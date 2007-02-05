@ERASE

0 REM this is the base code for all the AIRcable OS products
0 REM we take the AIRcable SMD/Mini as our base device

0 REM let's reserve the first 30 lines for internal stuff

0 REM $1 is the version of the command line
1 0.5

0 REM defaults setting for mode
0 REM uncomment the one you want to use as default
0 REM service slave
2 1110
0 REM service master 3110
0 REM cable slave 1010
0 REM cable master 3010
0 REM idle 0010

0 REM $3 stores the mode configuration
0 REM $3[0] = 0 48 means idle
0 REM $3[0] = 1 49 means pairing as slave
0 REM $3[0] = 2 50 means paired as slave
0 REM $3[0] = 3 51 means pairing as master
0 REM $3[0] = 4 52 means paired as master
0 REM $3[0] = 5 53 means relay pairing
0 REM $3[0] = 6 54 means relay paired
0 REM $3[0] = 7 55 means relay slave connected, master connecting
0 REM $3[0] = 8 56 means relay connected

0 REM $3[1] = 0 48 cable mode
0 REM $3[1] = 1 49 service mode
0 REM $3[1] = 2 50 relay mode

0 REM $3[2] = 0 48 device found / module paired
0 REM $3[2] = 1 49 inquiry needed

0 REM $3[3] = 0 48 means automatic
0 REM $3[3] = 1 49 means manual idle.
0 REM $3[3] = 2 50 manual slave, connecting
0 REM $3[3] = 3 51 manual inq
0 REM $3[3] = 4 52 manual master, connecting
0 REM $3[3] = 5 53 manual slave, connected
0 REM $3[3] = 6 54 manual master, connected
0 REM $3[3] = 7 55 relay pairing

0 REM $3[4] = 1 49 means service relay mode
0 REM $3[4] = 2 50 means cable relay mode

0 REM if var K = 1 then we must do a slave-1

0 REM $3[4] is the amount of time we trigger alarms while on manual
0 REM need service-master mode, does not store pairing information starts 
0 REM with pairing
3 Z

0 REM $4 IS RESERVED FOR PAIRED ADDR
4 0

0 REM $5 stores the name of the devices we only want during inquiry
5 AIRcable

0 REM $6 stores the filter address we filter on during inquiry
6 00A8FFFFFF

0 REM $7 for paired master addresses
7 0

0 REM $8 stores the pio settings
0 REM $8[0] BLUE LED
0 REM $8[1] GREEN LED
0 REM $8[2] BUTTON
0 REM $8[3] RS232 POWER OFF
0 REM $8[4] RS232 POWER ON
0 REM $8[5] DTR
0 REM $8[6] DSR
0 REM $8[7] POWER SWITCH
0 REM LINE $12 STORES THE DEFAULT VALUE
0 REM z means unitializated
8 z

0 REM Debug settings
0 REM first char is for Z enabled/disabled
0 REM second char is for shell
0 REM third is for dumping states
0 REM fourth for Obex/ObexFTP
0 REM 0 48 Enabled only on command line
0 REM 1 49 Always enabled
0 REM 2 50 Always Disabled
9 0000

0 REM $10 stores our friendly name
10 AIRcable

0 REM $11 stores our PIN
11 1234

0 REM DEFAULT pio settings IN ORDER
0 REM BLUE LED
0 REM GREEN LED
0 REM BUTTON
0 REM RS232 POWER OFF
0 REM RS232 POWER ON
0 REM DTR
0 REM DSR
0 REM POWER SWITCH
12 K0000000

0 REM PIO_IRQ SETTINGS
0 REM 13 only buttons pio, used for starting interrupts when there is
0 REM no connection going on
13 P000000000000
0 REM 14 button + DSR interrupt, interrupts that must be listened while
0 REM there is a connection going on
14 P000000000000

0 REM 15 is the settings for the uart when a connection is made
0 REM 0 means read from dip swithces
0 REM any other number is converted to an int.
15 1152

0 REM 16 this is the time that the Obex/ObexFTP will be available after
0 REM boot up
16 120

0 REM on variable I we store the baud rate setting.
0 REM this variable is initializated by @SENSOR
0 REM and is not setted until a connection is stablished


0 REM $20 is used for relay mode, it stores the master address
20 000000000000

0 REM $21 PIO_IRQ while off mode
21 P000000000000

0 REM $39 RESERVED
39 RESERVED

0 REM THIS TURNS A CHAR AT $0[E] into
0 REM and integer in F
40 IF $0[E] > 57 THEN 43
41 F = $0[E] - 48;
42 RETURN
0 REM WE NEED TO ADD 10 BECAUSE "A" IS NOT 0
0 REM IS 10
43 F = $0[E] - 55;
44 RETURN


@INIT 45
45 Z = $9[0] - 48;
46 A = uart 1152
47 IF $9[2] = 48 THEN 49
48 PRINTU "@INIT\n\r";
49 IF $8[0] <> 122 THEN 57
50 $0[0] = 0
51 PRINTV $12
52 FOR E = 0 TO 7
53 GOSUB 40
54 $8[E] = F + 48
55 NEXT E
56 $8[8] = 0

