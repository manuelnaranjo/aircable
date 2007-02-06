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
0 REM $8[7] POWER SWITCH / COMMAND LINE ENABLED
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
9 1000

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
0 REM POWER SWITCH / COMMAND LINE ENABLED
0 REM 12 K0000000
12 A94B3566

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
89 GOSUB 590

0 REM let's start up, green LED on
90 A = pioset ($8[1]-48)

91 K = 1
0 REM now we go to @IDLE, and then we get into the @ALARM
92 H = 1
0 REM for Unisex V2 switch detector
93 A = pioset $8[7]-48
94 A = pioin $8[7]-48
95 M = 0
96 IF H = 0 THEN 99
97 RESERVED
98 RETURN

0 REM Obex/ObexFTP timing handler
0 REM this code is also called from the command line on exit
99 B = readcnt
100 C = atoi $16
101 IF B < C THEN 108
102 GOSUB 105
103 H = 0
104 GOTO 150

105 IF $9[3] = 49 THEN 107
106 A = disable 3
107 RETURN

108 ALARM 30
109 GOTO 150

0 REM idle will be called, when the command line ends working
0 REM when the slave connection is closed, and when slave calls
0 REM timeouts, in any of those cases we will let the @ALARM
0 REM handle the slave mode stuff
0 REM idle used for slave connections, pairing or paired
@IDLE 110
111 IF $3[3] <> 48 THEN 120;
112 IF W <> 0 THEN 118;
113 IF K = 1 THEN 116;
114 IF K = 2 THEN 117;
0 REM lets trigger the alarm manually
115 GOTO 144;


116 A = slave-1;
117 K = 0;
118 RETURN

120 $3[3] = 48;
121 ALARM 1
122 RETURN

@PIN_CODE 140
140 IF $9[2] = 48 THEN 142
141 PRINTU "@PIN_CODE"
142 $0=$11;
143 RETURN

0 REM ALARM code, handles modes stuff, LEDs and long button press 
@ALARM 144
144 IF $9[2] = 48 THEN 146
145 PRINTU "@ALARM\n\r";


0 REM handle button press first of all.
146 IF W = 1 THEN 184


0 REM should go to mode dumping
147 IF $9[2] = 48 THEN 149
148 GOSUB 590

149 IF H = 1 THEN 99

150 IF $3[0] > 52 THEN 783

0 REM now the led stuff, and finally we handle the state.
0 REM firstly see if we are connected, then do what you need
151 B = status;
152 IF B < 10000 THEN 154;
153 B = B - 10000;
154 IF B > 0 THEN 156;
155 GOTO 160
0 REM ensure the leds are on
156 A = pioset ($8[0]-48);
157 A = pioset ($8[1]-48);
158 ALARM 5
159 RETURN

160 A = baud 1152
0 REM are we on automatic or manual?
161 IF $3[3] <> 48 THEN 718
0 REM we are on automatic.
0 REM are we on automatic - manual?
162 IF $3[0] = 48 THEN 179

0 REM LED SCHEMA:
0 REM CABLE 	SLAVE 	1 fast blink
0 REM SERVICE 	SLAVE 	2 fast blink
0 REM CABLE	MASTER 	3 fast blink
0 REM SERVICE	MASTER 	4 fast blink
163 A = pioset ($8[1]-48);
164 A = pioset ($8[0]-48)
165 A = pioclr ($8[0]-48);
0 REM are we on master or slave?
166 IF $3[0] > 50 THEN 171
0 REM ok we are on slave
0 REM CABLE 	SLAVE 1 fast BLINK
0 REM SERVICE 	SLAVE 2 fast BLINK

0 REM now are we on cable or service?
167 IF $3[1] = 48 THEN 222
0 REM service slave
168 A = pioset ($8[0]-48)
169 A = pioclr ($8[0]-48);
170 GOTO 211;

