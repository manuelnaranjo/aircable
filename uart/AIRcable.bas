@ERASE

0 REM this is the base code for all the AIRcable OS products
0 REM we take the AIRcable SMD/Mini as our base device

0 REM let's reserve the first 30 lines for internal stuff

0 REM $1 is the version of the command line
1 0.11UART

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

0 REM $3[1] = 0 48 cable mode
0 REM $3[1] = 1 49 service mode

0 REM $3[2] = 0 48 device found / module paired
0 REM $3[2] = 1 49 inquiry needed

0 REM $3[3] = 0 48 means automatic
0 REM $3[3] = 1 49 means manual idle.
0 REM $3[3] = 2 50 manual slave, connecting
0 REM $3[3] = 3 51 manual inq
0 REM $3[3] = 4 52 manual master, connecting
0 REM $3[3] = 5 53 manual slave, connected
0 REM $3[3] = 6 54 manual master, connected

0 REM if var K = 1 then we must do a slave-1

0 REM $3[5] service master counter
3 Z

0 REM $4 IS RESERVED FOR PAIRED ADDR
4 0

0 REM $5 stores the name of the devices we only want during inquiry
5 AIR

0 REM $6 stores the filter address we filter on during inquiry
6 0050C2

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
23 1

0 REM 24 service master counter
24 0

0 REM part of @MASTER
37 $24="5"
38 RETURN

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
0 REM next two lines are changed by serialOS and
0 REM AIRserial4 code, so update
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
90 GOSUB 598

0 REM let's start up, green LED on
91 A = pioset ($8[1]-48)

92 K = 1
0 REM now we go to @IDLE, and then we get into the @ALARM
93 A = uartint
94 H = 1
0 REM for Unisex V2 switch detector
95 A = pioset ($8[7]-48)
96 A = pioin ($8[7]-48)
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
106 GOTO 226

107 IF $9[3] = 49 THEN 109
108 A = disable 3
109 RETURN

110 ALARM 30
111 GOTO 226

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
116 GOTO 867
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
0 REM Horrible HACK, this piece of code, must come back once the renumbering 
0 REM tool is corrected
0 REM 148 IF $0[$8[6]-48]=48THEN151;
0 REM 149 IF $0[$8[6]-48]=49THEN153;
148 GOTO 940
150 RETURN
0 REM modem control to the other side
151 A = modemctl 1;
152 RETURN
153 A = modemctl 0;
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
192 IF $3[3] <> 48 THEN 846;
194 IF W <> 0 THEN 366;
195 IF K = 1 THEN 200;
196 IF K = 2 THEN 201;
0 REM turn off DTR start alarm
197 A = pioset($8[5]-48);
198 GOTO 220;


200 A = slave-1;
201 K = 0;
202 RETURN

@PIN_CODE 210
210 IF $9[2] = 48 THEN 212
211 PRINTU "@PIN_CODE"
212 IF $23[0] = 50 THEN 215
213 $0=$11;
214 RETURN
215 A = getuniq $0
216 RETURN

0 REM ALARM code, handles modes stuff, LEDs and long button press 
@ALARM 220
220 IF $9[2] = 48 THEN 222
221 PRINTU "@ALARM\n\r";


0 REM handle button press first of all.
222 IF W = 1 THEN 270


0 REM should go to mode dumping
223 IF $9[2] = 48 THEN 225
224 GOSUB 598

225 IF H = 1 THEN 101

0 REM now the led stuff, and finally we handle the state.
0 REM firstly see if we are connected, then do what you need
226 B = status;
227 IF B < 10000 THEN 229;
228 B = B - 10000;
229 IF B > 0 THEN 242;
0 REM turn off DTR
230 A = pioset($8[5]-48);
231 GOTO 246
0 REM ensure the leds are on
242 A = pioset ($8[0]-48);
243 A = pioset ($8[1]-48);
244 ALARM 5
245 RETURN

246 A = uartcfg 136
0 REM are we on automatic or manual?
247 IF $3[3] <> 48 THEN 735
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
253 IF $3[1] = 48 THEN 310
0 REM service slave
254 A = pioset ($8[0]-48)
255 A = pioclr ($8[0]-48);
256 GOTO 297;

