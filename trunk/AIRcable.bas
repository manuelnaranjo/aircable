@ERASE

0 REM this is the base code for all the AIRcable OS products
0 REM we take the AIRcable SMD/Mini as our base device

0 REM let's reserve the first 30 lines for internal stuff

0 REM $1 is the version of the command line
1 0.6a

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

0 REM 22 Parity Settings
0 REM [0] = "0" = none
0 REM "1" = even
0 REM "2" = odd
0 REM [1] = "0" 1 stop bit
0 REM "1" 2 stop bits
22 00

0 REM 23 unique settings
0 REM [0] = "0" don't add nothing
0 REM [0] = "1" add unique name
0 REM [0] = "2" add unique name, generate pin
23 0

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
46 A = baud 1152
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
59 IF $23[0] = 48 THEN 63
60 PRINTV " ";
61 A = getuniq $39;
62 PRINTV $39;
63 A = name $0;

64 H = 1

0 REM button as input
65 A = pioin ($8[2]-48);
0 REM bias pull up to high
66 A = pioset ($8[2]-48);
0 REM green LED output, off
67 A=pioout ($8[1]-48);
68 A=pioclr ($8[1]-48);
0 REM blue LED output, off
69 A=pioout ($8[0]-48)
0 REM RS232_off set, switch on RS232
70 A=pioout ($8[3]-48)
71 A=pioset ($8[3]-48)
0 REM RS232_on power on, switch to automatic later
72 A=pioout ($8[4]-48)
73 A=pioset ($8[4]-48)
0 REM DTR output set -5V
74 A=pioout ($8[5]-48)
75 A=pioset ($8[5]-48)
0 REM DSR input
0 REM this line is changed by serial OS code, so update
76 A=pioin ($8[6]-48)
0 REM set DSR to IRQ so that PIO_IRQ is called
0 REM just button interrupts here
77 A=pioirq $13

0 REM start baud rate
78 A = uartcfg 136
79 A = nextsns 6
0 REM reset for pairing timeout
80 A = zerocnt
81 IF $9[2] = 48 THEN 83
82 PRINTU "Command Line ready

0 REM state initialize
83 IF $3[0] <> 90 THEN 85
0 REM newly updated BASIC program, goto SLAVE mode
84 $3 = $2;

0 REM init button state
85 W = 0

0 REM in idle mode we wait for a command line interface start
0 REM you must type a +++ and enter
0 REM blue LED off
86 A = pioclr ($8[0]-48)
87 J = 0

88 $3[3] = 48;

0 REM should go to mode dump
89 IF $9[2] = 48 THEN 91
90 GOSUB 594

0 REM let's start up, green LED on
91 A = pioset ($8[1]-48)

92 K = 1
0 REM now we go to @IDLE, and then we get into the @ALARM
93 A = uartint
94 H = 1
0 REM for Unisex V2 switch detector
95 A = pioset $8[7]-48
96 A = pioin $8[7]-48
97 M = 0
98 IF H = 0 THEN 100
99 RESERVED
100 RETURN

0 REM Obex/ObexFTP timing handler
0 REM this code is also called from the command line on exit
101 B = readcnt
102 C = atoi $16
103 IF B < C THEN 110
104 GOSUB 108
105 H = 0
106 GOTO 236

107 IF $9[3] = 49 THEN 109
108 A = disable 3
109 RETURN

110 ALARM 30
111 GOTO 236

@SENSOR 112
0 REM baud rate selector switch implementation
0 REM thresholds (medians) for BAUD rate switch
0 REM AIO0 has voltage, use 1000 (3e8) as analog correction factor
0 REM if it is smaller than this, then switch is set
0 REM voltages: 160, 450, 650, 810, 930, 1020, 1090, >
0 REM switch    111, 110, 101, 100, 011,  010,  001, 000
0 REM baud:    1152,  96, 384, 000, 576,   48,  192, 321
112 IF $15[0] = 48 THEN 117;
0 REM we need to convert from string to integer, because we are on internal
0 REM baud rate, if an error ocurs while converting, then we switch
0 REM to the dip's automatically
113 C = atoi $15;
114 IF C = 0 THEN 117;
115 I = C;
116 GOTO 862
117 C = sensor $0;
118 IF C < 160 THEN 127;
119 IF C < 450 THEN 129;
120 IF C < 650 THEN 131;
121 IF C < 810 THEN 133;
122 IF C < 930 THEN 135;
123 IF C < 1020 THEN 137;
124 IF C < 1090 THEN 139;
125 I = 321;
126 GOTO 116;

