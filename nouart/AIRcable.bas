@ERASE

0 REM this is the base code for all the AIRcable OS products
0 REM we take the AIRcable SMD/Mini as our base device

0 REM moved from UART command line to SPP as default.

0 REM let's reserve the first 30 lines for internal stuff

0 REM $1 is the version of the command line
1 0.6

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

0 REM the numbers that are missing had been removed, camed from UART
0 REM $3[3] = 0 48 means automatic
0 REM $3[3] = 1 49 means manual idle.
0 REM $3[3] = 3 51 manual inq
0 REM $3[3] = 4 52 manual master, connecting
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
0 REM $8[8] COMMAND LINE PIN
0 REM LINE $12 STORES THE DEFAULT VALUE
0 REM z means unitializated
8 z

0 REM Debug settings
0 REM first char is for Z enabled/disabled
0 REM second is for dumping states
0 REM third for Obex/ObexFTP
0 REM 0 48 Enabled only on command line
0 REM 1 49 Always enabled
0 REM 2 50 Always Disabled
9 000

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
0 REM COMMAND LINE PIN
12 K00000005

0 REM PIO_IRQ SETTINGS
0 REM $13 Button + Off Switch + Command Line. For no connections
13 P000010000000
0 REM $14 button + DSR interrupt. While connected
14 P000000000000

0 REM 15 is the settings for the uart when a connection is made
0 REM 0 means read from dip swithces
0 REM any other number is converted to an int.
15 1152

0 REM 16 this is the time that the Obex/ObexFTP will be available after
0 REM boot up
16 120

0 REM on variable we store the baud rate setting.
0 REM this variable is initializated by @SENSOR
0 REM and is not set until a connection is stablished


0 REM $20 is used for relay mode, it stores the master address
20 000000000000

0 REM $21 PIO_IRQ for off mode, only Power Switch measurment.
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
47 IF $9[1] = 48 THEN 49
48 PRINTS "@INIT\n\r";
49 IF $8[0] <> 122 THEN 57
50 $0[0] = 0
51 PRINTV $12
52 FOR E = 0 TO 8
53 GOSUB 40
54 $8[E] = F + 48
55 NEXT E
56 $8[E+1] = 0

57 GOSUB 918

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
0 REM Command line Enable switch
77 A = pioin ($8[8]-48)
78 A = pioset ($8[8]-48)

0 REM set PIO_IRQ to not connected mode
79 A=pioirq $13

0 REM start baud rate
0 REM 80 A = uartcfg 136
0 REM 81 A = nextsns 6
0 REM reset for pairing timeout
82 A = zerocnt
83 IF $9[1] = 48 THEN 85
84 PRINTS "Command Line ready

0 REM state initialize
85 IF $3[0] <> 90 THEN 87
0 REM newly updated BASIC program, goto SLAVE mode
86 $3 = $2;

0 REM init button state
87 W = 0

0 REM blue LED off
88 A = pioclr ($8[0]-48)
89 J = 0

90 $3[3] = 48;

0 REM should go to mode dump
91 IF $9[1] = 48 THEN 93
92 GOSUB 600

0 REM let's start up, green LED on
93 A = pioset ($8[1]-48)

94 K = 1
96 H = 1
0 REM for Unisex V2 switch detector
97 A = pioset $8[7]-48
98 A = pioin $8[7]-48
99 M = 0
100 IF H = 0 THEN 102
101 RESERVED
102 RETURN

0 REM Obex/ObexFTP timing handler
0 REM this code is also called from the command line on exit
103 B = readcnt
104 C = atoi $16
105 IF B < C THEN 112
106 GOSUB 110
107 H = 0
108 GOTO 249

109 IF $9[2] = 49 THEN 111
110 A = disable 3
111 RETURN

112 ALARM 30
113 GOTO 249

@SENSOR 114
0 REM baud rate selector switch implementation
0 REM thresholds (medians) for BAUD rate switch
0 REM AIO0 has voltage, use 1000 (3e8) as analog correction factor
0 REM if it is smaller than this, then switch is set
0 REM voltages: 160, 450, 650, 810, 930, 1020, 1090, >
0 REM switch    111, 110, 101, 100, 011,  010,  001, 000
0 REM baud:    1152,  96, 384, 000, 576,   48,  192, 321
114 IF $15[0] = 48 THEN 119;
0 REM we need to convert from string to integer, because we are on internal
0 REM baud rate, if an error ocurs while converting, then we switch
0 REM to the dip's automatically
115 C = atoi $15;
116 IF C = 0 THEN 119;
117 I = C;
118 GOTO 847
119 C = sensor $0;
120 IF C < 160 THEN 129;
121 IF C < 450 THEN 131;
122 IF C < 650 THEN 133;
123 IF C < 810 THEN 135;
124 IF C < 930 THEN 137;
125 IF C < 1020 THEN 139;
126 IF C < 1090 THEN 141;
127 I = 321;
128 GOTO 118;