0 REM we are on master modes
257 FOR B = 0 TO 2
258 A = pioset ($8[0]-48)
259 A = pioclr ($8[0]-48)
260 NEXT B
261 IF $3[1] = 48 THEN 310;
262 A = pioset ($8[0]-48)
263 A = pioclr ($8[0]-48);
264 GOTO 299;


0 REM manual idle code, this is the only mode that ends here.
265 B = pioset ($8[1]-48);
266 B = pioclr ($8[0]-48);
267 A = slave-1;
268 K = 2
269 RETURN

0 REM this is a long button press, we have stuff to do
0 REM if we are connected, then we disconnect and reboot to unpaired
0 REM if we aren't then we must reboot and go to idle mode.
270 GOSUB 919;
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
297 A = slave 20;
298 GOTO 302

0 REM service - master
299 B = $24[0] 
300 IF B > 48 THEN 304
0 REM 300 IF A > 1 THEN 304
301 A = inquiry 6
302 ALARM 8
303 RETURN

304 A = master $7
305 IF $3[1] = 48 THEN 307
306 $24[0] = B-1
0 REM master returns 0 if the connection was succesfull
0 REM or if we are still trying to connect.
307 IF A = 0 THEN 242
308 ALARM 8
309 RETURN

0 REM cable code, if we are not paired check for timeout.
310 IF $3[0] = 50 THEN 316
311 IF $3[0] = 52 THEN 304
312 B = readcnt
313 IF B > 120 THEN 293
314 IF $3[0] = 49 THEN 297
0 REM we are pairing as master,
315 GOTO 301;

316 A = slave -20;
317 GOTO 302


0 REM this interrupt is launched when there is an incomming
0 REM slave connection
@SLAVE 318
318 IF $9[2] = 48 THEN 321;
319 PRINTU "@SLAVE\n\r";
0 REM 320 IF $3[0] = 54 THEN 858;
0 REM if we are not on slave mode, then we must ignore slave connections :D
321 IF $3[3] = 50 THEN 344;
322 IF $3[0] > 50 THEN 347;
323 IF $3[0] > 48 THEN 325;
324 GOTO 347

325 A = getconn $7
0 REM if we are on service-slave, and the PIN was a success
0 REM then this is our peer.
326 IF $3[1] = 49 THEN 334
0 REM cable-slave-paired, check address
327 IF $3[0] = 50 THEN 331

0 REM set to paired no matter who cames
328 $3[0] = 50
329 $4 = $7
330 GOTO 334

0 REM check address of the connection and allow
331 $0 = $4
332 B = strcmp $7
333 IF B <> 0 THEN 347

0 REM slave connected
0 REM allow DSR interrupts
0 REM green and blue LEDS on
0 REM read sensors
334 A = nextsns 1
335 B = pioset ($8[1]-48)
336 B = pioset ($8[0]-48)
0 REM set RS232 power to on
337 A = pioset ($8[4]-48)
0 REM DTR set on, +5V
338 A = pioclr ($8[5]-48)
0 REM allow DSR interrupts
339 A = pioirq $14
0 REM connect RS232 to slave
340 IF $9[1]= 49 THEN 349
0 REM 376 A = baud I
341 ALARM 0
342 C = link 1
343 RETURN

344 PRINTU"\n\rCONNECTED\n\r
345 $3[3] = 53
346 GOTO 336

0 REM disconnect and exit
347 A = disconnect 0
348 RETURN

349 C = shell
350 RETURN

@MASTER 351
0 REM successful master connection
351 IF $9[2] = 48 THEN 354
352 PRINTU "@MASTER\n\r";
0 REM 353 IF $3[0] > 52 THEN 833
0 REM if we are on manual master, then we have some requests
354 IF $3[3] <> 52 THEN 359
355 $3[3] = 54
356 A = pioset ($8[1]-48);
357 A = pioset ($8[0]-48);
358 GOTO 367
0 REM if we are not on master modes, then we must avoid this connection.
359 IF $3[0] > 50 THEN 362;
360 IF $3[0] > 48 THEN 377;
361 IF $3[0] = 48 THEN 377;
362 A = pioset ($8[1]-48);
363 A = pioset ($8[0]-48);
0 REM don't switch state in service mode or manual
364 IF $3[3] = 52 THEN 374
365 IF $3[1] = 49 THEN 367
0 REM set state master paired
366 $3[0] = 52