127 I = 1152;
128 GOTO 116;
129 I = 96;
130 GOTO 116;
131 I = 384;
132 GOTO 116;
133 I = 1152;
134 GOTO 116;
135 I = 576;
136 GOTO 116;
137 I = 48;
138 GOTO 116;
139 I = 192;
140 GOTO 116;

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
192 IF $3[3] <> 48 THEN 790;
193 IF $3[0] > 52 THEN 201;
194 IF W <> 0 THEN 364;
195 IF K = 1 THEN 198;
196 IF K = 2 THEN 199;
0 REM lets trigger the alarm manually
197 GOTO 230;


198 A = slave-1;
199 K = 0;
200 RETURN

201 IF $3[0] = 53 THEN 214
202 IF $3[0] = 54 THEN 206
203 IF $3[0] = 55 THEN 751
204 A = disconnect 1
205 $3[0] = 54
206 A = uartint
207 B = status
208 IF B > 0 THEN 210
209 GOSUB 855
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
225 IF $23[0] = 50 THEN 228
226 $0=$11;
227 RETURN
228 A = getuniq $0
229 RETURN

0 REM ALARM code, handles modes stuff, LEDs and long button press 
@ALARM 230
230 IF $9[2] = 48 THEN 232
231 PRINTU "@ALARM\n\r";


0 REM handle button press first of all.
232 IF W = 1 THEN 270


0 REM should go to mode dumping
233 IF $9[2] = 48 THEN 235
234 GOSUB 594

235 IF H = 1 THEN 101

236 IF $3[0] > 52 THEN 816

0 REM now the led stuff, and finally we handle the state.
0 REM firstly see if we are connected, then do what you need
237 B = status;
238 IF B < 10000 THEN 240;
239 B = B - 10000;
240 IF B > 0 THEN 242;
241 GOTO 246
0 REM ensure the leds are on
242 A = pioset ($8[0]-48);
243 A = pioset ($8[1]-48);
244 ALARM 5
245 RETURN

246 A = uartcfg 136
0 REM are we on automatic or manual?
247 IF $3[3] <> 48 THEN 731
0 REM we are on automatic.
0 REM are we on automatic - manual?
248 IF $3[0] = 48 THEN 265

0 REM LED SCHEMA:
0 REM CABLE 	SLAVE 	1 fast blink
0 REM SERVICE 	SLAVE 	2 fast blink
0 REM CABLE	MASTER 	3 fast blink
0 REM SERVICE	MASTER 	4 fast blink
249 A = pioset ($8[1]-48);
250 A = pioset ($8[0]-48)
251 A = pioclr ($8[0]-48);
0 REM are we on master or slave?
252 IF $3[0] > 50 THEN 257
0 REM ok we are on slave
0 REM CABLE 	SLAVE 1 fast BLINK
0 REM SERVICE 	SLAVE 2 fast BLINK

0 REM now are we on cable or service?
253 IF $3[1] = 48 THEN 308
0 REM service slave
254 A = pioset ($8[0]-48)
255 A = pioclr ($8[0]-48);
256 GOTO 297;