129 I = 1152;
130 GOTO 118;
131 I = 96;
132 GOTO 118;
133 I = 384;
134 GOTO 118;
135 I = 1152;
136 GOTO 118;
137 I = 576;
138 GOTO 118;
139 I = 48;
140 GOTO 118;
141 I = 192;
142 GOTO 118;

143 RETURN
0 REM handle button press and DSR, status is $0
@PIO_IRQ 144
144 IF $9[1] = 48 THEN 147;
145 PRINTS "PIO_IRQ\n\r"
146 PRINTS $0

147 A = pioget($8[8]-48);
148 IF A = 1 THEN 150
149 ALARM 1

0 REM press button starts alarm for long press recognition
150 IF $0[$8[2]-48]=48THEN188
0 REM speaciall tratement for Button release on rebooting
151 IF W = 3 THEN 143
0 REM was it a release, now handle it
152 IF W <> 0 THEN 161

0 REM button no pressed, button not released
0 REM when DSR on the RS232 changes
153 IF $0[$8[6]-48]=48THEN156;
154 IF $0[$8[6]-48]=49THEN158;
155 RETURN
0 REM modem control to the other side
156 A = modemctl 0;
157 RETURN
158 A = modemctl 1;
159 RETURN

0 REM released with W == 2, alarm already handled it, exit
160 IF W = 2 THEN 184

0 REM this is a short button press
0 REM if we are on idle mode, then we switch to cable slave
0 REM if we are on service or cable unnconnected then switch master <-> slave
0 REM there is a slight difference between this spec, and the last one
0 REM on the last one any button press while on service did nothing.
161 B = status;
162 IF B < 10000 THEN 164;
163 B = B - 10000;
164 IF B > 0 THEN 193;
165 IF $3[0] = 48 THEN 175;
166 IF $3[0] > 50 THEN 175;

0 REM we were slave, now lets go to master.
167 ALARM 0
168 IF $9[1] = 48 THEN 170;
169 PRINTS "-> pair as master";
170 $3[0] = 51;
171 W = 0;
172 B = zerocnt;
173 A = slave-1;
174 RETURN

0 REM switch to pair as slave
175 ALARM 0
176 IF $9[1] = 48 THEN 178
177 PRINTS "-> pair as slave\n"
178 $3[0] = 49
179 W = 0
180 A = zerocnt;
0 REM cancel inquiries
181 A = cancel
182 ALARM 1
183 RETURN

184 IF $9[1] = 48 THEN 186
185 PRINTS"Handled, ignore\n\r"
186 W = 0
187 RETURN


0 REM button press, recognize it and start ALARM for long press
188 IF $9[1] = 48 THEN 190
189 PRINTS "Button press\n\r"
190 W = 1
191 ALARM 3
192 RETURN

193 IF $9[1] = 48 THEN 195
194 PRINTS "Short, Connected
195 W = 0
196 RETURN

0 REM idle will be called, when the command line ends working
0 REM when the slave connection is closed, and when slave calls
0 REM timeouts, in any of those cases we will let the @ALARM
0 REM handle the slave mode stuff
0 REM idle used for slave connections, pairing or paired
@IDLE 197
197 IF $3[3] <> 48 THEN 773;
198 IF $3[0] > 52 THEN 206;
199 IF W <> 0 THEN 383;
200 IF K = 1 THEN 203;
201 IF K = 2 THEN 204;
0 REM lets trigger the alarm manually
202 GOTO 235;


203 A = slave-1;
204 K = 0;
205 RETURN

206 IF $3[0] = 53 THEN 219
207 IF $3[0] = 54 THEN 213
208 IF $3[0] = 55 THEN 740
209 A = disconnect 1
210 $3[0] = 54
212 B = status
213 IF B > 0 THEN 215
214 GOSUB 840
215 A = pioset ($8[1]-48);
216 A = pioset ($8[0]-48)
217 A = pioclr ($8[0]-48)
218 ALARM 9
219 RETURN

220 A = pioset ($8[0]-48);
221 A = pioset ($8[1]-48)
222 A = pioclr ($8[1]-48);
223 B = status
224 IF B > 1 THEN 226
225 A = master $20
226 ALARM 4
227 RETURN

@PIN_CODE 228
228 IF $9[1] = 48 THEN 230
229 PRINTS "@PIN_CODE"
230 IF $23[0] = 50 THEN 233
231 $0=$11;
232 RETURN
233 A = getuniq $0
234 RETURN

0 REM ALARM code, handles modes stuff, LEDs and long button press 
@ALARM 235
235 IF $9[1] = 48 THEN 237
236 PRINTS "@ALARM\n\r";

0 REM are we on automatic or manual?
237 IF $3[3] <> 48 THEN 726

0 REM check if the command line is accesible or not.

238 A = pioget($8[8]-48);
239 IF A = 1 THEN 245