0 REM read sensors
367 A = nextsns 1
368 A = pioset ($8[4]-48);
0 REM DTR set on
369 A = pioclr ($8[5]-48);
0 REM link
370 A = link 2
0 REM look for disconnect
371 ALARM 5
0 REM allow DSR interrupts
372 A = pioirq $14
373 GOTO 37

374 PRINTU"\n\rCONNECTED\n\r
375 $3[4] = 54
376 GOTO 367

377 A = disconnect 1
378 RETURN

0 REM $379 RESERVED
379 RESERVED
0 REM inquiry code, only in mode pair_as_master
@INQUIRY 380
380 $379 = $0
381 IF $9[2] = 48 THEN 383
382 PRINTU "@INQUIRY\n\r";
383 IF $3[3] <> 51 THEN 387
384 PRINTU"\n\rFound device: "
385 PRINTU $379
386 RETURN

387 $4 = $379;
388 $379 = $0[13];
389 IF $3[0] <> 51 THEN 391;
0 REM inquiry filter active
390 IF $3[2] = 49 THEN 392;
391 RETURN

392 IF $9[2] = 48 THEN 395;
393 PRINTU "found "
394 PRINTU $4
395 IF $5[0]=0 THEN 400;
0 REM check name of device
396 $0[0]=0;
397 PRINTV $379;
398 B = strcmp $5;
399 IF B <> 0 THEN 407;

0 REM found one, try to connect, inquiry canceled automaticall
0 REM 447 GOSUB 485;
400 B = master $4;
0 REM if master busy keep stored address in $4, get next
401 IF B = 0 THEN 408;
0 REM master accepted, store address, restart alarms, give it 8 seconds to connect
0 REM corrected by mn
402 $7 = $4;
403 ALARM 8;
0 REM all on to indicate we have one
404 A = pioset ($8[1]-48);
405 A = pioset ($8[0]-48);
0 REM set the counter to 5, when counter reaches
0 REM 0 we inqury again
406 $24="5"
407 RETURN

0 REM get next result, give the inq result at least 2 sec time
408 GOSUB 410;
409 RETURN

0 REM blink sub-routine pair as master mode, blue-on green-off and reverse
410 IF J = 1 THEN 415;
411 J = 1;
412 A = pioset ($8[0]-48);
413 A = pioclr ($8[1]-48);
414 RETURN
415 A = pioclr ($8[0]-48);
416 A = pioset ($8[1]-48);
417 J = 0;
418 RETURN;

@CONTROL 419
0 REM remote request for DTR pin on the RS232
419 IF $0[0] < 128 THEN 422
420 A = uartcfg$0[0]
421 RETURN
422 IF $0[0] = 49 THEN 425;
423 A=pioset ($8[5]-48);
424 RETURN;
425 A=pioclr ($8[5]-48);
426 RETURN

@UART 427
427 IF $9[2] = 48 THEN 429
428 PRINTU"@UART\n\r
429 A = uartint
430 $0[0] = 0;
431 TIMEOUTU 5
432 INPUTU $0;
433 A = strlen $0;
434 IF $0[A-3] <> 43 THEN 436
0 REM command line interface active
435 IF $0[A-1] = 43 THEN 438
436 A = uartint;
437 RETURN

438 $3[3] = 49
439 ALARM 1
440 A = enable 3
441 RETURN



0 REM read from uart and echo function
0 REM on line 940 we have the other uart echo function.
0 REM result is on $529
0 REM 528, 2211 RESERVED FOR TEMP
442 RESERVED
443 RESERVED
444 A = 1;
445 $443[0] = 0;
446 UART A;
447 IF $0[0] = 13 THEN 455;
448 $442 = $0;
449 PRINTU $0;
450 $0[0] = 0;
451 PRINTV $443;
452 PRINTV $442;
453 $443 = $0;
454 GOTO 446;
455 RETURN