0 REM we are on master modes
171 FOR B = 0 TO 2
172 A = pioset ($8[0]-48)
173 A = pioclr ($8[0]-48
174 NEXT B
175 IF $3[1] = 48 THEN 222;
176 A = pioset ($8[0]-48)
177 A = pioclr ($8[0]-48);
178 GOTO 213;


0 REM manual idle code, this is the only mode that ends here.
179 B = pioset ($8[1]-48);
180 B = pioclr ($8[0]-48);
0 REM little hidden feauture on $3[5], it is somesort of flag
0 REM that tell us if this is the first time that @IDLE is called
0 REM or the second, while we are on automatic-manual
181 A = slave-1;
182 K = 2
183 RETURN

0 REM this is a long button press, we have stuff to do
0 REM if we are connected, then we disconnect and reboot to unpaired
0 REM if we aren't then we must reboot and go to idle mode.
184 GOSUB 800;
185 W = 2
186 IF $39[3] = 49 THEN 198
187 IF $39[4] = 49 THEN 198

0 REM reboot 
188 $3[0] = 48
189 $3[1] = 48
190 IF $9[2] = 48 THEN 192
191 PRINTU"->Reboot\n\r";
192 A = pioclr($8[0]-48);
193 A = pioclr($8[1]-48);
194 W = 3
195 A = reboot
196 WAIT 3;
197 RETURN

0 REM disconnects, disconnect restarts @IDLE
198 ALARM 0
199 IF $9[2] = 48 THEN 201
200 PRINTU "-> Discconnect\n\r"
0 REM if we were paired, then we must unpair.
201 IF $3[0] = 50 THEN 204
202 IF $3[0] = 52 THEN 204
203 GOTO 205;
204 $3[0] = ($3[0] -1)
0 REM 307 A = disconnect 0
0 REM 308 A = disconnect 1
0 REM 309 A = cancel
205 $7 = "0"
206 GOTO 190

0 REM cable mode timeout
207 IF $9[2] = 48 THEN 209
208 PRINTU "Timeout\n\r";
209 ALARM 0;
210 GOTO 179;

0 REM automatic modes code.
0 REM service - slave:
211 A = slave 5;
212 RETURN

0 REM service - master
213 A = strlen $7;
214 IF A > 1 THEN 218
215 A = inquiry 6
216 ALARM 8
217 RETURN

218 A = master $7
0 REM master returns 0 if the connection was succesfull
0 REM or if we are still trying to connect.
219 IF A = 0 THEN 156
220 ALARM 8
221 RETURN

0 REM cable code, if we are not paired check for timeout.
222 IF $3[0] = 50 THEN 228
223 IF $3[0] = 52 THEN 218
224 B = readcnt
225 IF B > 120 THEN 207
226 IF $3[0] = 49 THEN 211
0 REM we are pairing as master,
227 GOTO 215;

228 A = slave -5;
229 RETURN


0 REM this interrupt is launched when there is an incomming
0 REM slave connection
@SLAVE 240
240 A = pioget ($8[7]-48);
241 IF A = 1 THEN 280
242 IF $9[2] = 48 THEN 244;
243 PRINTU "@SLAVE\n\r";
244 IF $3[0] = 54 THEN 820;
0 REM if we are not on slave mode, then we must ignore slave connections :D
245 IF $3[3] = 50 THEN 268;
246 IF $3[0] > 50 THEN 271;
247 IF $3[0] > 48 THEN 249;
248 GOTO 271

249 A = getconn $7
0 REM if we are on service-slave, and the PIN was a success
0 REM then this is our peer.
250 IF $3[1] = 49 THEN 258
0 REM cable-slave-paired, check address
251 IF $3[0] = 50 THEN 255

0 REM set to paired no matter who cames
252 $3[0] = 50
253 $4 = $7
254 GOTO 258

0 REM check address of the connection and allow
255 $0 = $4
256 B = strcmp $7
257 IF B <> 0 THEN 271

0 REM slave connected
0 REM allow DSR interrupts
0 REM green and blue LEDS on
0 REM read sensors
258 A = nextsns 1
259 B = pioset ($8[1]-48)
260 B = pioset ($8[0]-48)
0 REM set RS232 power to on
261 A = pioset ($8[4]-48)
0 REM DTR set on, +5V
262 A = pioclr ($8[5]-48)
0 REM allow DSR interrupts
263 A = pioirq $14
0 REM connect RS232 to slave
264 IF $9[1]= 49 THEN 273
0 REM 376 A = baud I
265 ALARM 0
266 C = link 1
267 RETURN

268 PRINTU"\n\rCONNECTED\n\r
269 $3[3] = 53
270 GOTO 260

0 REM disconnect and exit
271 A = disconnect 0
272 RETURN

273 C = shell
274 RETURN

0 REM if PIO is on the user has 5 seconds to get into the command line
0 REM interface
280 TIMEOUTS 5
281 INPUTS $279
282 IF $279[0] <> 43 THEN 242
283 IF $279[2] <> 43 THEN 242
284 GOTO 451

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


0 REM read from uart and echo function
0 REM on line 940 we have the other uart echo function.
0 REM result is on $529
0 REM 528, 438 RESERVED FOR TEMP
437 RESERVED
438 RESERVED
439 INPUTS $438;
440 GOTO 441;
441 RETURN

0 REM command line interface
451 ALARM 0
452 A = baud 1152
453 A = pioclr ($8[0]-48);
454 A = pioclr ($8[1]-48);
455 $3[3] = 49
0 REM enable FTP again
456 A = enable 3
457 PRINTS "\r\nAIRcable OS "
458 PRINTS "command line v
459 PRINTS $1
460 PRINTS "\r\nType h to "
461 PRINTS "see the list of "
462 PRINTS "commands";
463 PRINTS "\n\rAIRcable> "
464 GOSUB 710;
465 PRINTS"\n\r

0 REM h: help, l: list,
0 REM n: name, p: pin, b: name filter, g: address filter
0 REM c: class of device, u: uart, d: date,
0 REM a: mode
0 REM o: obex
0 REM e: exit

0 REM help
466 IF $438[0] = 104 THEN 620;
0 REM info
467 IF $438[0] = 108 THEN 510;
0 REM name
468 IF $438[0] = 110 THEN 640;
0 REM pin
469 IF $438[0] = 112 THEN 650;
0 REM class
470 IF $438[0] = 99 THEN 654;
0 REM uart
471 IF $438[0] = 117 THEN 536;
0 REM date
472 IF $438[0] = 100 THEN 680;
0 REM shell
473 IF $438[0] = 115 THEN 740;
0 REM obex
476 IF $438[0] = 111 THEN 690;
0 REM modes
477 IF $438[0] = 97 THEN 549;
0 REM exit
478 IF $438[0] = 101 THEN 490;
0 REM name filter
479 IF $438[0] = 98 THEN 670;
0 REM addr filter
480 IF $438[0] = 103 THEN 675;
0 REM hidden debug settings
481 IF $438[0] = 122 THEN 486;
0 REM reboot
482 IF $438[0] = 114 THEN 713;
484 PRINTS"Command not found
485 GOTO 463;

486 PRINTS"Input settings: "
487 GOSUB 439
488 $9 = $438
489 GOTO 463

0 REM exit code, we end with slave-1 to ensure
0 REM that @SLAVE starts all again, and that
0 REM we start unvisible
490 PRINTS "Bye!!\n\r
491 GOSUB 105;
492 $3[3] = 48;
493 A = disconnect 0;
495 A = zerocnt
496 A = slave -1
497 RETURN

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
520 GOSUB 543
521 PRINTS"\n\rDate: ";
522 A = date $0;
523 PRINTS $0;
524 A = getaddr;
525 PRINTS"\n\rBT Address:
526 PRINTS $0
527 GOSUB 800;
528 PRINTS"\n\rBT Status:
529 PRINTS $39;
530 PRINTS"\n\rName Filter:
531 PRINTS $5;
532 PRINTS"\n\rAddr Filter:
533 PRINTS $6;
534 GOSUB 590
535 GOTO 463;

536 PRINTS"Enter new Baud Ra
537 PRINTS"te divide by 100,
538 PRINTS"or 0 for switches
539 PRINTS": "
540 GOSUB 439
541 $15 = $438
542 GOTO 463

543 IF $15[0] = 48 THEN 547
544 PRINTS $15
545 PRINTS "00 bps
546 RETURN
547 PRINTS "External
548 RETURN

0 REM -------------------------- Modes chooser --------------------------------
0 REM the user should select between
0 REM 0: Manual
0 REM 1: Service Slave
0 REM 2: Service Master
0 REM 3: Cable Slave
0 REM 4: Cable Master
0 REM 5: Master Relay Mode
0 REM Mode:
549 PRINTS"Select new mode\n
550 PRINTS"\r0: Manual\n\r1:
551 PRINTS" Service Slave\n
552 PRINTS"\r2: Service Mast
553 PRINTS"er\n\r3: Cable Sl
554 PRINTS"ave\n\r4: Cable M
555 PRINTS"aster\n\r5: Maste
556 PRINTS"r Relay Mode\n\rM
557 PRINTS"ode: "
558 GOSUB 710;
559 IF $438[0] = 48 THEN 567;
560 IF $438[0] = 49 THEN 570;
561 IF $438[0] = 50 THEN 574;
562 IF $438[0] = 51 THEN 578;
563 IF $438[0] = 52 THEN 582;
564 IF $438[0] = 53 THEN 586;
565 PRINTS"\n\rInvalid Option
566 GOTO 463;

567 $3[0]=48;
568 $3[3]=49;
569 GOTO 463;
570 $3[0] = 49;
571 $3[1] = 49;
572 $3[3] = 48;
573 GOTO 463;
574 $3[0] = 51;
575 $3[1] = 49;
576 $3[3] = 48;
577 GOTO 463;
578 $3[0] = 49;
579 $3[1] = 48;
580 $3[3] = 48;
581 GOTO 463;
582 $3[0] = 51;
583 $3[2] = 49;
584 $3[3] = 48;
585 GOTO 463;
586 $3[0] = 53;
587 $3[1] = 50;
588 $3[2] = 48;
589 GOTO 463

0 REM -------------------------- Listing code ---------------------------------
590 PRINTS "\n\rMode: "
591 IF $3[0] > 52 THEN 609
592 IF $3[0] = 48 THEN 607
593 IF $3[1] = 48 THEN 596
594 PRINTS"Service - "
595 GOTO 597;
596 PRINTS"Cable - "
597 IF $3[0] >= 51 THEN 600;
598 PRINTS"Slave"
599 GOTO 601;
600 PRINTS"Master"
601 IF $3[0] = 50 THEN 605;
602 IF $3[0] = 52 THEN 605;
603 PRINTS"\n\rUnpaired"
604 RETURN
605 PRINTS"\n\rPaired"
606 RETURN
607 PRINTS"Idle"
608 RETURN
609 PRINTS"Relay Mode Master
610 RETURN

0 REM ----------------------- Help code ---------------------------------------
0 REM h: help, l: list,
0 REM n: name, p: pin, b: name filter, g: address filter
0 REM c: class of device, u: uart, d: date,
0 REM o: obex, a: mode
0 REM e: exit, r: reboot
620 PRINTS"h: help, l: li
621 PRINTS"st\n\rn: name, p: "
622 PRINTS"pin, b: name filte"
623 PRINTS"r, g: address filt"
624 PRINTS"er\n\rc: class of "
625 PRINTS"device, u: uart, d"
626 PRINTS": date\n\ro: obex, "
627 PRINTS"a: mode, s: shell\n"
628 PRINTS"\re: exit, r: reboo
629 PRINTS"t"
630 GOTO 463;

0 REM Name Function
640 PRINTS"New Name: "
641 GOSUB 439;
642 $10 = $438;
643 $0[0] = 0;
644 PRINTV $10;
645 PRINTV " ";
646 A = getuniq $39;
647 PRINTV $39;
648 A = name $0;
649 GOTO 463

0 REM Pin Function
650 PRINTS"New PIN: ";
651 GOSUB 439;
652 $11 = $438;
653 GOTO 463

654 PRINTS"Type the class of "
655 PRINTS"device as xxxx xxx"
656 PRINTS"x: "
657 GOSUB 439
658 $0[0] = 0;
659 PRINTV"@0000 =
660 PRINTV$438;
661 $438 = $0;
662 A = psget 0;
663 $437 =$0
664 $0[0]=0;
665 PRINTV $438;
666 $438 = $437[17]
667 PRINTV $438;
668 A = psset 3
669 GOTO 463

0 REM friendly name filter code
670 PRINTS"Enter the new name"
671 PRINTS" filter: "
672 GOSUB 439
673 $5 = $438
674 GOTO 463;

0 REM addr filter code
675 PRINTS"Enter the new addr"
676 PRINTS"ess filter: "
677 GOSUB 439
678 $6 = $438
679 GOTO 463

0 REM date changing methods
680 PRINTS"Insert new dat
681 PRINTS"e, check the manua
682 PRINTS"l for formating: "
683 GOSUB 439;
684 A = strlen $438
685 IF A <> 16 THEN 688
686 A = setdate $438
687 GOTO 463
688 PRINTS"\n\rInvalid format
689 GOTO 463

0 REM activate Obex/ObexFTP
0 REM 0 Enabled only on command line
0 REM 1 Always enabled
0 REM 2 Always Disabled
690 PRINTS"Obex/ObexFTP setti"
691 PRINTS"ngs:\n\r0: Enabled "
692 PRINTS"only on command li"
693 PRINTS"ne\n\r1: Always Ena"
694 PRINTS"bled\n\r2: Always D"
695 PRINTS"isabled\n\rChoose "
696 PRINTS"Option: "
697 GOSUB 710
698 939 $9[3] = $438[0]
699 IF $438[0] = 50 THEN 705
700 $0[0] = 0
701 A = psget 6
702 $0[11] = 48
703 A = psset 3
704 GOTO 463
705 $0[0] = 0
706 A = psget 6
707 $0[11] = 54
708 A = psset 3
709 GOTO 463

0 REM one char read function
710 A = 1
711 INPUTS $438
712 RETURN

0 REM reboot code
713 PRINTS"Rebooting, please "
714 PRINTS"do not disconnect "
715 PRINTS"electric power\n\r
716 $3[3] = 48

717 A = disconnect 0
718 A = reboot
718 WAIT 2
719 RETURN

0 REM convert status to a string
0 REM store the result on $44
800 B = status
801 $39[0] = 0;
802 $39 = "00000";
803 IF B < 10000 THEN 806;
804 $39[0] = 49;
805 B = B -10000;
806 IF B < 1000 THEN 809;
807 $39[1] = 49;
808 B = B -1000;
809 IF B < 100 THEN 812;
810 $39[2] = 49;
811 B = B -100;
812 IF B < 10 THEN 815;
813 $39[3] = 49;
814 B = B -10;
815 IF B < 1 THEN 817;
816 $39[4] = 49;
817 $39[5] = 0;
818 RETURN

740 A = shell
741 RETURN