0 REM to show the user the command line can be accessed, we do a long blink
240 A = pioset($8[1]-48);
241 A = pioset($8[0]-48)
242 A = pioclr($8[0]-48);
243 A = slave 5
244 RETURN

0 REM handle button press first of all.
245 IF W = 1 THEN 283

0 REM should go to mode dumping
246 IF $9[1] = 48 THEN 248
247 GOSUB 600

248 IF H = 1 THEN 103

249 IF $3[0] > 52 THEN 801

0 REM now the led stuff, and finally we handle the state.
0 REM firstly see if we are connected, then do what you need
250 B = status;
251 IF B < 10000 THEN 253;
252 B = B - 10000;
253 IF B > 0 THEN 255;
254 GOTO 261
0 REM ensure the leds are on
255 A = pioset ($8[0]-48);
256 A = pioset ($8[1]-48);
257 ALARM 5
258 RETURN


0 REM we are on automatic.
0 REM are we on automatic - manual?
261 IF $3[0] = 48 THEN 278

0 REM LED SCHEMA:
0 REM CABLE 	SLAVE 	1 fast blink
0 REM SERVICE 	SLAVE 	2 fast blink
0 REM CABLE	MASTER 	3 fast blink
0 REM SERVICE	MASTER 	4 fast blink
262 A = pioset ($8[1]-48);
263 A = pioset ($8[0]-48)
264 A = pioclr ($8[0]-48);
0 REM are we on master or slave?
265 IF $3[0] > 50 THEN 270
0 REM ok we are on slave
0 REM CABLE 	SLAVE 1 fast BLINK
0 REM SERVICE 	SLAVE 2 fast BLINK

0 REM now are we on cable or service?
266 IF $3[1] = 48 THEN 323
0 REM service slave
267 A = pioset ($8[0]-48)
268 A = pioclr ($8[0]-48);
269 GOTO 310;