0 REM command line interface
456 ALARM 0
457 A = uartcfg 136
458 A = pioclr ($8[0]-48);
459 A = pioclr ($8[1]-48);
460 $3[3] = 49
461 H = 0
0 REM enable FTP again
462 A = enable 3
463 PRINTU "\r\nAIRcable OS "
464 PRINTU "command line v
465 PRINTU $1
466 PRINTU "\r\nType h to "
467 PRINTU "see the list of "
468 PRINTU "commands";
469 PRINTU "\n\rAIRcable> "
470 GOSUB 704;
471 PRINTU"\n\r

0 REM h: help, l: list,
0 REM n: name, p: pin, b: name filter, g: address filter
0 REM c: class of device, u: uart, d: date,
0 REM s: slave, i: inquiry, m: master, a: mode
0 REM o: obex
0 REM e: exit

0 REM help
472 IF $443[0] = 104 THEN 619;
0 REM info
473 IF $443[0] = 108 THEN 505;
0 REM name
474 IF $443[0] = 110 THEN 634;
0 REM pin
475 IF $443[0] = 112 THEN 644;
0 REM class
476 IF $443[0] = 99 THEN 648;
0 REM uart
477 IF $443[0] = 117 THEN 531;
0 REM date
478 IF $443[0] = 100 THEN 674;
0 REM inquiry
479 IF $443[0] = 105 THEN 761;
0 REM slave
480 IF $443[0] = 115 THEN 833;
0 REM master
481 IF $443[0] = 109 THEN 800;
0 REM obex
482 IF $443[0] = 111 THEN 684;
0 REM modes
483 IF $443[0] = 97 THEN 557;
0 REM exit
484 IF $443[0] = 101 THEN 495;
0 REM name filter
485 IF $443[0] = 98 THEN 664;
0 REM hidden debug settings
486 IF $443[0] = 122 THEN 491;
0 REM reboot
487 IF $443[0] = 114 THEN 710;
0 REM name/pin settings
488 IF $443[0] = 107 THEN 717
489 PRINTU"Command not found
490 GOTO 469;

491 PRINTU"Input settings: "
492 GOSUB 444
493 $9 = $443
494 GOTO 469

0 REM exit code, we end with slave-1 to ensure
0 REM that @SLAVE starts all again, and that
0 REM we start unvisible
495 PRINTU "Bye!!\n\r
496 GOSUB 107;
497 $3[3] = 48;
498 H = 1
499 A = slave -1;
500 A = uartint
501 A = zerocnt
502 A = pioset($8[1]-48);
503 M = 0
504 RETURN

0 REM ----------------------- Listing Code ------------------------------------
505 PRINTU"Command Line v
506 PRINTU $1
507 PRINTU"\n\rName: ";
508 PRINTU $10;
509 PRINTU"\n\rPin: ";
510 PRINTU$11;
511 A = psget 0;
512 PRINTU"\n\rClass: ";
513 PRINTU $0;
514 PRINTU"Baud: "
515 GOSUB 551
0 REM 516 PRINTU"\n\rDate: ";
0 REM 517 A = date $0;
0 REM 518 PRINTU $0;
519 A = getaddr;
520 PRINTU"\n\rBT Address:
521 PRINTU $0
522 GOSUB 919;
523 PRINTU"\n\rBT Status:
524 PRINTU $39;
525 PRINTU"\n\rName Filter:
526 PRINTU $5;
527 GOSUB 598
528 GOTO 469;

531 PRINTU"Enter new Baud Ra
532 PRINTU"te divide by 100,
533 PRINTU"or 0 for switches
534 PRINTU": "
535 GOSUB 444
536 $15 = $443
537 PRINTU"\n\r"
538 PRINTU"Parity settings:\n
539 PRINTU"\r0 for none\n\r
540 PRINTU"1 for even\n\r
541 PRINTU"2 for odd: "
542 GOSUB 704
543 A = $443[0]
544 $22[0] = A
545 PRINTU"\n\rStop Bits settin"
546 PRINTU"gs:\n\r0 for 1 stop
547 PRINTU" bit\n\r1 for 2 stop
548 PRINTU" bits:
549 GOSUB 704
550 GOTO 469

551 IF $15[0] = 48 THEN 555
552 PRINTU $15
553 PRINTU "00 bps
554 RETURN
555 PRINTU "External
556 RETURN