57 $0[0] = 0;
58 PRINTV $10;
59 PRINTV " ";
60 A = getuniq $39;
61 PRINTV $39;
62 A = name $0;

63 H = 1

0 REM button as input
64 A = pioin ($8[2]-48);
0 REM bias pull up to high
65 A = pioset ($8[2]-48);
0 REM green LED output, off
66 A=pioout ($8[1]-48);
67 A=pioclr ($8[1]-48);
0 REM blue LED output, off
68 A=pioout ($8[0]-48)
0 REM RS232_off set, switch on RS232
69 A=pioout ($8[3]-48)
70 A=pioset ($8[3]-48)
0 REM RS232_on power on, switch to automatic later
71 A=pioout ($8[4]-48)
72 A=pioset ($8[4]-48)
0 REM DTR output set -5V
73 A=pioout ($8[5]-48)
74 A=pioset ($8[5]-48)
0 REM DSR input
75 A=pioin ($8[6]-48)
0 REM set DSR to IRQ so that PIO_IRQ is called
0 REM just button interrupts here
76 A=pioirq $13

0 REM start baud rate
77 A = baud 1152
78 A = nextsns 6
0 REM reset for pairing timeout
79 A = zerocnt
80 IF $9[2] = 48 THEN 82
81 PRINTU "Command Line ready

0 REM state initialize
82 IF $3[0] <> 90 THEN 84
0 REM newly updated BASIC program, goto SLAVE mode
83 $3 = $2;

0 REM init button state
84 W = 0

0 REM in idle mode we wait for a command line interface start
0 REM you must type a +++ and enter
0 REM blue LED off
85 A = pioclr ($8[0]-48)
86 J = 0

87 $3[3] = 48;

0 REM should go to mode dump
88 IF $9[2] = 48 THEN 90
89 GOSUB 577

0 REM let's start up, green LED on
90 A = pioset ($8[1]-48)

91 K = 1
0 REM now we go to @IDLE, and then we get into the @ALARM
92 A = uartint
93 H = 1
0 REM for Unisex V2 switch detector
94 A = pioset $8[7]-48
95 A = pioin $8[7]-48
96 M = 0
97 IF H = 0 THEN 99
98 RESERVED
99 RETURN

0 REM Obex/ObexFTP timing handler
0 REM this code is also called from the command line on exit
100 B = readcnt
101 C = atoi $16
102 IF B < C THEN 109
103 GOSUB 107
104 H = 0
105 GOTO 233

106 IF $9[3] = 49 THEN 108
107 A = disable 3
108 RETURN

109 ALARM 30
110 GOTO 233

@SENSOR 111
0 REM baud rate selector switch implementation
0 REM thresholds (medians) for BAUD rate switch
0 REM AIO0 has voltage, use 1000 (3e8) as analog correction factor
0 REM if it is smaller than this, then switch is set
0 REM voltages: 160, 450, 650, 810, 930, 1020, 1090, >
0 REM switch    111, 110, 101, 100, 011,  010,  001, 000
0 REM baud:    1152,  96, 384, 000, 576,   48,  192, 321
111 IF $15[0] = 48 THEN 117;
0 REM we need to convert from string to integer, because we are on internal
0 REM baud rate, if an error ocurs while converting, then we switch
0 REM to the dip's automatically
112 C = atoi $15;
113 IF C = 0 THEN 117;
114 I = C;
115 A = baud I
116 RETURN
117 C = sensor $0;
118 IF C < 160 THEN 127;
119 IF C < 450 THEN 129;
120 IF C < 650 THEN 131;
121 IF C < 810 THEN 133;
122 IF C < 930 THEN 135;
123 IF C < 1020 THEN 137;
124 IF C < 1090 THEN 139;
125 I = 321;
126 GOTO 115;

127 I = 1152;
128 GOTO 115;
129 I = 96;
130 GOTO 115;
131 I = 384;
132 GOTO 115;
133 I = 1152;
134 GOTO 115;
135 I = 576;
136 GOTO 115;
137 I = 48;
138 GOTO 115;
139 I = 192;
140 GOTO 115;

141 RETURN
0 REM handle button press and DSR, status is $0
@PIO_IRQ 142
142 IF $9[2] = 48 THEN 145;
143 PRINTU "PIO_IRQ\n\r"
144 PRINTU $0

0 REM press button starts alarm for long press recognition
145 IF $0[$8[2]-48]=48THEN183
0 REM speaciall tratement for Button release on rebooting
146 IF W = 3 THEN 141
0 REM was it a release, now handle it
147 IF W <> 0 THEN 156

0 REM button no pressed, button not released
0 REM when DSR on the RS232 changes
148 IF $0[$8[6]-48]=48THEN151;
149 IF $0[$8[6]-48]=49THEN153;
150 RETURN
0 REM modem control to the other side
151 A = modemctl 0;
152 RETURN
153 A = modemctl 1;
154 RETURN

0 REM released with W == 2, alarm already handled it, exit
155 IF W = 2 THEN 179