0 REM we are on master modes
257 FOR B = 0 TO 2
258 A = pioset ($8[0]-48)
259 A = pioclr ($8[0]-48
260 NEXT B
261 IF $3[1] = 48 THEN 308;
262 A = pioset ($8[0]-48)
263 A = pioclr ($8[0]-48);
264 GOTO 299;


0 REM manual idle code, this is the only mode that ends here.
265 B = pioset ($8[1]-48);
266 B = pioclr ($8[0]-48);
0 REM little hidden feauture on $3[5], it is somesort of flag
0 REM that tell us if this is the first time that @IDLE is called
0 REM or the second, while we are on automatic-manual
267 A = slave-1;
268 K = 2
269 RETURN

0 REM this is a long button press, we have stuff to do
0 REM if we are connected, then we disconnect and reboot to unpaired
0 REM if we aren't then we must reboot and go to idle mode.
270 GOSUB 914;
271 W = 2
272 IF $39[3] = 49 THEN 284
273 IF $39[4] = 49 THEN 284

0 REM reboot 
274 $3[0] = 48
275 $3[1] = 48
276 IF $9[2] = 48 THEN 278
277 PRINTU"->Reboot\n\r";
278 A = pioclr($8[0]-48);
279 A = pioclr($8[1]-48);
280 W = 3
281 A = reboot
282 WAIT 3;
283 RETURN

0 REM disconnects, disconnect restarts @IDLE
284 ALARM 0
285 IF $9[2] = 48 THEN 287
286 PRINTU "-> Discconnect\n\r"
0 REM if we were paired, then we must unpair.
287 IF $3[0] = 50 THEN 290
288 IF $3[0] = 52 THEN 290
289 GOTO 291;
290 $3[0] = ($3[0] -1)
0 REM 307 A = disconnect 0
0 REM 308 A = disconnect 1
0 REM 309 A = cancel
291 $7 = "0"
292 GOTO 276

0 REM cable mode timeout
293 IF $9[2] = 48 THEN 295
294 PRINTU "Timeout\n\r";
295 ALARM 0;
296 GOTO 265;

0 REM automatic modes code.
0 REM service - slave:
297 A = slave 5;
298 RETURN

0 REM service - master
299 A = strlen $7;
300 IF A > 1 THEN 304
301 A = inquiry 6
302 ALARM 8
303 RETURN

304 A = master $7
0 REM master returns 0 if the connection was succesfull
0 REM or if we are still trying to connect.
305 IF A = 0 THEN 242
306 ALARM 8
307 RETURN

0 REM cable code, if we are not paired check for timeout.
308 IF $3[0] = 50 THEN 314
309 IF $3[0] = 52 THEN 304
310 B = readcnt
311 IF B > 120 THEN 293
312 IF $3[0] = 49 THEN 297
0 REM we are pairing as master,
313 GOTO 301;

314 A = slave -5;
315 RETURN


0 REM this interrupt is launched when there is an incomming
0 REM slave connection
@SLAVE 316
316 IF $9[2] = 48 THEN 318;
317 PRINTU "@SLAVE\n\r";
318 IF $3[0] = 54 THEN 853;
0 REM if we are not on slave mode, then we must ignore slave connections :D
319 IF $3[3] = 50 THEN 342;
320 IF $3[0] > 50 THEN 345;
321 IF $3[0] > 48 THEN 323;
322 GOTO 345

323 A = getconn $7
0 REM if we are on service-slave, and the PIN was a success
0 REM then this is our peer.
324 IF $3[1] = 49 THEN 332
0 REM cable-slave-paired, check address
325 IF $3[0] = 50 THEN 329

0 REM set to paired no matter who cames
326 $3[0] = 50
327 $4 = $7
328 GOTO 332

0 REM check address of the connection and allow
329 $0 = $4
330 B = strcmp $7
331 IF B <> 0 THEN 345

0 REM slave connected
0 REM allow DSR interrupts
0 REM green and blue LEDS on
0 REM read sensors
332 A = nextsns 1
333 B = pioset ($8[1]-48)
334 B = pioset ($8[0]-48)
0 REM set RS232 power to on
335 A = pioset ($8[4]-48)
0 REM DTR set on, +5V
336 A = pioclr ($8[5]-48)
0 REM allow DSR interrupts
337 A = pioirq $14
0 REM connect RS232 to slave
338 IF $9[1]= 49 THEN 347
0 REM 376 A = baud I
339 ALARM 0
340 C = link 1
341 RETURN

342 PRINTU"\n\rCONNECTED\n\r
343 $3[3] = 53
344 GOTO 334

0 REM disconnect and exit
345 A = disconnect 0
346 RETURN

347 C = shell
348 RETURN

@MASTER 349
0 REM successful master connection
349 IF $9[2] = 48 THEN 351
350 PRINTU "@MASTER\n\r";
351 IF $3[0] > 52 THEN 828
0 REM if we are on manual master, then we have some requests
352 IF $3[3] <> 52 THEN 357
353 $3[3] = 54
354 A = pioset ($8[1]-48);
355 A = pioset ($8[0]-48);
356 GOTO 365
0 REM if we are not on master modes, then we must avoid this connection.
357 IF $3[0] > 50 THEN 360;
358 IF $3[0] > 48 THEN 375;
359 IF $3[0] = 48 THEN 375;
360 A = pioset ($8[1]-48);
361 A = pioset ($8[0]-48);
0 REM don't switch state in service mode or manual
362 IF $3[3] = 52 THEN 372
363 IF $3[1] = 49 THEN 365
0 REM set state master paired
364 $3[0] = 52

0 REM read sensors
365 A = nextsns 1
366 A = pioset ($8[4]-48);
0 REM DTR set on
367 A = pioclr ($8[5]-48);
0 REM link
368 A = link 2
0 REM look for disconnect
369 ALARM 5
0 REM allow DSR interrupts
370 A = pioirq $14
371 RETURN

372 PRINTU"\n\rCONNECTED\n\r
373 $3[4] = 54
374 GOTO 365

375 A = disconnect 1
376 RETURN

0 REM $377 RESERVED
377 RESERVED
0 REM inquiry code, only in mode pair_as_master
@INQUIRY 378
378 $377 = $0
379 IF $9[2] = 48 THEN 381
380 PRINTU "@INQUIRY\n\r";
381 IF $3[3] <> 51 THEN 386
382 PRINTU"\n\rFound device: "
383 PRINTU $377
384 ALARM 4
385 RETURN

386 $4 = $377;
387 $377 = $0[13];
388 IF $3[0] <> 51 THEN 391;
0 REM inquiry filter active
389 IF $3[2] = 48 THEN 391;
390 IF $3[2] = 49 THEN 392;
391 RETURN

392 IF $9[2] = 48 THEN 395;
393 PRINTU "found "
394 PRINTU $4
0 REM check name of device
395 $0[0]=0;
396 PRINTV $377;
397 B = strcmp $5;
398 IF B <> 0 THEN 405;

0 REM found one, try to connect, inquiry canceled automaticall
0 REM 447 GOSUB 485;
399 B = master $4;
0 REM if master busy keep stored address in $4, get next
400 IF B = 0 THEN 406;
0 REM master accepted, store address, restart alarms, give it 8 seconds to connect
0 REM corrected by mn
401 $7 = $4;
402 ALARM 8;
0 REM all on to indicate we have one
403 A = pioset ($8[1]-48);
404 A = pioset ($8[0]-48);
405 RETURN

0 REM get next result, give the inq result at least 2 sec time
406 GOSUB 408;
407 RETURN

0 REM blink sub-routine pair as master mode, blue-on green-off and reverse
408 IF J = 1 THEN 413;
409 J = 1;
410 A = pioset ($8[0]-48);
411 A = pioclr ($8[1]-48);
412 RETURN
413 A = pioclr ($8[0]-48);
414 A = pioset ($8[0]-48);
415 J = 0;
416 RETURN;

@CONTROL 417
0 REM remote request for DTR pin on the RS232
417 IF $0[0] < 128 THEN 420
418 A = uartcfg$0[0]
419 RETURN
420 IF $0[0] = 49 THEN 422;
421 A=pioset ($8[5]-48);
422 RETURN;
423 A=pioclr ($8[5]-48);
424 RETURN

@UART 425
425 IF $9[2] = 48 THEN 427
426 PRINTU"@UART\n\r
427 A = uartint
428 $0[0] = 0;
429 TIMEOUTU 5
430 INPUTU $0;
431 A = strlen $0;
432 IF $0[A-3] <> 43 THEN 434
0 REM command line interface active
433 IF $0[A-1] = 43 THEN 436
434 A = uartint;
435 RETURN

436 $3[3] = 49
437 ALARM 1
438 A = enable 3
439 RETURN



0 REM read from uart and echo function
0 REM on line 940 we have the other uart echo function.
0 REM result is on $529
0 REM 528, 2211 RESERVED FOR TEMP
440 RESERVED
441 RESERVED
442 A = 1;
443 $441[0] = 0;
444 UART A;
445 IF $0[0] = 13 THEN 453;
446 $440 = $0;
447 PRINTU $0;
448 $0[0] = 0;
449 PRINTV $441;
450 PRINTV $440;
451 $441 = $0;
452 GOTO 444;
453 RETURN

0 REM command line interface
454 ALARM 0
455 A = uartcfg 136
456 A = pioclr ($8[0]-48);
457 A = pioclr ($8[1]-48);
458 $3[3] = 49
0 REM enable FTP again
459 A = enable 3
460 PRINTU "\r\nAIRcable OS "
461 PRINTU "command line v
462 PRINTU $1
463 PRINTU "\r\nType h to "
464 PRINTU "see the list of "
465 PRINTU "commands";
466 PRINTU "\n\rAIRcable> "
467 GOSUB 700;
468 PRINTU"\n\r

0 REM h: help, l: list,
0 REM n: name, p: pin, b: name filter, g: address filter
0 REM c: class of device, u: uart, d: date,
0 REM s: slave, i: inquiry, m: master, a: mode
0 REM o: obex
0 REM e: exit

0 REM help
469 IF $441[0] = 104 THEN 615;
0 REM info
470 IF $441[0] = 108 THEN 501;
0 REM name
471 IF $441[0] = 110 THEN 630;
0 REM pin
472 IF $441[0] = 112 THEN 640;
0 REM class
473 IF $441[0] = 99 THEN 644;
0 REM uart
474 IF $441[0] = 117 THEN 527;
0 REM date
475 IF $441[0] = 100 THEN 670;
0 REM inquiry
476 IF $441[0] = 105 THEN 757;
0 REM slave
477 IF $441[0] = 115 THEN 782;
0 REM master
478 IF $441[0] = 109 THEN 767;
0 REM obex
479 IF $441[0] = 111 THEN 680;
0 REM modes
480 IF $441[0] = 97 THEN 553;
0 REM exit
481 IF $441[0] = 101 THEN 494;
0 REM name filter
482 IF $441[0] = 98 THEN 660;
0 REM addr filter
483 IF $441[0] = 103 THEN 665;
0 REM hidden debug settings
484 IF $441[0] = 122 THEN 490;
0 REM reboot
485 IF $441[0] = 114 THEN 706;
0 REM relay mode pair
486 IF $441[0] = 106 THEN 802;
0 REM name/pin settings
487 IF $441[0] = 107 THEN 713
488 PRINTU"Command not found
489 GOTO 466;

490 PRINTU"Input settings: "
491 GOSUB 442
492 $9 = $441
493 GOTO 466

0 REM exit code, we end with slave-1 to ensure
0 REM that @SLAVE starts all again, and that
0 REM we start unvisible
494 PRINTU "Bye!!\n\r
495 GOSUB 107;
496 $3[3] = 48;
497 A = slave -1;
498 A = uartint
499 A = zerocnt
500 RETURN

0 REM ----------------------- Listing Code ------------------------------------
501 PRINTU"Command Line v
502 PRINTU $1
503 PRINTU"\n\rName: ";
504 PRINTU $10;
505 PRINTU"\n\rPin: ";
506 PRINTU$11;
507 A = psget 0;
508 PRINTU"\n\rClass: ";
509 PRINTU $0;
510 PRINTU"\n\rBaud Rate: "
511 GOSUB 547
512 PRINTU"\n\rDate: ";
513 A = date $0;
514 PRINTU $0;
515 A = getaddr;
516 PRINTU"\n\rBT Address:
517 PRINTU $0
518 GOSUB 914;
519 PRINTU"\n\rBT Status:
520 PRINTU $39;
521 PRINTU"\n\rName Filter:
522 PRINTU $5;
523 PRINTU"\n\rAddr Filter:
524 PRINTU $6;
525 GOSUB 594
526 GOTO 466;

527 PRINTU"Enter new Baud Ra
528 PRINTU"te divide by 100,
529 PRINTU"or 0 for switches
530 PRINTU": "
531 GOSUB 442
532 $15 = $441
533 PRINTU"\n\r"
534 PRINTU"Parity settings:\n
535 PRINTU"\r0 for none\n\r
536 PRINTU"\r1 for even\n\r
537 PRINTU"\r2 for odd: "
538 GOSUB 700
539 A = $441[0]
540 $22[0] = A
541 PRINTU"\n\rStop Bits settin"
542 PRINTU"gs:\n\r0 for 1 stop
543 PRINTU" bit\n\r1 for 2 stop
544 PRINTU" bits:
545 GOSUB 700
546 GOTO 466

547 IF $15[0] = 48 THEN 551
548 PRINTU $15
549 PRINTU "00 bps
550 RETURN
551 PRINTU "External
552 RETURN

0 REM -------------------------- Modes chooser --------------------------------
0 REM the user should select between
0 REM 0: Manual
0 REM 1: Service Slave
0 REM 2: Service Master
0 REM 3: Cable Slave
0 REM 4: Cable Master
0 REM 5: Master Relay Mode
0 REM Mode:
553 PRINTU"Select new mode\n
554 PRINTU"\r0: Manual\n\r1:
555 PRINTU" Service Slave\n
556 PRINTU"\r2: Service Mast
557 PRINTU"er\n\r3: Cable Sl
558 PRINTU"ave\n\r4: Cable M
559 PRINTU"aster\n\r5: Maste
560 PRINTU"r Relay Mode\n\rM
561 PRINTU"ode: "
562 GOSUB 700;
563 IF $441[0] = 48 THEN 571;
564 IF $441[0] = 49 THEN 574;
565 IF $441[0] = 50 THEN 578;
566 IF $441[0] = 51 THEN 582;
567 IF $441[0] = 52 THEN 586;
568 IF $441[0] = 53 THEN 590;
569 PRINTU"\n\rInvalid Option
570 GOTO 466;

571 $3[0]=48;
572 $3[3]=49;
573 GOTO 466;
574 $3[0] = 49;
575 $3[1] = 49;
576 $3[3] = 48;
577 GOTO 466;
578 $3[0] = 51;
579 $3[1] = 49;
580 $3[3] = 48;
581 GOTO 466;
582 $3[0] = 49;
583 $3[1] = 48;
584 $3[3] = 48;
585 GOTO 466;
586 $3[0] = 51;
587 $3[2] = 49;
588 $3[3] = 48;
589 GOTO 466;
590 $3[0] = 53;
591 $3[1] = 50;
592 $3[2] = 48;
593 GOTO 466

0 REM -------------------------- Listing code ---------------------------------
594 PRINTU "\n\rMode: "
595 IF $3[0] > 52 THEN 613
596 IF $3[0] = 48 THEN 611
597 IF $3[1] = 48 THEN 600
598 PRINTU"Service - "
599 GOTO 601;
600 PRINTU"Cable - "
601 IF $3[0] >= 51 THEN 604;
602 PRINTU"Slave"
603 GOTO 605;
604 PRINTU"Master"
605 IF $3[0] = 50 THEN 609;
606 IF $3[0] = 52 THEN 609;
607 PRINTU"\n\rUnpaired"
608 RETURN
609 PRINTU"\n\rPaired"
610 RETURN
611 PRINTU"Idle"
612 RETURN
613 PRINTU"Relay Mode Master
614 RETURN

0 REM ----------------------- Help code ---------------------------------------
0 REM h: help, l: list,
0 REM n: name, p: pin, k: name/pin settings, 
0 REM b: name filter, g: address filter,
0 REM c: class of device, u: uart, d: date,
0 REM s: slave, i: inquiry, m: master, a: mode
0 REM o: obex, f: obexftp, j: relay mode pair
0 REM e: exit, r: reboot
615 PRINTU"h: help, l: list,\n"
616 PRINTU"\rn: name, p: pin, "
617 PRINTU"k: name/pin setting"
618 PRINTU"s,\n\rb: name filte"
619 PRINTU"r, g: address filte"
620 PRINTU"r,\n\rc: class of d"
621 PRINTU"evice, u: uart, d: "
622 PRINTU"date,\n\rs: slave, "
623 PRINTU"i: inquiry, m: mast"
624 PRINTU"er, a: mode,\n\ro: "
625 PRINTU"obex, f: obexftp, j"
626 PRINTU": relay mode pair,"
627 PRINTU"\n\re: exit, "
628 PRINTU"r: reboot"
629 GOTO 466;

0 REM Name Function
630 PRINTU"New Name: "
631 GOSUB 442;
632 $10 = $441;
633 $0[0] = 0;
634 PRINTV $10;
635 PRINTV " ";
636 A = getuniq $39;
637 PRINTV $39;
638 A = name $0;
639 GOTO 466

0 REM Pin Function
640 PRINTU"New PIN: ";
641 GOSUB 442;
642 $11 = $441;
643 GOTO 466

644 PRINTU"Type the class of "
645 PRINTU"device as xxxx xxx"
646 PRINTU"x: "
647 GOSUB 442
648 $0[0] = 0;
649 PRINTV"@0000 =
650 PRINTV$441;
651 $441 = $0;
652 A = psget 0;
653 $440 =$0
654 $0[0]=0;
655 PRINTV $441;
656 $441 = $440[17]
657 PRINTV $441;
658 A = psset 3
659 GOTO 466

0 REM friendly name filter code
660 PRINTU"Enter the new name"
661 PRINTU" filter: "
662 GOSUB 442
663 $5 = $441
664 GOTO 466;

0 REM addr filter code
665 PRINTU"Enter the new addr"
666 PRINTU"ess filter: "
667 GOSUB 442
668 $6 = $441
669 GOTO 466

0 REM date changing methods
670 PRINTU"Insert new dat
671 PRINTU"e, check the manua
672 PRINTU"l for formating: "
673 GOSUB 442;
674 A = strlen $441
675 IF A <> 16 THEN 678
676 A = setdate $441
677 GOTO 466
678 PRINTU"\n\rInvalid format
679 GOTO 466

0 REM activate Obex/ObexFTP
0 REM 0 Enabled only on command line
0 REM 1 Always enabled
0 REM 2 Always Disabled
680 PRINTU"Obex/ObexFTP setti"
681 PRINTU"ngs:\n\r0: Enabled "
682 PRINTU"only on command li"
683 PRINTU"ne\n\r1: Always Ena"
684 PRINTU"bled\n\r2: Always D"
685 PRINTU"isabled\n\rChoose "
686 PRINTU"Option: "
687 GOSUB 700
688 $9[3] = $441[0]
689 IF $441[0] = 50 THEN 695
690 $0[0] = 0
691 A = psget 6
692 $0[11] = 48
693 A = psset 3
694 GOTO 466
695 $0[0] = 0
696 A = psget 6
697 $0[11] = 54
698 A = psset 3
699 GOTO 466

0 REM one char read function
700 A = 1
701 $441[0] = 0;
702 UART A
703 PRINTU $0
704 $441 = $0
705 RETURN

0 REM reboot code
706 PRINTU"Rebooting, please "
707 PRINTU"do not disconnect "
708 PRINTU"electric power\n\r
709 $3[3] = 48
710 A = reboot
711 WAIT 2
712 RETURN

0 REM name/pin settings:
0 REM 0: Don't add anything,
0 REM 1: Add uniq to the name,
0 REM 2: Add uniq to the name, set pin to uniq.
713 PRINTU"Name/Pin settings:\n"
714 PRINTU"\r0: Don't add anyth"
715 PRINTU"ing,\n\r1: Add uniq "
716 PRINTU"to the name,\n\r2: "
717 PRINTU"Add uniq to the nam"
718 PRINTU"e, set pin to uniq: "
719 GOSUB 700
720 IF $441[0] < 48 THEN 724
721 IF $441[0] > 50 THEN 724
722 $23 = $441
723 GOTO 466

724 PRINTU"Invalid Option\n\r"
725 GOTO 713

0 REM ---------------------- Manual Modes code --------------------------------

726 PRINTU "\n\rThere is BT
727 PRINTU "activity, please
728 PRINTU "wait and try agai
729 PRINTU "n
730 GOTO 466;

0 REM Led STUFF for manual 
731 IF $3[3] = 50 THEN 740
732 IF $3[3] = 51 THEN 745
733 IF $3[3] = 52 THEN 752
0 REM command line has just started?
734 IF $3[3] = 49 THEN 454
735 IF $3[3] = 54 THEN 737
736 RETURN

737 A = pioclr ($8[0]-48);
738 A = pioclr ($8[1]-48);
739 GOTO 466

0 REM slave connecting leds
740 A = pioset ($8[1]-48);
741 A = pioset ($8[0]-48)
742 A = pioclr ($8[0]-48)
743 ALARM 4
744 GOTO 790

0 REM inq leds
745 A = pioset ($8[0]-48);
746 A = pioset ($8[1]-48)
747 A = pioclr ($8[0]-48);
748 A = pioclr ($8[1]-48);
749 ALARM 2
750 GOTO 790


0 REM this line is part of the relay mode
751 A = zerocnt
0 REM master connecting leds
752 A = pioset ($8[0]-48);
753 A = pioset ($8[1]-48)
754 A = pioclr ($8[1]-48);
755 ALARM 4
756 GOTO 790

0 REM inquiry code
0 REM by default we inquiry for 10 seconds
757 GOSUB 914;
758 IF $39[0] = 49 THEN 726
759 PRINTU"Inquirying for
760 PRINTU" 16s. Please wait.
761 B = inquiry 10
762 $3[3] = 51;
763 GOSUB 914;
764 A = zerocnt
765 A = nextsns 0
766 GOTO 745;

0 REM master code
767 GOSUB 914;
768 IF $39[3] = 49 THEN 726
769 PRINTU"Please input "
770 PRINTU"the addr of your "
771 PRINTU"peer:
772 GOSUB 442
773 B = strlen$441
774 IF B<>12 THEN 779
775 $3[3] = 52;
776 B = master $441
777 B = zerocnt
778 GOTO 752

779 PRINTU"Invalid add
780 PRINTU"r, try again.
781 GOTO 466;

0 REM slave code
0 REM manual slave
0 REM by default we open the slave channel for 60 seconds
782 GOSUB 914;
783 IF $39[4] = 49 THEN 726
784 PRINTU"Slave Open for
785 PRINTU" 16s. Please wait.
786 $3[3] = 50
787 A = slave 15
788 A = zerocnt
789 GOTO 740


0 REM timeout for any manual mode, as this part of the code
0 REM will be called as soon as the slave channel is opened
0 REM we check for activity firstly
790 B = readcnt
791 IF B < 16 THEN 801
792 $3[3] = 49
793 ALARM 0
794 A = cancel
795 A = disconnect 0
796 A = disconnect 1
797 A = pioclr ($8[0]-48)
798 A = pioclr ($8[1]-48)
799 A = nextsns 4
800 GOTO 466

801 RETURN

0 REM ---------------------------- RELAY CODE ----------------------------------

0 REM relay mode pair
0 REM Enter the address of your peer: 
802 PRINTU"Enter the address "
803 PRINTU"of your peer: "
804 GOSUB 442;
805 A = strlen $441;
806 IF A = 12 THEN 809;
807 PRINTU"\n\rNot valid peer
808 GOTO 466
809 PRINTU"\n\rTrying to pair
810 $3[0] = 53;
811 $3[3] = 48;
812 $20 = $441
813 A = zerocnt
814 A = master $20
815 GOTO 752

0 REM relay mode alarm handler
0 REM first check for command line
816 IF $3[3] <> 48 THEN 454
817 ALARM 5
818 IF $3[0] = 53 THEN 752
819 B = status
820 IF $3[0] = 54 THEN 208
821 IF B < 1 THEN 206
822 IF $3[0] = 55 THEN 215
823 IF B > 10 THEN 245
824 A = disconnect 0
825 A = disconnect 1
826 $3[0] = 54
827 GOTO 427

828 IF $3[0] = 53 THEN 835
829 A = pioset ($8[1]-48);
830 A = pioset ($8[0]-48);
831 $3[0] = 56
832 A = link 3;
833 ALARM 4
834 RETURN
835 $3[0]=54
836 A = disconnect 1
837 PRINTU"\n\rPair successfull"
838 PRINTU"\n\rPlease choose "
839 PRINTU"which kind of relay "
840 PRINTU"you want:\n\r1: Serv"
841 PRINTU"ice Relay\n\r2: Cabl"
842 PRINTU"e Relay\n\rMode: "
843 ALARM 0
844 GOSUB 700
845 IF $441[0] = 49 THEN 849
846 IF $441[0] = 50 THEN 849
847 PRINTU"\n\rInvalid Option
848 GOTO 838
849 A = $441[0];
850 $3[4] = A;
851 $3[0] = 54;
852 GOTO 466

853 $3[0] = 55
854 GOTO 214

855 B = readcnt;
856 IF $3[4] = 50 THEN 859
857 A = slave 8;
858 RETURN
859 IF B < 120 THEN 857
860 A = slave -8;
861 RETURN


862 IF I = 12 THEN 877
863 IF I = 24 THEN 879
864 IF I = 48 THEN 881
865 IF I = 96 THEN 883
866 IF I = 192 THEN 885
867 IF I = 384 THEN 887
868 IF I = 576 THEN 889
869 IF I = 769 THEN 891
870 IF I = 1152 THEN 893
871 IF I = 2304 THEN 895
872 IF I = 4608 THEN 897
873 IF I = 9216 THEN 899
874 IF I = 13824 THEN 901
0 REM wrong settings for baud rate, we don't have a fixed value, we can't do
0 REM parity and stop bits
875 A = baud I
876 RETURN

877 I = 0
878 GOTO 902
879 I = 1
880 GOTO 902
881 I = 2
882 GOTO 902
883 I = 3
884 GOTO 902
885 I = 4
886 GOTO 902
887 I = 5
888 GOTO 902
889 I = 6
890 GOTO 902
891 I = 7
892 GOTO 902
893 I = 8
894 GOTO 902
895 I = 9
896 GOTO 902
897 I = 10
898 GOTO 902
899 I = 11
900 GOTO 902
901 I = 12
902 IF $22[0] = 49 THEN 905
903 IF $22[0] = 50 THEN 907
904 GOTO 908
905 I = I + 64
906 GOTO 908
907 I = I + 32
908 IF $22[1] = 49 THEN 911
909 GOTO 911
910 I = I + 16
911 I = I + 128
912 A = uartcfg I
913 RETURN

0 REM -------------------------- END RELAY CODE --------------------------------

0 REM convert status to a string
0 REM store the result on $44
914 B = status
915 $39[0] = 0;
916 $39 = "00000";
917 IF B < 10000 THEN 920;
918 $39[0] = 49;
919 B = B -10000;
920 IF B < 1000 THEN 923;
921 $39[1] = 49;
922 B = B -1000;
923 IF B < 100 THEN 926;
924 $39[2] = 49;
925 B = B -100;
926 IF B < 10 THEN 929;
927 $39[3] = 49;
928 B = B -10;
929 IF B < 1 THEN 931;
930 $39[4] = 49;
931 $39[5] = 0;
932 RETURN