0 REM -------------------------- Modes chooser --------------------------------
0 REM the user should select between
0 REM 0: Manual
0 REM 1: Service Slave
0 REM 2: Service Master
0 REM 3: Cable Slave
0 REM 4: Cable Master
0 REM 5: Master Relay Mode
0 REM Mode:
557 PRINTU"Select new mode\n
558 PRINTU"\r0: Manual\n\r1:
559 PRINTU" Service Slave\n
560 PRINTU"\r2: Service Mast
561 PRINTU"er\n\r3: Cable Sl
562 PRINTU"ave\n\r4: Cable M
563 PRINTU"aster\n\r\n\rMode:
565 PRINTU" "
566 GOSUB 704;
567 IF $443[0] = 48 THEN 575;
568 IF $443[0] = 49 THEN 577;
569 IF $443[0] = 50 THEN 579;
570 IF $443[0] = 51 THEN 582;
571 IF $443[0] = 52 THEN 584;
573 PRINTU"\n\rInvalid Option
574 GOTO 469;

575 $3 = "0010";
576 GOTO 469;
577 $3 = "1110";
578 GOTO 469;
579 $3 = "3110";
580 $7 = "0"
581 GOTO 469;
582 $3 = "1010";
583 GOTO 469;
584 $3 = "3010";
585 $7 = "0";
586 GOTO 469;

588 A = $433[0];
589 $9[3] = A
590 RETURN

0 REM -------------------------- Listing code ---------------------------------
598 PRINTU "\n\rMode: "
599 IF $3[0] > 52 THEN 617
600 IF $3[0] = 48 THEN 615
601 IF $3[1] = 48 THEN 604
602 PRINTU"Service - "
603 GOTO 605;
604 PRINTU"Cable - "
605 IF $3[0] >= 51 THEN 608;
606 PRINTU"Slave"
607 GOTO 609;
608 PRINTU"Master"
609 IF $3[0] = 50 THEN 613;
610 IF $3[0] = 52 THEN 613;
611 PRINTU"\n\rUnpaired"
612 RETURN
613 PRINTU"\n\rPaired"
614 RETURN
615 PRINTU"Idle"
616 RETURN
617 PRINTU"Relay Mode Master
618 RETURN

0 REM ----------------------- Help code ---------------------------------------
0 REM h: help, l: list,
0 REM n: name, p: pin, k: name/pin settings, 
0 REM b: name filter, g: address filter,
0 REM c: class of device, u: uart, d: date,
0 REM s: slave, i: inquiry, m: master, a: mode
0 REM o: obex, e: exit, r: reboot
619 PRINTU"h: help, l: list,\n"
620 PRINTU"\rn: name, p: pin, "
621 PRINTU"k: name/pin setting"
622 PRINTU"s,\n\rb: name filte"
623 PRINTU"r\n\rc: class of d"
624 PRINTU"evice, u: uart, d: "
625 PRINTU"date,\n\rs: slave, "
626 PRINTU"i: inquiry, m: mast"
627 PRINTU"er, a: mode,\n\ro: "
628 PRINTU"obex/obexFTP settin"
629 PRINTU"gs, e: exit, r: r"
630 PRINTU"boot\n\r"
631 GOTO 469;

0 REM Name Function
634 PRINTU"New Name: "
635 GOSUB 444;
636 $10 = $443;
637 $0[0] = 0;
638 PRINTV $10;
639 PRINTV " ";
640 A = getuniq $39;
641 PRINTV $39;
642 A = name $0;
643 GOTO 469

0 REM Pin Function
644 PRINTU"New PIN: ";
645 GOSUB 444;
646 $11 = $443;
647 GOTO 469

648 PRINTU"Type the class of "
649 PRINTU"device as xxxx xxx"
650 PRINTU"x: "
651 GOSUB 444
652 $0[0] = 0;
653 PRINTV"@0000 =
654 PRINTV$443;
655 $443 = $0;
656 A = psget 0;
657 $442 =$0
658 $0[0]=0;
659 PRINTV $443;
660 $443 = $442[17]
661 PRINTV $443;
662 A = psset 3
663 GOTO 469