0 REM this is a short button press
0 REM if we are on idle mode, then we switch to cable slave
0 REM if we are on service or cable unnconnected then switch master <-> slave
0 REM there is a slight difference between this spec, and the last one
0 REM on the last one any button press while on service did nothing.
156 B = status;
157 IF B < 10000 THEN 159;
158 B = B - 10000;
159 IF B > 0 THEN 188;
160 IF $3[0] = 48 THEN 170;
161 IF $3[0] > 50 THEN 170;

0 REM we were slave, now lets go to master.
162 ALARM 0
163 IF $9[2] = 48 THEN 165;
164 PRINTU "-> pair as master";
165 $3[0] = 51;
166 W = 0;
167 B = zerocnt;
168 A = slave-1;
169 RETURN

0 REM switch to pair as slave
170 ALARM 0
171 IF $9[2] = 48 THEN 173
172 PRINTU "-> pair as slave\n"
173 $3[0] = 49
174 W = 0
175 A = zerocnt;
0 REM cancel inquiries
176 A = cancel
177 ALARM 1
178 RETURN

179 IF $9[2] = 48 THEN 181
180 PRINTU"Handled, ignore\n\r"
181 W = 0
182 RETURN


0 REM button press, recognize it and start ALARM for long press
183 IF $9[2] = 48 THEN 185
184 PRINTU "Button press\n\r"
185 W = 1
186 ALARM 3
187 RETURN

188 IF $9[2] = 48 THEN 190
189 PRINTU "Short, Connected
190 W = 0
191 RETURN

0 REM idle will be called, when the command line ends working
0 REM when the slave connection is closed, and when slave calls
0 REM timeouts, in any of those cases we will let the @ALARM
0 REM handle the slave mode stuff
0 REM idle used for slave connections, pairing or paired
@IDLE 192
192 IF $3[3] <> 48 THEN 757;
193 IF $3[0] > 52 THEN 201;
194 IF W <> 0 THEN 200;
195 IF K = 1 THEN 198;
196 IF K = 2 THEN 199;
0 REM lets trigger the alarm manually
197 GOTO 227;


198 A = slave-1;
199 K = 0;
200 RETURN

201 IF $3[0] = 53 THEN 214
202 IF $3[0] = 54 THEN 206
203 IF $3[0] = 55 THEN 718
204 A = disconnect 1
205 $3[0] = 54
206 A = uartint
207 B = status
208 IF B > 0 THEN 210
209 GOSUB 822
210 A = pioset ($8[1]-48);
211 A = pioset ($8[0]-48)
212 A = pioclr ($8[0]-48)
213 ALARM 9
214 RETURN

215 A = pioset ($8[0]-48);
216 A = pioset ($8[1]-48)
217 A = pioclr ($8[1]-48);
218 B = status
219 IF B > 1 THEN 221
220 A = master $20
221 ALARM 4
222 RETURN

@PIN_CODE 223
223 IF $9[2] = 48 THEN 225
224 PRINTU "@PIN_CODE"
225 $0=$11;
226 RETURN

0 REM ALARM code, handles modes stuff, LEDs and long button press 
@ALARM 227
227 IF $9[2] = 48 THEN 229
228 PRINTU "@ALARM\n\r";


0 REM handle button press first of all.
229 IF W = 1 THEN 267


0 REM should go to mode dumping
230 IF $9[2] = 48 THEN 232
231 GOSUB 577

232 IF H = 1 THEN 100

233 IF $3[0] > 52 THEN 783

0 REM now the led stuff, and finally we handle the state.
0 REM firstly see if we are connected, then do what you need
234 B = status;
235 IF B < 10000 THEN 237;
236 B = B - 10000;
237 IF B > 0 THEN 239;
238 GOTO 243
0 REM ensure the leds are on
239 A = pioset ($8[0]-48);
240 A = pioset ($8[1]-48);
241 ALARM 5
242 RETURN

243 A = baud 1152
0 REM are we on automatic or manual?
244 IF $3[3] <> 48 THEN 699
0 REM we are on automatic.
0 REM are we on automatic - manual?
245 IF $3[0] = 48 THEN 262

0 REM LED SCHEMA:
0 REM CABLE 	SLAVE 	1 fast blink
0 REM SERVICE 	SLAVE 	2 fast blink
0 REM CABLE	MASTER 	3 fast blink
0 REM SERVICE	MASTER 	4 fast blink
246 A = pioset ($8[1]-48);
247 A = pioset ($8[0]-48)
248 A = pioclr ($8[0]-48);
0 REM are we on master or slave?
249 IF $3[0] > 50 THEN 254
0 REM ok we are on slave
0 REM CABLE 	SLAVE 1 fast BLINK
0 REM SERVICE 	SLAVE 2 fast BLINK

0 REM now are we on cable or service?
250 IF $3[1] = 48 THEN 305
0 REM service slave
251 A = pioset ($8[0]-48)
252 A = pioclr ($8[0]-48);
253 GOTO 294;