0 REM we are on master modes
270 FOR B = 0 TO 2
271 A = pioset ($8[0]-48)
272 A = pioclr ($8[0]-48
273 NEXT B
274 IF $3[1] = 48 THEN 323;
275 A = pioset ($8[0]-48)
276 A = pioclr ($8[0]-48);
277 GOTO 312;


0 REM manual idle code, this is the only mode that ends here.
278 B = pioset ($8[1]-48);
279 B = pioclr ($8[0]-48);
280 A = slave-1;
281 K = 2
282 RETURN

0 REM this is a long button press, we have stuff to do
0 REM if we are connected, then we disconnect and reboot to unpaired
0 REM if we aren't then we must reboot and go to idle mode.
283 GOSUB 899;
284 W = 2
285 IF $39[3] = 49 THEN 297
286 IF $39[4] = 49 THEN 297

0 REM reboot 
287 $3[0] = 48
288 $3[1] = 48
289 IF $9[1] = 48 THEN 291
290 PRINTS"->Reboot\n\r";
291 A = pioclr($8[0]-48);
292 A = pioclr($8[1]-48);
293 W = 3
294 A = reboot
295 WAIT 3;
296 RETURN

0 REM disconnects, disconnect restarts @IDLE
297 ALARM 0
298 IF $9[1] = 48 THEN 300
299 PRINTS "-> Discconnect\n\r"
0 REM if we were paired, then we must unpair.
300 IF $3[0] = 50 THEN 303
301 IF $3[0] = 52 THEN 303
302 GOTO 304;
303 $3[0] = ($3[0] -1)
0 REM 307 A = disconnect 0
0 REM 308 A = disconnect 1
0 REM 309 A = cancel
304 $7 = "0"
305 GOTO 289

0 REM cable mode timeout
306 IF $9[1] = 48 THEN 308
307 PRINTS "Timeout\n\r";
308 ALARM 0;
309 GOTO 278;

0 REM automatic modes code.
0 REM service - slave:
310 A = slave 5;
311 RETURN

0 REM service - master
312 A = strlen $7;
313 IF A > 1 THEN 317
314 A = inquiry 6
315 ALARM 8
316 RETURN

317 A = master $7
318 IF $3[1] = 48 THEN 320
319 $7 = "0"
0 REM master returns 0 if the connection was succesfull
0 REM or if we are still trying to connect.
320 IF A = 0 THEN 255
321 ALARM 8
322 RETURN

0 REM cable code, if we are not paired check for timeout.
323 IF $3[0] = 50 THEN 329
324 IF $3[0] = 52 THEN 317
325 B = readcnt
326 IF B > 120 THEN 306
327 IF $3[0] = 49 THEN 310
0 REM we are pairing as master,
328 GOTO 314;

329 A = slave -5;
330 RETURN


0 REM this interrupt is launched when there is an incomming
0 REM slave connection
@SLAVE 331
331 A = pioget($8[8]-48);
332 IF A <> 1 THEN 361;
333 IF $9[1] = 48 THEN 335;
334 PRINTS "@SLAVE\n\r";
335 IF $3[0] = 54 THEN 838;
0 REM if we are not on slave mode, then we must ignore slave connections :D

336 IF $3[0] > 50 THEN 357;
337 IF $3[0] > 48 THEN 339;
338 GOTO 357

339 A = getconn $7
0 REM if we are on service-slave, and the PIN was a success
0 REM then this is our peer.
340 IF $3[1] = 49 THEN 348
0 REM cable-slave-paired, check address
341 IF $3[0] = 50 THEN 345

0 REM set to paired no matter who cames
342 $3[0] = 50
343 $4 = $7
344 GOTO 348

0 REM check address of the connection and allow
345 $0 = $4
346 B = strcmp $7
347 IF B <> 0 THEN 357

0 REM slave connected
0 REM set interrupts to connected mode.
0 REM green and blue LEDS on
0 REM read sensors
348 A = nextsns 1
349 B = pioset ($8[1]-48)
350 B = pioset ($8[0]-48)
0 REM set RS232 power to on
351 A = pioset ($8[4]-48)
0 REM DTR set on, +5V
352 A = pioclr ($8[5]-48)
0 REM set interrupts to connected mode.
353 A = pioirq $14
0 REM connect RS232 to slave
354 ALARM 0
355 C = link 1
356 RETURN

0 REM disconnect and exit
357 A = disconnect 0
358 RETURN

0 REM the user has selected to enabled the command line.
0 REM does he really want to get into?
361 TIMEOUTS 5
362 INPUTS $283
363 A = strlen $283
364 IF A < 3 THEN 333
365 IF $283[A-3] <> 43 THEN 333
366 IF $283[A-1] <> 43 THEN 333
367 GOTO 461

@MASTER 368
0 REM successful master connection
368 IF $9[1] = 48 THEN 370
369 PRINTS "@MASTER\n\r";
370 IF $3[0] > 52 THEN 813
0 REM if we are on manual master, then we have some requests
371 IF $3[3] <> 52 THEN 376
372 $3[3] = 54
373 A = pioset ($8[1]-48);
374 A = pioset ($8[0]-48);
375 GOTO 384
0 REM if we are not on master modes, then we must avoid this connection.
376 IF $3[0] > 50 THEN 379;
377 IF $3[0] > 48 THEN 394;
378 IF $3[0] = 48 THEN 394;
379 A = pioset ($8[1]-48);
380 A = pioset ($8[0]-48);
0 REM don't switch state in service mode or manual
381 IF $3[3] = 52 THEN 391
382 IF $3[1] = 49 THEN 384
0 REM set state master paired
383 $3[0] = 52

0 REM read sensors
384 A = nextsns 1
385 A = pioset ($8[4]-48);
0 REM DTR set on
386 A = pioclr ($8[5]-48);
0 REM link
387 A = link 2
0 REM look for disconnect
388 ALARM 5
0 REM allow DSR interrupts
389 A = pioirq $14
390 RETURN

391 PRINTS"\n\rCONNECTED\n\r
392 $3[4] = 54
393 GOTO 384

394 A = disconnect 1
395 RETURN

0 REM $396 RESERVED
396 RESERVED
0 REM inquiry code, only in mode pair_as_master
@INQUIRY 397
397 $396 = $0
398 IF $9[1] = 48 THEN 400
399 PRINTS "@INQUIRY\n\r";
400 IF $3[3] <> 51 THEN 405
401 PRINTS"\n\rFound device: "
402 PRINTS $396
403 ALARM 4
404 RETURN

405 $4 = $396;
406 $396 = $0[13];
407 IF $3[0] <> 51 THEN 410;
0 REM inquiry filter active
408 IF $3[2] = 48 THEN 410;
409 IF $3[2] = 49 THEN 411;
410 RETURN

411 IF $9[1] = 48 THEN 414;
412 PRINTS "found "
413 PRINTS $4
0 REM check name of device
414 $0[0]=0;
415 PRINTV $396;
416 B = strcmp $5;
417 IF B <> 0 THEN 424;

0 REM found one, try to connect, inquiry canceled automaticall
0 REM 447 GOSUB 485;
418 B = master $4;
0 REM if master busy keep stored address in $4, get next
419 IF B = 0 THEN 425;
0 REM master accepted, store address, restart alarms, give it 8 seconds to connect
0 REM corrected by mn
420 $7 = $4;
421 ALARM 8;
0 REM all on to indicate we have one
422 A = pioset ($8[1]-48);
423 A = pioset ($8[0]-48);
424 RETURN

0 REM get next result, give the inq result at least 2 sec time
425 GOSUB 427;
426 RETURN

0 REM blink sub-routine pair as master mode, blue-on green-off and reverse
427 IF J = 1 THEN 432;
428 J = 1;
429 A = pioset ($8[0]-48);
430 A = pioclr ($8[1]-48);
431 RETURN
432 A = pioclr ($8[0]-48);
433 A = pioset ($8[0]-48);
434 J = 0;
435 RETURN;

@CONTROL 436
0 REM remote request for DTR pin on the RS232
436 IF $0[0] < 128 THEN 439
437 A = uartcfg$0[0]
438 RETURN
439 IF $0[0] = 49 THEN 441;
440 A=pioset ($8[5]-48);
441 RETURN;
442 A=pioclr ($8[5]-48);
443 RETURN

@UART 444
444 IF $9[1] = 48 THEN 437
445 PRINTS"@UART\n\r
446 $0[0] = 0;
447 TIMEOUTU 5
448 INPUTU $0;
449 A = strlen $0;
450 IF $0[A-3] <> 43 THEN 444
0 REM command line interface active
451 IF $0[A-1] = 43 THEN 453

452 RETURN

453 $3[3] = 49
454 ALARM 1
455 A = enable 3
456 RETURN



0 REM read from uart and echo function
0 REM on line 940 we have the other uart echo function.
0 REM result is on $529
0 REM 457 RESERVED FOR TEMP
457 RESERVED
458 $457[0] = 0;
459 INPUTS $457
460 RETURN

0 REM command line interface
461 ALARM 0
462 A = pioirq $14
463 A = pioclr ($8[0]-48);
464 A = pioclr ($8[1]-48);
465 $3[3] = 49
0 REM enable FTP again
466 A = enable 3
467 PRINTS "\r\nAIRcable OS "
468 PRINTS "command line v
469 PRINTS $1
470 PRINTS "\r\nType h to "
471 PRINTS "see the list of "
472 PRINTS "commands";
473 PRINTS "\n\rAIRcable> "
474 GOSUB 458;
475 PRINTS"\n\r

0 REM h: help, l: list,
0 REM n: name, p: pin, b: name filter, g: address filter
0 REM c: class of device, u: uart, d: date,
0 REM s: slave, i: inquiry, m: master, a: mode
0 REM o: obex
0 REM e: exit

0 REM help
476 IF $457[0] = 104 THEN 621;
0 REM info
477 IF $457[0] = 108 THEN 510;
0 REM name
478 IF $457[0] = 110 THEN 636;
0 REM pin
479 IF $457[0] = 112 THEN 641;
0 REM class
480 IF $457[0] = 99 THEN 645;
0 REM uart
481 IF $457[0] = 117 THEN 533;
0 REM date
482 IF $457[0] = 100 THEN 671;
0 REM inquiry
483 IF $457[0] = 105 THEN 746;
0 REM shell
484 IF $457[0] = 115 THEN 927;
0 REM master
0 REM 485 IF $457[0] = 109 THEN 757;
0 REM obex
486 IF $457[0] = 111 THEN 681;
0 REM modes
487 IF $457[0] = 97 THEN 559;
0 REM exit
488 IF $457[0] = 101 THEN 501;
0 REM name filter
489 IF $457[0] = 98 THEN 661;
0 REM addr filter
490 IF $457[0] = 103 THEN 666;
0 REM hidden debug settings
491 IF $457[0] = 122 THEN 497;
0 REM reboot
492 IF $457[0] = 114 THEN 701;
0 REM relay mode pair
493 IF $457[0] = 106 THEN 785;
0 REM name/pin settings
494 IF $457[0] = 107 THEN 708
495 PRINTS"Command not found
496 GOTO 473;

497 PRINTS"Input settings: "
498 GOSUB 458
499 $9 = $457
500 GOTO 473

0 REM exit code, we end with slave-1 to ensure
0 REM that @SLAVE starts all again, and that
0 REM we start unvisible
501 PRINTS "Bye!!\n\r
502 GOSUB 109;
503 $3[3] = 48;
504 A = slave -1;
505 A = disconnect 0
506 A = zerocnt
507 A = pioset($8[1]-48);
508 M = 0
509 RETURN

0 REM ----------------------- Listing Code ------------------------------------
510 PRINTS"Command Line v
511 PRINTS $1
512 PRINTS"\n\rName: ";
513 PRINTS $10;
514 PRINTS"\n\rPin: ";
515 PRINTS$11;
516 A = psget 0;
517 PRINTS"\n\rClass: ";
518 PRINTS $0;
519 PRINTS"\n\rBaud Rate: "
520 GOSUB 553
521 PRINTS"\n\rDate: ";
522 A = date $0;
523 PRINTS $0;
524 A = getaddr;
525 PRINTS"\n\rBT Address:
526 PRINTS $0
527 PRINTS"\n\rName Filter:
528 PRINTS $5;
529 PRINTS"\n\rAddr Filter:
530 PRINTS $6;
531 GOSUB 600
532 GOTO 473;

533 PRINTS"Enter new Baud Ra
534 PRINTS"te divide by 100,
535 PRINTS"or 0 for switches
536 PRINTS": "
537 GOSUB 458
538 $15 = $457
539 PRINTS"\n\r"
540 PRINTS"Parity settings:\n
541 PRINTS"\r0 for none\n\r
542 PRINTS"\r1 for even\n\r
543 PRINTS"\r2 for odd: "
544 GOSUB 458
545 A = $457[0]
546 $22[0] = A
547 PRINTS"\n\rStop Bits settin"
548 PRINTS"gs:\n\r0 for 1 stop
549 PRINTS" bit\n\r1 for 2 stop
550 PRINTS" bits:
551 GOSUB 458
552 GOTO 473

553 IF $15[0] = 48 THEN 557
554 PRINTS $15
555 PRINTS "00 bps
556 RETURN
557 PRINTS "External
558 RETURN

0 REM -------------------------- Modes chooser --------------------------------
0 REM the user should select between
0 REM 0: Manual
0 REM 1: Service Slave
0 REM 2: Service Master
0 REM 3: Cable Slave
0 REM 4: Cable Master
0 REM 5: Master Relay Mode
0 REM Mode:
559 PRINTS"Select new mode\n
560 PRINTS"\r0: Manual\n\r1:
561 PRINTS" Service Slave\n
562 PRINTS"\r2: Service Mast
563 PRINTS"er\n\r3: Cable Sl
564 PRINTS"ave\n\r4: Cable M
565 PRINTS"aster\n\r5: Maste
566 PRINTS"r Relay Mode\n\rM
567 PRINTS"ode: "
568 GOSUB 458;
569 IF $457[0] = 48 THEN 577;
570 IF $457[0] = 49 THEN 580;
571 IF $457[0] = 50 THEN 584;
572 IF $457[0] = 51 THEN 588;
573 IF $457[0] = 52 THEN 592;
574 IF $457[0] = 53 THEN 596;
575 PRINTS"\n\rInvalid Option
576 GOTO 473;

577 $3[0]=48;
578 $3[3]=49;
579 GOTO 473;
580 $3[0] = 49;
581 $3[1] = 49;
582 $3[3] = 48;
583 GOTO 473;
584 $3[0] = 51;
585 $3[1] = 49;
586 $3[3] = 48;
587 GOTO 473;
588 $3[0] = 49;
589 $3[1] = 48;
590 $3[3] = 48;
591 GOTO 473;
592 $3[0] = 51;
593 $3[2] = 49;
594 $3[3] = 48;
595 GOTO 473;
596 $3[0] = 53;
597 $3[1] = 50;
598 $3[2] = 48;
599 GOTO 473

0 REM -------------------------- Listing code ---------------------------------
600 PRINTS "\n\rMode: "
601 IF $3[0] > 52 THEN 619
602 IF $3[0] = 48 THEN 617
603 IF $3[1] = 48 THEN 606
604 PRINTS"Service - "
605 GOTO 607;
606 PRINTS"Cable - "
607 IF $3[0] >= 51 THEN 610;
608 PRINTS"Slave"
609 GOTO 611;
610 PRINTS"Master"
611 IF $3[0] = 50 THEN 615;
612 IF $3[0] = 52 THEN 615;
613 PRINTS"\n\rUnpaired"
614 RETURN
615 PRINTS"\n\rPaired"
616 RETURN
617 PRINTS"Idle"
618 RETURN
619 PRINTS"Relay Mode Master
620 RETURN

0 REM ----------------------- Help code ---------------------------------------
0 REM h: help, l: list,
0 REM n: name, p: pin, k: name/pin settings, 
0 REM b: name filter, g: address filter,
0 REM c: class of device, u: uart, d: date,
0 REM i: inquiry, m: master, a: mode,
0 REM o: obex, f: obexftp, j: relay mode pair,
0 REM e: exit, r: reboot, s: shell,
0 REM q: PIO settings
621 PRINTS"h: help, l: list,\n"
622 PRINTS"\rn: name, p: pin, "
623 PRINTS"k: name/pin setting"
624 PRINTS"s,\n\rb: name filte"
625 PRINTS"r, g: address filte"
626 PRINTS"r,\n\rc: class of d"
627 PRINTS"evice, u: uart, d: "
628 PRINTS"date,\n\ri: inquiry"
629 PRINTS", m: master, a: mode"
630 PRINTS",\n\ro: obex, f: obe"
631 PRINTS"xftp, j: relay mode "
632 PRINTS"pair,\n\re: exit, r:"
633 PRINTS" reboot, s: shell,\n"
634 PRINTS"\rq: PIO settings"
635 GOTO 473;

0 REM Name Function
636 PRINTS"New Name: "
637 GOSUB 458;
638 $10 = $457;
639 GOSUB 918
640 GOTO 473

0 REM Pin Function
641 PRINTS"New PIN: ";
642 GOSUB 458;
643 $11 = $457;
644 GOTO 473

645 PRINTS"Type the class of "
646 PRINTS"device as xxxx xxx"
647 PRINTS"x: "
648 GOSUB 458
649 $0[0] = 0;
650 PRINTV"@0000 =
651 PRINTV$457;
652 $457 = $0;
653 A = psget 0;
654 $455 =$0
655 $0[0]=0;
656 PRINTV $457;
657 $457 = $455[17]
658 PRINTV $457;
659 A = psset 3
660 GOTO 473

0 REM friendly name filter code
661 PRINTS"Enter the new name"
662 PRINTS" filter: "
663 GOSUB 458
664 $5 = $457
665 GOTO 473;

0 REM addr filter code
666 PRINTS"Enter the new addr"
667 PRINTS"ess filter: "
668 GOSUB 458
669 $6 = $457
670 GOTO 473

0 REM date changing methods
671 PRINTS"Insert new dat
672 PRINTS"e, check the manua
673 PRINTS"l for formating: "
674 GOSUB 458;
675 A = strlen $457
676 IF A <> 16 THEN 679
677 A = setdate $457
678 GOTO 473
679 PRINTS"\n\rInvalid format
680 GOTO 473

0 REM activate Obex/ObexFTP
0 REM 0 Enabled only on command line
0 REM 1 Always enabled
0 REM 2 Always Disabled
681 PRINTS"Obex/ObexFTP setti"
682 PRINTS"ngs:\n\r0: Enabled "
683 PRINTS"only on command li"
684 PRINTS"ne\n\r1: Always Ena"
685 PRINTS"bled\n\r2: Always D"
686 PRINTS"isabled\n\rChoose "
687 PRINTS"Option: "
688 GOSUB 458
689 $9[2] = $457[0]
690 IF $457[0] = 50 THEN 696
691 $0[0] = 0
692 A = psget 6
693 $0[11] = 48
694 A = psset 3
695 GOTO 473
696 $0[0] = 0
697 A = psget 6
698 $0[11] = 54
699 A = psset 3
700 GOTO 473

0 REM reboot code
701 PRINTS"Rebooting, please "
702 PRINTS"do not disconnect "
703 PRINTS"electric power\n\r
704 $3[3] = 48
705 A = reboot
706 WAIT 2
707 RETURN

0 REM name/pin settings:
0 REM 0: Don't add anything,
0 REM 1: Add uniq to the name,
0 REM 2: Add uniq to the name, set pin to uniq.
708 PRINTS"Name/Pin settings:\n"
709 PRINTS"\r0: Don't add anyth"
710 PRINTS"ing,\n\r1: Add uniq "
711 PRINTS"to the name,\n\r2: "
712 PRINTS"Add uniq to the nam"
713 PRINTS"e, set pin to uniq: "
714 GOSUB 458
715 IF $457[0] < 48 THEN 719
716 IF $457[0] > 50 THEN 719
717 $23 = $457
718 GOTO 473

719 PRINTS"Invalid Option\n\r"
720 GOTO 708

0 REM ---------------------- Manual Modes code --------------------------------

721 PRINTS "\n\rThere is BT
722 PRINTS "activity, please
723 PRINTS "wait and try agai
724 PRINTS "n
725 GOTO 473;

0 REM Led STUFF for manual 
726 IF $3[3] = 51 THEN 734
727 IF $3[3] = 52 THEN 741
0 REM command line has just started?
728 IF $3[3] = 49 THEN 461
729 IF $3[3] = 54 THEN 731
730 RETURN

731 A = pioclr ($8[0]-48);
732 A = pioclr ($8[1]-48);
733 GOTO 473


0 REM inq leds
734 A = pioset ($8[0]-48);
735 A = pioset ($8[1]-48)
736 A = pioclr ($8[0]-48);
737 A = pioclr ($8[1]-48);
738 ALARM 20
739 GOTO 773


0 REM this line is part of the relay mode
740 A = zerocnt
0 REM master connecting leds
741 A = pioset ($8[0]-48);
742 A = pioset ($8[1]-48)
743 A = pioclr ($8[1]-48);
744 ALARM 4
745 GOTO 773

0 REM inquiry code
0 REM by default we inquiry for 10 seconds
746 GOSUB 899;
747 IF $39[0] = 49 THEN 721
748 PRINTS"Inquirying for
749 PRINTS" 16s. Please wait.
0 REM 750 A = nextsns 30
751 B = inquiry 10
752 $3[5] = $3[0];
753 $3[3] = 51;
754 GOSUB 899;
755 A = zerocnt
756 GOTO 734;

0 REM master code
757 GOSUB 899;
758 IF $39[3] = 49 THEN 721
759 PRINTS"Please input "
760 PRINTS"the addr of your "
761 PRINTS"peer:
762 GOSUB 458
763 B = strlen$457
764 IF B<>12 THEN 770
765 $3[5] = $3[3]
766 B = master $457
767 B = zerocnt
768 $3[3] = 52;
769 GOTO 741

770 PRINTS"Invalid add
771 PRINTS"r, try again.
772 GOTO 473;

0 REM timeout for any manual mode, as this part of the code
0 REM will be called as soon as the slave channel is opened
0 REM we check for activity firstly
773 B = readcnt
774 IF B < 16 THEN 784
775 $3[3] = 49
776 ALARM 0
777 A = cancel
778 $3[0] = $3[5]
779 A = disconnect 1
780 A = pioclr ($8[0]-48)
781 A = pioclr ($8[1]-48)
782 GOTO 473

784 RETURN

0 REM ---------------------------- RELAY CODE ----------------------------------

0 REM relay mode pair
0 REM Enter the address of your peer: 
785 PRINTS"Enter the address "
786 PRINTS"of your peer: "
787 GOSUB 458;
788 A = strlen $457;
789 IF A = 12 THEN 792;
790 PRINTS"\n\rNot valid peer
791 GOTO 473
792 PRINTS"\n\rTrying to pair
793 $3[5] = $3[0];
794 $3[3] = 48;
795 $20 = $457
796 A = zerocnt
797 A = master $20
0 REM 798 A = nextsns 30
799 $3[0] = 53
800 GOTO 741

0 REM relay mode alarm handler
0 REM first check for command line
801 IF $3[3] <> 48 THEN 461
802 ALARM 5
803 IF $3[0] = 53 THEN 741
804 B = status
805 IF $3[0] = 54 THEN 213
806 IF B < 1 THEN 209
807 IF $3[0] = 55 THEN 220
808 IF B > 10 THEN 258
809 A = disconnect 0
810 A = disconnect 1
811 $3[0] = 54
812 GOTO 444

813 IF $3[0] = 53 THEN 820
814 A = pioset ($8[1]-48);
815 A = pioset ($8[0]-48);
816 $3[0] = 56
817 A = link 3;
818 ALARM 4
819 RETURN
820 $3[0]=54
821 A = disconnect 1
822 PRINTS"\n\rPair successfull"
823 PRINTS"\n\rPlease choose "
824 PRINTS"which kind of relay "
825 PRINTS"you want:\n\r1: Serv"
826 PRINTS"ice Relay\n\r2: Cabl"
827 PRINTS"e Relay\n\rMode: "
828 ALARM 0
829 GOSUB 458
830 IF $457[0] = 49 THEN 834
831 IF $457[0] = 50 THEN 834
832 PRINTS"\n\rInvalid Option
833 GOTO 823
834 A = $457[0];
835 $3[4] = A;
836 $3[0] = 54;
837 GOTO 473

838 $3[0] = 55
839 GOTO 219

840 B = readcnt;
841 IF $3[4] = 50 THEN 844
842 A = slave 8;
843 RETURN
844 IF B < 120 THEN 842
845 A = slave -8;
846 RETURN


847 IF I = 12 THEN 862
848 IF I = 24 THEN 864
849 IF I = 48 THEN 866
850 IF I = 96 THEN 868
851 IF I = 192 THEN 870
852 IF I = 384 THEN 872
853 IF I = 576 THEN 874
854 IF I = 769 THEN 876
855 IF I = 1152 THEN 878
856 IF I = 2304 THEN 880
857 IF I = 4608 THEN 882
858 IF I = 9216 THEN 884
859 IF I = 13824 THEN 886
0 REM wrong settings for baud rate, we don't have a fixed value, we can't do
0 REM parity and stop bits
860 A = baud I
861 RETURN

862 I = 0
863 GOTO 887
864 I = 1
865 GOTO 887
866 I = 2
867 GOTO 887
868 I = 3
869 GOTO 887
870 I = 4
871 GOTO 887
872 I = 5
873 GOTO 887
874 I = 6
875 GOTO 887
876 I = 7
877 GOTO 887
878 I = 8
879 GOTO 887
880 I = 9
881 GOTO 887
882 I = 10
883 GOTO 887
884 I = 11
885 GOTO 887
886 I = 12
887 IF $22[0] = 49 THEN 890
888 IF $22[0] = 50 THEN 892
889 GOTO 893
890 I = I + 64
891 GOTO 893
892 I = I + 32
893 IF $22[1] = 49 THEN 896
894 GOTO 896
895 I = I + 16
896 I = I + 128
897 A = uartcfg I
898 RETURN

0 REM -------------------------- END RELAY CODE --------------------------------

0 REM convert status to a string
0 REM store the result on $44
899 B = status
900 $39[0] = 0;
901 $39 = "00000";
902 IF B < 10000 THEN 905;
903 $39[0] = 49;
904 B = B -10000;
905 IF B < 1000 THEN 908;
906 $39[1] = 49;
907 B = B -1000;
908 IF B < 100 THEN 911;
909 $39[2] = 49;
910 B = B -100;
911 IF B < 10 THEN 914;
912 $39[3] = 49;
913 B = B -10;
914 IF B < 1 THEN 916;
915 $39[4] = 49;
916 $39[5] = 0;
917 RETURN

918 $0[0] = 0;
919 PRINTV $10;
920 IF $23[0] = 48 THEN 924
921 PRINTV " ";
922 A = getuniq $39;
923 PRINTV $39;
924 A = name $0;
925 RETURN

926 $3[0] = 48
927 A = shell
928 RETURN