0 REM friendly name filter code
664 PRINTU"Enter the new name"
665 PRINTU" filter: "
666 GOSUB 444
667 $5 = $443
668 GOTO 469;

0 REM addr filter code
669 PRINTU"Enter the new addr"
670 PRINTU"ess filter: "
671 GOSUB 444
672 $6 = $443
673 GOTO 469

0 REM date changing methods
674 PRINTU"Insert new dat
675 PRINTU"e, check the manua
676 PRINTU"l for formating: "
677 GOSUB 444;
678 A = strlen $443
679 IF A <> 16 THEN 682
680 A = setdate $443
681 GOTO 469
682 PRINTU"\n\rInvalid format
683 GOTO 469

0 REM activate Obex/ObexFTP
0 REM 0 Enabled only on command line
0 REM 1 Always enabled
0 REM 2 Always Disabled
684 PRINTU"Obex/ObexFTP setti"
685 PRINTU"ngs:\n\r0: Enabled "
686 PRINTU"only on command li"
687 PRINTU"ne\n\r1: Always Ena"
688 PRINTU"bled\n\r2: Always D"
689 PRINTU"isabled\n\rChoose "
690 PRINTU"Option: "
691 GOSUB 704
692 GOSUB 588
693 IF $443[0] = 50 THEN 699
694 $0[0] = 0
695 A = psget 6
696 $0[11] = 48
697 A = psset 4
698 GOTO 469
699 $0[0] = 0
700 A = psget 6
701 $0[11] = 54
702 A = psset 4
703 GOTO 469

0 REM one char read function
704 A = 1
705 $443[0] = 0;
706 UART A
707 PRINTU $0
708 $443 = $0
709 RETURN

0 REM reboot code
710 PRINTU"Rebooting, please "
711 PRINTU"do not disconnect "
712 PRINTU"electric power\n\r
713 $3[3] = 48
714 A = reboot
715 WAIT 2
716 RETURN

0 REM name/pin settings:
0 REM 0: Don't add anything,
0 REM 1: Add uniq to the name,
0 REM 2: Add uniq to the name, set pin to uniq.
717 PRINTU"Name/Pin settings:\n"
718 PRINTU"\r0: Don't add anyth"
719 PRINTU"ing,\n\r1: Add uniq "
720 PRINTU"to the name,\n\r2: "
721 PRINTU"Add uniq to the nam"
722 PRINTU"e, set pin to uniq: "
723 GOSUB 704
724 IF $443[0] < 48 THEN 728
725 IF $443[0] > 50 THEN 728
726 $23 = $443
727 GOTO 469

728 PRINTU"Invalid Option\n\r"
729 GOTO 717

0 REM ---------------------- Manual Modes code --------------------------------

730 PRINTU "\n\rThere is BT
731 PRINTU "activity, please
732 PRINTU "wait and try agai
733 PRINTU "n
734 GOTO 469;

0 REM Led STUFF for manual 
735 IF $3[3] = 50 THEN 744
736 IF $3[3] = 51 THEN 748
737 IF $3[3] = 52 THEN 754
0 REM command line has just started?
738 IF $3[3] = 49 THEN 456
739 IF $3[3] = 54 THEN 741
740 RETURN

741 A = pioclr ($8[0]-48);
742 A = pioclr ($8[1]-48);
743 GOTO 469

0 REM slave connecting leds
744 A = pioset ($8[1]-48);
745 A = pioset ($8[0]-48)
746 A = pioclr ($8[0]-48)
747 GOTO 846

0 REM inq leds
748 A = pioset ($8[0]-48);
749 A = pioset ($8[1]-48)
750 A = pioclr ($8[0]-48);
751 A = pioclr ($8[1]-48);
752 GOTO 846


0 REM this line is part of the relay mode
753 A = zerocnt
0 REM master connecting leds
754 A = pioset ($8[0]-48);
755 A = pioset ($8[1]-48)
756 A = pioclr ($8[1]-48);
757 ALARM 18
758 GOTO 846