0 REM we are on master modes
254 FOR B = 0 TO 2
255 A = pioset ($8[0]-48)
256 A = pioclr ($8[0]-48
257 NEXT B
258 IF $3[1] = 48 THEN 305;
259 A = pioset ($8[0]-48)
260 A = pioclr ($8[0]-48);
261 GOTO 296;


0 REM manual idle code, this is the only mode that ends here.
262 B = pioset ($8[1]-48);
263 B = pioclr ($8[0]-48);
0 REM little hidden feauture on $3[5], it is somesort of flag
0 REM that tell us if this is the first time that @IDLE is called
0 REM or the second, while we are on automatic-manual
264 A = slave-1;
265 K = 2
266 RETURN

0 REM this is a long button press, we have stuff to do
0 REM if we are connected, then we disconnect and reboot to unpaired
0 REM if we aren't then we must reboot and go to idle mode.
267 GOSUB 1000;
268 W = 2
269 IF $39[3] = 49 THEN 281
270 IF $39[4] = 49 THEN 281

0 REM reboot 
271 $3[0] = 48
272 $3[1] = 48
273 IF $9[2] = 48 THEN 275
274 PRINTU"->Reboot\n\r";
275 A = pioclr($8[0]-48);
276 A = pioclr($8[1]-48);
277 W = 3
278 A = reboot
279 WAIT 3;
280 RETURN

0 REM disconnects, disconnect restarts @IDLE
281 ALARM 0
282 IF $9[2] = 48 THEN 284
283 PRINTU "-> Discconnect\n\r"
0 REM if we were paired, then we must unpair.
284 IF $3[0] = 50 THEN 287
285 IF $3[0] = 52 THEN 287
286 GOTO 288;
287 $3[0] = ($3[0] -1)
0 REM 307 A = disconnect 0
0 REM 308 A = disconnect 1
0 REM 309 A = cancel
288 $7 = "0"
289 GOTO 273

0 REM cable mode timeout
290 IF $9[2] = 48 THEN 292
291 PRINTU "Timeout\n\r";
292 ALARM 0;
293 GOTO 262;

0 REM automatic modes code.
0 REM service - slave:
294 A = slave 5;
295 RETURN

0 REM service - master
296 A = strlen $7;
297 IF A > 1 THEN 301
298 A = inquiry 6
299 ALARM 8
300 RETURN

301 A = master $7
0 REM master returns 0 if the connection was succesfull
0 REM or if we are still trying to connect.
302 IF A = 0 THEN 239
303 ALARM 8
304 RETURN

0 REM cable code, if we are not paired check for timeout.
305 IF $3[0] = 50 THEN 311
306 IF $3[0] = 52 THEN 301
307 B = readcnt
308 IF B > 120 THEN 290
309 IF $3[0] = 49 THEN 294
0 REM we are pairing as master,
310 GOTO 298;

311 A = slave -5;
312 RETURN


0 REM this interrupt is launched when there is an incomming
0 REM slave connection
@SLAVE 313
313 IF $9[2] = 48 THEN 315;
314 PRINTU "@SLAVE\n\r";
315 IF $3[0] = 54 THEN 820;
0 REM if we are not on slave mode, then we must ignore slave connections :D
316 IF $3[3] = 50 THEN 339;
317 IF $3[0] > 50 THEN 342;
318 IF $3[0] > 48 THEN 320;
319 GOTO 342

320 A = getconn $7
0 REM if we are on service-slave, and the PIN was a success
0 REM then this is our peer.
321 IF $3[1] = 49 THEN 329
0 REM cable-slave-paired, check address
322 IF $3[0] = 50 THEN 326

0 REM set to paired no matter who cames
323 $3[0] = 50
324 $4 = $7
325 GOTO 329

0 REM check address of the connection and allow
326 $0 = $4
327 B = strcmp $7
328 IF B <> 0 THEN 342

0 REM slave connected
0 REM allow DSR interrupts
0 REM green and blue LEDS on
0 REM read sensors
329 A = nextsns 1
330 B = pioset ($8[1]-48)
331 B = pioset ($8[0]-48)
0 REM set RS232 power to on
332 A = pioset ($8[4]-48)
0 REM DTR set on, +5V
333 A = pioclr ($8[5]-48)
0 REM allow DSR interrupts
334 A = pioirq $14
0 REM connect RS232 to slave
335 IF $9[1]= 49 THEN 344
0 REM 376 A = baud I
336 ALARM 0
337 C = link 1
338 RETURN

339 PRINTU"\n\rCONNECTED\n\r
340 $3[3] = 53
341 GOTO 331

0 REM disconnect and exit
342 A = disconnect 0
343 RETURN

344 C = shell
345 RETURN

@MASTER 346
0 REM successful master connection
346 IF $9[2] = 48 THEN 348
347 PRINTU "@MASTER\n\r";
348 IF $3[0] > 52 THEN 795
0 REM if we are on manual master, then we have some requests
349 IF $3[3] <> 52 THEN 354
350 $3[3] = 54
351 A = pioset ($8[1]-48);
352 A = pioset ($8[0]-48);
353 GOTO 362
0 REM if we are not on master modes, then we must avoid this connection.
354 IF $3[0] > 50 THEN 357;
355 IF $3[0] > 48 THEN 372;
356 IF $3[0] = 48 THEN 372;
357 A = pioset ($8[1]-48);
358 A = pioset ($8[0]-48);
0 REM don't switch state in service mode or manual
359 IF $3[3] = 52 THEN 369
360 IF $3[1] = 49 THEN 362
0 REM set state master paired
361 $3[0] = 52

0 REM read sensors
362 A = nextsns 1
363 A = pioset ($8[4]-48);
0 REM DTR set on
364 A = pioclr ($8[5]-48);
0 REM link
365 A = link 2
0 REM look for disconnect
366 ALARM 5
0 REM allow DSR interrupts
367 A = pioirq $14
368 RETURN

369 PRINTU"\n\rCONNECTED\n\r
370 $3[4] = 54
371 GOTO 362

372 A = disconnect 1
373 RETURN

0 REM $374 RESERVED
374 RESERVED
0 REM inquiry code, only in mode pair_as_master
@INQUIRY 375
375 $374 = $0
376 IF $9[2] = 48 THEN 378
377 PRINTU "@INQUIRY\n\r";
378 IF $3[3] <> 51 THEN 383
379 PRINTU"\n\rFound device: "
380 PRINTU $374
381 ALARM 4
382 RETURN

383 $4 = $374;
384 $374 = $0[13];
385 IF $3[0] <> 51 THEN 388;
0 REM inquiry filter active
386 IF $3[2] = 48 THEN 388;
387 IF $3[2] = 49 THEN 389;
388 RETURN

389 IF $9[2] = 48 THEN 392;
390 PRINTU "found "
391 PRINTU $4
0 REM check name of device
392 $0[0]=0;
393 PRINTV $374;
394 B = strcmp $5;
395 IF B <> 0 THEN 402;

0 REM found one, try to connect, inquiry canceled automaticall
0 REM 447 GOSUB 485;
396 B = master $4;
0 REM if master busy keep stored address in $4, get next
397 IF B = 0 THEN 403;
0 REM master accepted, store address, restart alarms, give it 8 seconds to connect
0 REM corrected by mn
398 $7 = $4;
399 ALARM 8;
0 REM all on to indicate we have one
400 A = pioset ($8[1]-48);
401 A = pioset ($8[0]-48);
402 RETURN

0 REM get next result, give the inq result at least 2 sec time
403 GOSUB 405;
404 RETURN

0 REM blink sub-routine pair as master mode, blue-on green-off and reverse
405 IF J = 1 THEN 410;
406 J = 1;
407 A = pioset ($8[0]-48);
408 A = pioclr ($8[1]-48);
409 RETURN
410 A = pioclr ($8[0]-48);
411 A = pioset ($8[0]-48);
412 J = 0;
413 RETURN;

@CONTROL 414
0 REM remote request for DTR pin on the RS232
414 IF $0[0] < 128 THEN 417
415 A = uartcfg$0[0]
416 RETURN
417 IF $0[0] = 49 THEN 419;
418 A=pioset ($8[5]-48);
419 RETURN;
420 A=pioclr ($8[5]-48);
421 RETURN

@UART 422
422 IF $9[2] = 48 THEN 424
423 PRINTU"@UART\n\r
424 A = uartint
425 $0[0] = 0;
426 TIMEOUTU 5
427 INPUTU $0;
428 A = strlen $0;
429 IF $0[A-3] <> 43 THEN 431
0 REM command line interface active
430 IF $0[A-1] = 43 THEN 433
431 A = uartint;
432 RETURN

433 $3[3] = 49
434 ALARM 1
435 A = enable 3
436 RETURN



0 REM read from uart and echo function
0 REM on line 940 we have the other uart echo function.
0 REM result is on $529
0 REM 528, 438 RESERVED FOR TEMP
437 RESERVED
438 RESERVED
439 A = 1;
440 $438[0] = 0;
441 UART A;
442 IF $0[0] = 13 THEN 450;
443 $437 = $0;
444 PRINTU $0;
445 $0[0] = 0;
446 PRINTV $438;
447 PRINTV $437;
448 $438 = $0;
449 GOTO 441;
450 RETURN

0 REM command line interface
451 ALARM 0
452 A = baud 1152
453 A = pioclr ($8[0]-48);
454 A = pioclr ($8[1]-48);
455 $3[3] = 49
0 REM enable FTP again
456 A = enable 3
457 PRINTU "\r\nAIRcable OS "
458 PRINTU "command line v
459 PRINTU $1
460 PRINTU "\r\nType h to "
461 PRINTU "see the list of "
462 PRINTU "commands";
463 PRINTU "\n\rAIRcable> "
464 GOSUB 681;
465 PRINTU"\n\r

0 REM h: help, l: list,
0 REM n: name, p: pin, b: name filter, g: address filter
0 REM c: class of device, u: uart, d: date,
0 REM s: slave, i: inquiry, m: master, a: mode
0 REM o: obex
0 REM e: exit

0 REM help
466 IF $438[0] = 104 THEN 598;
0 REM info
467 IF $438[0] = 108 THEN 497;
0 REM name
468 IF $438[0] = 110 THEN 611;
0 REM pin
469 IF $438[0] = 112 THEN 621;
0 REM class
470 IF $438[0] = 99 THEN 625;
0 REM uart
471 IF $438[0] = 117 THEN 523;
0 REM date
472 IF $438[0] = 100 THEN 651;
0 REM inquiry
473 IF $438[0] = 105 THEN 724;
0 REM slave
474 IF $438[0] = 115 THEN 749;
0 REM master
475 IF $438[0] = 109 THEN 734;
0 REM obex
476 IF $438[0] = 111 THEN 661;
0 REM modes
477 IF $438[0] = 97 THEN 536;
0 REM exit
478 IF $438[0] = 101 THEN 490;
0 REM name filter
479 IF $438[0] = 98 THEN 641;
0 REM addr filter
480 IF $438[0] = 103 THEN 646;
0 REM hidden debug settings
481 IF $438[0] = 122 THEN 486;
0 REM reboot
482 IF $438[0] = 114 THEN 687;
0 REM relay mode pair
483 IF $438[0] = 106 THEN 769;
484 PRINTU"Command not found
485 GOTO 463;

486 PRINTU"Input settings: "
487 GOSUB 439
488 $9 = $438
489 GOTO 463

0 REM exit code, we end with slave-1 to ensure
0 REM that @SLAVE starts all again, and that
0 REM we start unvisible
490 PRINTU "Bye!!\n\r
491 GOSUB 107;
492 $3[3] = 48;
493 A = slave -1;
494 A = uartint
495 A = zerocnt
496 RETURN

0 REM ----------------------- Listing Code ------------------------------------
497 PRINTU"Command Line v
498 PRINTU $1
499 PRINTU"\n\rName: ";
500 PRINTU $10;
501 PRINTU"\n\rPin: ";
502 PRINTU$11;
503 A = psget 0;
504 PRINTU"\n\rClass: ";
505 PRINTU $0;
506 PRINTU"\n\rBaud Rate: "
507 GOSUB 530
508 PRINTU"\n\rDate: ";
509 A = date $0;
510 PRINTU $0;
511 A = getaddr;
512 PRINTU"\n\rBT Address:
513 PRINTU $0
514 GOSUB 1000;
515 PRINTU"\n\rBT Status:
516 PRINTU $39;
517 PRINTU"\n\rName Filter:
518 PRINTU $5;
519 PRINTU"\n\rAddr Filter:
520 PRINTU $6;
521 GOSUB 577
522 GOTO 463;

523 PRINTU"Enter new Baud Ra
524 PRINTU"te divide by 100,
525 PRINTU"or 0 for switches
526 PRINTU": "
527 GOSUB 439
528 $15 = $438
529 GOTO 463

530 IF $15[0] = 48 THEN 534
531 PRINTU $15
532 PRINTU "00 bps
533 RETURN
534 PRINTU "External
535 RETURN

0 REM -------------------------- Modes chooser --------------------------------
0 REM the user should select between
0 REM 0: Manual
0 REM 1: Service Slave
0 REM 2: Service Master
0 REM 3: Cable Slave
0 REM 4: Cable Master
0 REM 5: Master Relay Mode
0 REM Mode:
536 PRINTU"Select new mode\n
537 PRINTU"\r0: Manual\n\r1:
538 PRINTU" Service Slave\n
539 PRINTU"\r2: Service Mast
540 PRINTU"er\n\r3: Cable Sl
541 PRINTU"ave\n\r4: Cable M
542 PRINTU"aster\n\r5: Maste
543 PRINTU"r Relay Mode\n\rM
544 PRINTU"ode: "
545 GOSUB 681;
546 IF $438[0] = 48 THEN 554;
547 IF $438[0] = 49 THEN 557;
548 IF $438[0] = 50 THEN 561;
549 IF $438[0] = 51 THEN 565;
550 IF $438[0] = 52 THEN 569;
551 IF $438[0] = 53 THEN 573;
552 PRINTU"\n\rInvalid Option
553 GOTO 463;

554 $3[0]=48;
555 $3[3]=49;
556 GOTO 463;
557 $3[0] = 49;
558 $3[1] = 49;
559 $3[3] = 48;
560 GOTO 463;
561 $3[0] = 51;
562 $3[1] = 49;
563 $3[3] = 48;
564 GOTO 463;
565 $3[0] = 49;
566 $3[1] = 48;
567 $3[3] = 48;
568 GOTO 463;
569 $3[0] = 51;
570 $3[2] = 49;
571 $3[3] = 48;
572 GOTO 463;
573 $3[0] = 53;
574 $3[1] = 50;
575 $3[2] = 48;
576 GOTO 463

0 REM -------------------------- Listing code ---------------------------------
577 PRINTU "\n\rMode: "
578 IF $3[0] > 52 THEN 596
579 IF $3[0] = 48 THEN 594
580 IF $3[1] = 48 THEN 583
581 PRINTU"Service - "
582 GOTO 584;
583 PRINTU"Cable - "
584 IF $3[0] >= 51 THEN 587;
585 PRINTU"Slave"
586 GOTO 588;
587 PRINTU"Master"
588 IF $3[0] = 50 THEN 592;
589 IF $3[0] = 52 THEN 592;
590 PRINTU"\n\rUnpaired"
591 RETURN
592 PRINTU"\n\rPaired"
593 RETURN
594 PRINTU"Idle"
595 RETURN
596 PRINTU"Relay Mode Master
597 RETURN

0 REM ----------------------- Help code ---------------------------------------
0 REM h: help, l: list,
0 REM n: name, p: pin, b: name filter, g: address filter
0 REM c: class of device, u: uart, d: date,
0 REM s: slave, i: inquiry, m: master, a: mode
0 REM o: obex, f: obexftp, j: relay mode pair
0 REM e: exit, r: reboot
598 PRINTU"h: help, l: li
599 PRINTU"st\n\rn: name, p: "
600 PRINTU"pin, b: name filte
601 PRINTU"r, g: address filt
602 PRINTU"er\n\rc: class of "
603 PRINTU"device, u: uart, d
604 PRINTU": date\n\rs: slav
605 PRINTU"e, i: inquiry, m: "
606 PRINTU"master, a: mode\n
607 PRINTU"\ro: obex, j: relay
608 PRINTU" mode pair\n\re: ex
609 PRINTU"it, r: reboot
610 GOTO 463;

0 REM Name Function
611 PRINTU"New Name: "
612 GOSUB 439;
613 $10 = $438;
614 $0[0] = 0;
615 PRINTV $10;
616 PRINTV " ";
617 A = getuniq $39;
618 PRINTV $39;
619 A = name $0;
620 GOTO 463

0 REM Pin Function
621 PRINTU"New PIN: ";
622 GOSUB 439;
623 $11 = $438;
624 GOTO 463

625 PRINTU"Type the class of "
626 PRINTU"device as xxxx xxx"
627 PRINTU"x: "
628 GOSUB 439
629 $0[0] = 0;
630 PRINTV"@0000 =
631 PRINTV$438;
632 $438 = $0;
633 A = psget 0;
634 $437 =$0
635 $0[0]=0;
636 PRINTV $438;
637 $438 = $437[17]
638 PRINTV $438;
639 A = psset 3
640 GOTO 463

0 REM friendly name filter code
641 PRINTU"Enter the new name"
642 PRINTU" filter: "
643 GOSUB 439
644 $5 = $438
645 GOTO 463;

0 REM addr filter code
646 PRINTU"Enter the new addr"
647 PRINTU"ess filter: "
648 GOSUB 439
649 $6 = $438
650 GOTO 463

0 REM date changing methods
651 PRINTU"Insert new dat
652 PRINTU"e, check the manua
653 PRINTU"l for formating: "
654 GOSUB 439;
655 A = strlen $438
656 IF A <> 16 THEN 659
657 A = setdate $438
658 GOTO 463
659 PRINTU"\n\rInvalid format
660 GOTO 463

0 REM activate Obex/ObexFTP
0 REM 0 Enabled only on command line
0 REM 1 Always enabled
0 REM 2 Always Disabled
661 PRINTU"Obex/ObexFTP setti"
662 PRINTU"ngs:\n\r0: Enabled "
663 PRINTU"only on command li"
664 PRINTU"ne\n\r1: Always Ena"
665 PRINTU"bled\n\r2: Always D"
666 PRINTU"isabled\n\rChoose "
667 PRINTU"Option: "
668 GOSUB 681
669 939 $9[3] = $438[0]
670 IF $438[0] = 50 THEN 676
671 $0[0] = 0
672 A = psget 6
673 $0[11] = 48
674 A = psset 3
675 GOTO 463
676 $0[0] = 0
677 A = psget 6
678 $0[11] = 54
679 A = psset 3
680 GOTO 463

0 REM one char read function
681 A = 1
682 $438[0] = 0;
683 UART A
684 PRINTU $0
685 $438 = $0
686 RETURN

0 REM reboot code
687 PRINTU"Rebooting, please "
688 PRINTU"do not disconnect "
689 PRINTU"electric power\n\r
690 $3[3] = 48
691 A = reboot
692 WAIT 2
693 RETURN

0 REM ---------------------- Manual Modes code --------------------------------

694 PRINTU "\n\rThere is BT
695 PRINTU "activity, please
696 PRINTU "wait and try agai
697 PRINTU "n
698 GOTO 463;

0 REM Led STUFF for manual 
699 IF $3[3] = 50 THEN 707
700 IF $3[3] = 51 THEN 712
701 IF $3[3] = 52 THEN 719
0 REM command line has just started?
702 IF $3[3] = 49 THEN 451
703 IF $3[3] = 54 THEN 704
799 RETURN

704 A = pioclr ($8[0]-48);
705 A = pioclr ($8[1]-48);
706 GOTO 463

0 REM slave connecting leds
707 A = pioset ($8[1]-48);
708 A = pioset ($8[0]-48)
709 A = pioclr ($8[0]-48)
710 ALARM 4
711 GOTO 757

0 REM inq leds
712 A = pioset ($8[0]-48);
713 A = pioset ($8[1]-48)
714 A = pioclr ($8[0]-48);
715 A = pioclr ($8[1]-48);
716 ALARM 2
717 GOTO 757


0 REM this line is part of the relay mode
718 A = zerocnt
0 REM master connecting leds
719 A = pioset ($8[0]-48);
720 A = pioset ($8[1]-48)
721 A = pioclr ($8[1]-48);
722 ALARM 4
723 GOTO 757

0 REM inquiry code
0 REM by default we inquiry for 10 seconds
724 GOSUB 1000;
725 IF $39[0] = 49 THEN 694
726 PRINTU"Inquirying for
727 PRINTU" 16s. Please wait.
728 B = inquiry 10
729 $3[3] = 51;
730 GOSUB 1000;
731 A = zerocnt
732 A = nextsns 0
733 GOTO 712;

0 REM master code
734 GOSUB 1000;
735 IF $39[3] = 49 THEN 694
736 PRINTU"Please input "
737 PRINTU"the addr of your "
738 PRINTU"peer:
739 GOSUB 439
740 B = strlen$438
741 IF B<>12 THEN 746
742 $3[3] = 52;
743 B = master $438
744 B = zerocnt
745 GOTO 719

746 PRINTU"Invalid add
747 PRINTU"r, try again.
748 GOTO 463;

0 REM slave code
0 REM manual slave
0 REM by default we open the slave channel for 60 seconds
749 GOSUB 1000;
750 IF $39[4] = 49 THEN 694
751 PRINTU"Slave Open for
752 PRINTU" 16s. Please wait.
753 $3[3] = 50
754 A = slave 15
755 A = zerocnt
756 GOTO 707


0 REM timeout for any manual mode, as this part of the code
0 REM will be called as soon as the slave channel is opened
0 REM we check for activity firstly
757 B = readcnt
758 IF B < 16 THEN 768
759 $3[3] = 49
760 ALARM 0
761 A = cancel
762 A = disconnect 0
763 A = disconnect 1
764 A = pioclr ($8[0]-48)
765 A = pioclr ($8[1]-48)
766 A = nextsns 4
767 GOTO 463

768 RETURN

0 REM ---------------------------- RELAY CODE ----------------------------------

0 REM relay mode pair
0 REM Enter the address of your peer: 
769 PRINTU"Enter the address "
770 PRINTU"of your peer: "
771 GOSUB 439;
772 A = strlen $438;
773 IF A = 12 THEN 776;
774 PRINTU"\n\rNot valid peer
775 GOTO 463
776 PRINTU"\n\rTrying to pair
777 $3[0] = 53;
778 $3[3] = 48;
779 $20 = $438
780 A = zerocnt
781 A = master $20
782 GOTO 719

0 REM relay mode alarm handler
0 REM first check for command line
783 IF $3[3] <> 48 THEN 451
784 ALARM 5
785 IF $3[0] = 53 THEN 719
786 B = status
787 IF $3[0] = 54 THEN 208
788 IF B < 1 THEN 206
789 IF $3[0] = 55 THEN 215
790 IF B > 10 THEN 242
791 A = disconnect 0
792 A = disconnect 1
793 $3[0] = 54
794 GOTO 424

795 IF $3[0] = 53 THEN 802
796 A = pioset ($8[1]-48);
797 A = pioset ($8[0]-48);
798 $3[0] = 56
799 A = link 3;
800 ALARM 4
801 RETURN
802 $3[0]=54
803 A = disconnect 1
804 PRINTU"\n\rPair successfull"
805 PRINTU"\n\rPlease choose "
806 PRINTU"which kind of relay "
807 PRINTU"you want:\n\r1: Serv"
808 PRINTU"ice Relay\n\r2: Cabl"
809 PRINTU"e Relay\n\rMode: "
810 ALARM 0
811 GOSUB 681
812 IF $438[0] = 49 THEN 816
813 IF $438[0] = 50 THEN 816
814 PRINTU"\n\rInvalid Option
815 GOTO 805
816 A = $438[0];
817 $3[4] = A;
818 $3[0] = 54;
819 GOTO 463

820 $3[0] = 55
821 GOTO 214

822 B = readcnt;
823 IF $3[4] = 50 THEN 826
824 A = slave 8;
825 RETURN
826 IF B < 120 THEN 824
827 A = slave -8;
828 RETURN

0 REM -------------------------- END RELAY CODE --------------------------------

0 REM convert status to a string
0 REM store the result on $44
1000 B = status
1001 $39[0] = 0;
1002 $39 = "00000";
1003 IF B < 10000 THEN 1006;
1004 $39[0] = 49;
1005 B = B -10000;
1006 IF B < 1000 THEN 1009;
1007 $39[1] = 49;
1008 B = B -1000;
1009 IF B < 100 THEN 1012;
1010 $39[2] = 49;
1011 B = B -100;
1012 IF B < 10 THEN 1015;
1013 $39[3] = 49;
1014 B = B -10;
1015 IF B < 1 THEN 1017;
1016 $39[4] = 49;
1017 $39[5] = 0;
1018 RETURN