0 REM inquiry code
0 REM by default we inquiry for 10 seconds
761 GOSUB 919;
762 IF $39[0] = 49 THEN 730
763 PRINTU"Inquirying for
764 PRINTU" 18s. Please wait.
765 A = nextsns 20
766 B = inquiry 6
767 $3[3] = 51;
768 GOSUB 919;
769 A = zerocnt
770 GOTO 748;

0 REM master code
800 GOSUB 919;
801 IF $39[3] = 49 THEN 730
802 PRINTU"Please input "
803 PRINTU"the addr of your "
804 PRINTU"peer:
805 GOSUB 444
806 B = strlen$443
807 IF B<>12 THEN 830
808 $3[3] = 52;
809 A = nextsns 20
810 B = master $443
811 B = zerocnt
812 GOTO 754

830 PRINTU"Invalid add
831 PRINTU"r, try again.
832 GOTO 469;

0 REM slave code
0 REM manual slave
0 REM by default we open the slave channel for 60 seconds
833 GOSUB 919;
834 IF $39[4] = 49 THEN 730
835 PRINTU"Slave Open for 16s
836 $3[3] = 50
837 A = nextsns 20
838 A = slave 15
839 A = zerocnt
840 GOTO 744


0 REM timeout for any manual mode, as this part of the code
0 REM will be called as soon as the slave channel is opened
0 REM we check for activity firstly
846 B = readcnt
847 IF B < 16 THEN 854
848 $3[3] = 49
0 REM 797 ALARM 0
849 A = cancel
0 REM 799 A = disconnect 0
850 A = disconnect 1
851 A = pioclr ($8[0]-48)
852 A = pioclr ($8[1]-48)
0 REM 804 A = nextsns 4
853 GOTO 469

854 ALARM 18 
855 RETURN

860 IF $3[3] > 48 THEN 862
861 A = baud I
862 RETURN

863 IF $3[3] > 48 THEN 865
864 A = uartcfg I
865 RETURN

867 IF I = 12 THEN 882
868 IF I = 24 THEN 884
869 IF I = 48 THEN 886
870 IF I = 96 THEN 888
871 IF I = 192 THEN 890
872 IF I = 384 THEN 892
873 IF I = 576 THEN 894
874 IF I = 769 THEN 896
875 IF I = 1152 THEN 898
876 IF I = 2304 THEN 900
877 IF I = 4608 THEN 902
878 IF I = 9216 THEN 904
879 IF I = 13824 THEN 906
0 REM wrong settings for baud rate, we don't have a fixed value, we can't do
0 REM parity and stop bits
880 GOTO 860

882 I = 0
883 GOTO 907
884 I = 1
885 GOTO 907
886 I = 2
887 GOTO 907
888 I = 3
889 GOTO 907
890 I = 4
891 GOTO 907
892 I = 5
893 GOTO 907
894 I = 6
895 GOTO 907
896 I = 7
897 GOTO 907
898 I = 8
899 GOTO 907
900 I = 9
901 GOTO 907
902 I = 10
903 GOTO 907
904 I = 11
905 GOTO 907
906 I = 12
907 IF $22[0] = 49 THEN 910
908 IF $22[0] = 50 THEN 912
909 GOTO 913
910 I = I + 64
911 GOTO 913
912 I = I + 32
913 IF $22[1] = 49 THEN 916
914 GOTO 916
915 I = I + 16
916 I = I + 128
917 GOTO 863

0 REM convert status to a string
0 REM store the result on $44
919 B = status
920 $39[0] = 0;
921 $39 = "00000";
922 IF B < 10000 THEN 925;
923 $39[0] = 49;
924 B = B -10000;
925 IF B < 1000 THEN 928;
926 $39[1] = 49;
927 B = B -1000;
928 IF B < 100 THEN 931;
929 $39[2] = 49;
930 B = B -100;
931 IF B < 10 THEN 934;
932 $39[3] = 49;
933 B = B -10;
934 IF B < 1 THEN 936;
935 $39[4] = 49;
936 $39[5] = 0;
937 RETURN

940 IF $3[3] <> 48 THEN 944
941 IF $0[$8[6]-48]=48THEN151;
942 IF $0[$8[6]-48]=49THEN153;
943 RETURN

944 A = disconnect 0
945 A = disconnect 1
946 $3[3] = 49
947 ALARM 1
948 RETURN


