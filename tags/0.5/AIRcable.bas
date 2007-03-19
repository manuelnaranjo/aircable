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
12 K000000

0 REM PIO_IRQ SETTINGS
0 REM 13 only buttons pio, used for starting interrupts when there is
0 REM no connection going on
13 P00000000000
0 REM 14 button + DSR interrupt, interrupts that must be listened while
0 REM there is a connection going on
14 P00000000000

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

0 REM $44 RESERVED
44 RESERVED

0 REM THIS TURNS A CHAR AT $0[E] into
0 REM and integer in F
45 IF $0[E] > 57 THEN 48
46 F = $0[E] - 48;
47 RETURN
0 REM WE NEED TO ADD 10 BECAUSE "A" IS NOT 0
0 REM IS 10
48 F = $0[E] - 55;
49 RETURN


@INIT 50
50 Z = $9[0] - 48;
51 A = uart 1152
52 IF $9[2] = 48 THEN 54
53 PRINTU "@INIT\n\r";
54 IF $8[0] <> 122 THEN 62
55 $0[0] = 0
56 PRINTV $12
57 FOR E = 0 TO 6
58 GOSUB 45
59 $8[E] = F + 48
60 NEXT E
61 $8[8] = 0

62 $0[0] = 0;
63 PRINTV $10;
64 PRINTV " ";
65 A = getuniq $44;
66 PRINTV $44;
67 A = name $0;

0 REM button as input
68 A = pioin ($8[2]-48);
0 REM bias pull up to high
69 A = pioset ($8[2]-48);
0 REM green LED output, off
70 A=pioout ($8[1]-48);
71 A=pioclr ($8[1]-48);
0 REM blue LED output, off
72 A=pioout ($8[0]-48)
0 REM RS232_off set, switch on RS232
73 A=pioout ($8[3]-48)
74 A=pioset ($8[3]-48)
0 REM RS232_on power on, switch to automatic later
75 A=pioout ($8[4]-48)
76 A=pioset ($8[4]-48)
0 REM DTR output set -5V
77 A=pioout ($8[5]-48)
78 A=pioset ($8[5]-48)
0 REM DSR input
79 A=pioin ($8[6]-48)
0 REM set DSR to IRQ so that PIO_IRQ is called
0 REM just button interrupts here
80 A=pioirq $13

0 REM start baud rate
81 A = baud 1152
82 A = nextsns 6
0 REM reset for pairing timeout
83 A = zerocnt
84 IF $9[2] = 48 THEN 86
85 PRINTU "Command Line ready

0 REM state initialize
86 IF $3[0] <> 90 THEN 88
0 REM newly updated BASIC program, goto SLAVE mode
87 $3 = $2;

0 REM init button state
88 W = 0

0 REM in idle mode we wait for a command line interface start
0 REM you must type a +++ and enter
0 REM blue LED off
89 A = pioclr ($8[0]-48)
90 J = 0

91 $3[3] = 48;

0 REM should go to mode dump
92 IF $9[2] = 48 THEN 94
93 GOSUB 671

0 REM let's start up, green LED on
94 A = pioset ($8[1]-48)

96 K = 1
0 REM now we go to @IDLE, and then we get into the @ALARM
95 A = uartint
97 H = 1
98 RETURN

0 REM Obex/ObexFTP timing handler
0 REM this code is also called from the command line on exit
99 B = readcnt
100 C = atoi $16
101 IF B < C THEN 108
102 GOSUB 105
103 H = 0
104 GOTO 235

105 IF $9[3] = 49 THEN 107
106 A = disable 3
107 RETURN

108 ALARM 30
109 GOTO 235

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

142 RETURN
0 REM handle button press and DSR, status is $0
@PIO_IRQ 143
143 IF $9[2] = 48 THEN 146;
144 PRINTU "PIO_IRQ\n\r"
145 PRINTU $0

0 REM press button starts alarm for long press recognition
146 IF $0[$8[2]-48]=48THEN184
0 REM speaciall tratement for Button release on rebooting
147 IF W = 3 THEN 142
0 REM was it a release, now handle it
148 IF W <> 0 THEN 157

0 REM button no pressed, button not released
0 REM when DSR on the RS232 changes
149 IF $0[$8[6]-48]=48THEN152;
150 IF $0[$8[6]-48]=49THEN154;
151 RETURN
0 REM modem control to the other side
152 A = modemctl 0;
153 RETURN
154 A = modemctl 1;
155 RETURN

0 REM released with W == 2, alarm already handled it, exit
156 IF W = 2 THEN 180

0 REM this is a short button press
0 REM if we are on idle mode, then we switch to cable slave
0 REM if we are on service or cable unnconnected then switch master <-> slave
0 REM there is a slight difference between this spec, and the last one
0 REM on the last one any button press while on service did nothing.
157 B = status;
158 IF B < 10000 THEN 160;
159 B = B - 10000;
160 IF B > 0 THEN 189;
161 IF $3[0] = 48 THEN 171;
162 IF $3[0] > 50 THEN 171;

0 REM we were slave, now lets go to master.
163 ALARM 0
164 IF $9[2] = 48 THEN 166;
165 PRINTU "-> pair as master";
166 $3[0] = 51;
167 W = 0;
168 B = zerocnt;
169 A = slave-1;
170 RETURN

0 REM switch to pair as slave
171 ALARM 0
172 IF $9[2] = 48 THEN 174 
173 PRINTU "-> pair as slave\n"
174 $3[0] = 49
175 W = 0
176 A = zerocnt;
0 REM cancel inquiries
177 A = cancel
178 ALARM 1
179 RETURN

180 IF $9[2] = 48 THEN 182 
181 PRINTU"Handled, ignore\n\r" 
182 W = 0
183 RETURN


0 REM button press, recognize it and start ALARM for long press
184 IF $9[2] = 48 THEN 186
185 PRINTU "Button press\n\r"
186 W = 1
187 ALARM 3
188 RETURN

189 IF $9[2] = 48 THEN 191
190 PRINTU "Short, Connected
191 W = 0
192 RETURN

0 REM idle will be called, when the command line ends working
0 REM when the slave connection is closed, and when slave calls
0 REM timeouts, in any of those cases we will let the @ALARM
0 REM handle the slave mode stuff
0 REM idle used for slave connections, pairing or paired
@IDLE 193
193 IF $3[3] <> 48 THEN 853;
194 IF $3[0] > 52 THEN 202;
195 IF W <> 0 THEN 201;
196 IF K = 1 THEN 199;
197 IF K = 2 THEN 200;
0 REM lets trigger the alarm manually
198 GOTO 229; 


199 A = slave-1;
200 K = 0;
201 RETURN

202 IF $3[0] = 53 THEN 215
203 IF $3[0] = 54 THEN 207
204 IF $3[0] = 55 THEN 814
205 A = disconnect 1
206 $3[0] = 54
207 A = uartint
208 B = status
209 IF B > 0 THEN 211
210 GOSUB 952
211 A = pioset ($8[1]-48);
212 A = pioset ($8[0]-48)
213 A = pioclr ($8[0]-48)
214 ALARM 9
215 RETURN

216 A = pioset ($8[0]-48);
217 A = pioset ($8[1]-48)
218 A = pioclr ($8[1]-48);
219 B = status
220 IF B > 1 THEN 222
221 A = master $20
222 ALARM 4
223 RETURN

@PIN_CODE 224
224 IF $9[2] = 48 THEN 226
225 PRINTU "@PIN_CODE"
226 $0=$11;
227 RETURN

0 REM ALARM code, handles modes stuff, LEDs and long button press 
@ALARM 229
229 IF $9[2] = 48 THEN 231
230 PRINTU "@ALARM\n\r";


0 REM handle button press first of all.
231 IF W = 1 THEN 285


0 REM should go to mode dumping
232 IF $9[2] = 48 THEN 234
233 GOSUB 671

234 IF H = 1 THEN 99

235 IF $3[0] > 52 THEN 890

0 REM now the led stuff, and finally we handle the state.
0 REM firstly see if we are connected, then do what you need
236 B = status;
237 IF B < 10000 THEN 239;
238 B = B - 10000;
239 IF B > 0 THEN 241;
240 GOTO 245
0 REM ensure the leds are on
241 A = pioset ($8[0]-48);
242 A = pioset ($8[1]-48);
243 ALARM 5
244 RETURN

245 A = baud 1152
0 REM are we on automatic or manual?
246 IF $3[3] <> 48 THEN 794
0 REM we are on automatic.
0 REM are we on automatic - manual?
247 IF $3[0] = 48 THEN 280

0 REM LED SCHEMA:
0 REM CABLE 	SLAVE 	1 fast blink
0 REM SERVICE 	SLAVE 	2 fast blink
0 REM CABLE	MASTER 	3 fast blink
0 REM SERVICE	MASTER 	4 fast blink
248 A = pioset ($8[1]-48);
249 A = pioset ($8[0]-48)
250 A = pioclr ($8[0]-48);
0 REM are we on master or slave?
251 IF $3[0] > 50 THEN 256
0 REM ok we are on slave
0 REM CABLE 	SLAVE 1 fast BLINK
0 REM SERVICE 	SLAVE 2 fast BLINK

0 REM now are we on cable or service?
252 IF $3[1] = 48 THEN 340
0 REM service slave
253 A = pioset ($8[0]-48)
254 A = pioclr ($8[0]-48);
255 GOTO 320;

0 REM we are on master modes
256 FOR B = 0 TO 2
257 A = pioset ($8[0]-48)
258 A = pioclr ($8[0]-48
259 NEXT B
260 IF $3[1] = 48 THEN 340;
261 A = pioset ($8[0]-48)
262 A = pioclr ($8[0]-48);
263 GOTO 325;


0 REM manual idle code, this is the only mode that ends here.
280 B = pioset ($8[1]-48);
281 B = pioclr ($8[0]-48);
0 REM little hidden feauture on $3[5], it is somesort of flag
0 REM that tell us if this is the first time that @IDLE is called
0 REM or the second, while we are on automatic-manual
282 A = slave-1;
283 K = 2
284 RETURN

0 REM this is a long button press, we have stuff to do
0 REM if we are connected, then we disconnect and reboot to unpaired
0 REM if we aren't then we must reboot and go to idle mode.
285 GOSUB 1000;
286 W = 2
287 IF $44[3] = 49 THEN 300
289 IF $44[4] = 49 THEN 300

0 REM reboot 
290 $3[0] = 48
291 $3[1] = 48
292 IF $9[2] = 48 THEN 294
293 PRINTU"->Reboot\n\r";
294 A = pioclr($8[0]-48);
295 A = pioclr($8[1]-48);
296 W = 3
297 A = reboot
298 WAIT 3;
299 RETURN

0 REM disconnects, disconnect restarts @IDLE
300 ALARM 0
301 IF $9[2] = 48 THEN 303
302 PRINTU "-> Discconnect\n\r"
0 REM if we were paired, then we must unpair.
303 IF $3[0] = 50 THEN 306
304 IF $3[0] = 52 THEN 306
305 GOTO 307;
306 $3[0] = ($3[0] -1)
0 REM 307 A = disconnect 0
0 REM 308 A = disconnect 1
0 REM 309 A = cancel
307 $7 = "0"
308 GOTO 292

0 REM cable mode timeout
315 IF $9[2] = 48 THEN 317
316 PRINTU "Timeout\n\r";
317 ALARM 0;
318 GOTO 280;

0 REM automatic modes code.
0 REM service - slave:
320 A = slave 5;
321 RETURN

0 REM service - master
325 A = strlen $7;
326 IF A > 1 THEN 330
327 A = inquiry 6
328 ALARM 8
329 RETURN

330 A = master $7
0 REM master returns 0 if the connection was succesfull
0 REM or if we are still trying to connect.
331 IF A = 0 THEN 241 
332 ALARM 8
333 RETURN

0 REM cable code, if we are not paired check for timeout.
340 IF $3[0] = 50 THEN 347
341 IF $3[0] = 52 THEN 330
342 B = readcnt
343 IF B > 120 THEN 315
344 IF $3[0] = 49 THEN 320
0 REM we are pairing as master,
345 GOTO 327;

347 A = slave -5;
348 RETURN


0 REM this interrupt is launched when there is an incomming
0 REM slave connection
@SLAVE 350
350 IF $9[2] = 48 THEN 352;
351 PRINTU "@SLAVE\n\r";
352 IF $3[0] = 54 THEN 950;
0 REM if we are not on slave mode, then we must ignore slave connections :D
353 IF $3[3] = 50 THEN 380;
354 IF $3[0] > 50 THEN 384;
355 IF $3[0] > 48 THEN 357;
356 GOTO 384

357 A = getconn $7
0 REM if we are on service-slave, and the PIN was a success
0 REM then this is our peer.
358 IF $3[1] = 49 THEN 368
0 REM cable-slave-paired, check address
359 IF $3[0] = 50 THEN 363

0 REM set to paired no matter who cames
360 $3[0] = 50
361 $4 = $7
362 GOTO 368

0 REM check address of the connection and allow
363 $0 = $4
364 B = strcmp $7
365 IF B <> 0 THEN 384

0 REM slave connected
0 REM allow DSR interrupts
0 REM green and blue LEDS on
0 REM read sensors
368 A = nextsns 1
369 B = pioset ($8[1]-48)
370 B = pioset ($8[0]-48)
0 REM set RS232 power to on
371 A = pioset ($8[4]-48)
0 REM DTR set on, +5V
372 A = pioclr ($8[5]-48)
0 REM allow DSR interrupts
373 A = pioirq $14
0 REM connect RS232 to slave
374 IF $9[1]= 49 THEN 386
0 REM 376 A = baud I
375 ALARM 0
376 C = link 1
377 RETURN

380 PRINTU"\n\rCONNECTED\n\r
381 $3[3] = 53
382 GOTO 370

0 REM disconnect and exit
384 A = disconnect 0
385 RETURN

386 C = shell
387 RETURN

@MASTER 389
0 REM successful master connection
389 IF $9[2] = 48 THEN 391 
390 PRINTU "@MASTER\n\r";
391 IF $3[0] > 52 THEN 910
0 REM if we are on manual master, then we have some requests
392 IF $3[3] <> 52 THEN 397
393 $3[3] = 54
394 A = pioset ($8[1]-48);
395 A = pioset ($8[0]-48);
396 GOTO 407
0 REM if we are not on master modes, then we must avoid this connection.
397 IF $3[0] > 50 THEN 402;
398 IF $3[0] > 48 THEN 417;
399 IF $3[0] = 48 THEN 417;
402 A = pioset ($8[1]-48);
403 A = pioset ($8[0]-48);
0 REM don't switch state in service mode or manual
404 IF $3[3] = 52 THEN 414
405 IF $3[1] = 49 THEN 407
0 REM set state master paired
406 $3[0] = 52

0 REM read sensors
407 A = nextsns 1
408 A = pioset ($8[4]-48);
0 REM DTR set on
409 A = pioclr ($8[5]-48);
0 REM link
410 A = link 2
0 REM look for disconnect
411 ALARM 5
0 REM allow DSR interrupts
412 A = pioirq $14
413 RETURN

414 PRINTU"\n\rCONNECTED\n\r
415 $3[4] = 54
416 GOTO 407

417 A = disconnect 1
418 RETURN

0 REM $419 RESERVED
419 RESERVED
0 REM inquiry code, only in mode pair_as_master
@INQUIRY 420
420 $419 = $0
421 IF $9[2] = 48 THEN 423
422 PRINTU "@INQUIRY\n\r";
423 IF $3[3] <> 51 THEN 430
424 PRINTU"\n\rFound device: "
425 PRINTU $419
426 ALARM 4
427 RETURN

430 $4 = $419;
431 $419 = $0[13];
432 IF $3[0] <> 51 THEN 435;
0 REM inquiry filter active
433 IF $3[2] = 48 THEN 435;
434 IF $3[2] = 49 THEN 440;
435 RETURN

440 IF $9[2] = 48 THEN 443;
441 PRINTU "found "
442 PRINTU $4
0 REM check name of device
443 $0[0]=0;
444 PRINTV $419;
445 B = strcmp $5;
446 IF B <> 0 THEN 454;

0 REM found one, try to connect, inquiry canceled automaticall
0 REM 447 GOSUB 485;
448 B = master $4;
0 REM if master busy keep stored address in $4, get next
449 IF B = 0 THEN 460;
0 REM master accepted, store address, restart alarms, give it 8 seconds to connect
0 REM corrected by mn
450 $7 = $4;
451 ALARM 8;
0 REM all on to indicate we have one
452 A = pioset ($8[1]-48);
453 A = pioset ($8[0]-48);
454 RETURN

0 REM get next result, give the inq result at least 2 sec time
460 GOSUB 485;
461 RETURN

0 REM blink sub-routine pair as master mode, blue-on green-off and reverse
485 IF J = 1 THEN 490;
486 J = 1;
487 A = pioset ($8[0]-48);
488 A = pioclr ($8[1]-48);
489 RETURN
490 A = pioclr ($8[0]-48);
491 A = pioset ($8[0]-48);
492 J = 0;
493 RETURN;

@CONTROL 495
0 REM remote request for DTR pin on the RS232
495 IF $0[0] < 128 THEN 498
496 A = uartcfg$0[0]
497 RETURN
498 IF $0[0] = 49 THEN 500;
499 A=pioset ($8[5]-48);
500 RETURN;
501 A=pioclr ($8[5]-48);
502 RETURN

@UART 507
507 IF $9[2] = 48 THEN 509
508 PRINTU"@UART\n\r
509 A = uartint
510 $0[0] = 0;
511 TIMEOUTU 5
512 INPUTU $0;
514 A = strlen $0;
515 IF $0[A-3] <> 43 THEN 517
0 REM command line interface active
516 IF $0[A-1] = 43 THEN 520
517 A = uartint;
518 RETURN

520 $3[3] = 49
521 ALARM 1
522 A = enable 3
523 RETURN



0 REM read from uart and echo function
0 REM on line 940 we have the other uart echo function.
0 REM result is on $529
0 REM 528, 529 RESERVED FOR TEMP
528 RESERVED
529 RESERVED
530 A = 1;
531 $529[0] = 0;
532 UART A;
533 IF $0[0] = 13 THEN 541;
534 $528 = $0;
535 PRINTU $0;
536 $0[0] = 0;
537 PRINTV $529;
538 PRINTV $528;
539 $529 = $0;
540 GOTO 532;
541 RETURN

0 REM command line interface
545 ALARM 0
546 A = baud 1152
547 A = pioclr ($8[0]-48);
548 A = pioclr ($8[1]-48);
549 $3[3] = 49
0 REM enable FTP again
550 A = enable 3
551 PRINTU "\r\nAIRcable OS "
552 PRINTU "command line v
553 PRINTU $1
554 PRINTU "\r\nType h to "
555 PRINTU "see the list of "
556 PRINTU "commands";
557 PRINTU "\n\rAIRcable> "
558 GOSUB 776;
559 PRINTU"\n\r

0 REM h: help, l: list,
0 REM n: name, p: pin, b: name filter, g: address filter
0 REM c: class of device, u: uart, d: date,
0 REM s: slave, i: inquiry, m: master, a: mode
0 REM o: obex
0 REM e: exit

0 REM help
560 IF $529[0] = 104 THEN 692;
0 REM info
561 IF $529[0] = 108 THEN 591;
0 REM name
562 IF $529[0] = 110 THEN 706;
0 REM pin
563 IF $529[0] = 112 THEN 716;
0 REM class
564 IF $529[0] = 99 THEN 720;
0 REM uart
565 IF $529[0] = 117 THEN 617;
0 REM date
566 IF $529[0] = 100 THEN 746;
0 REM inquiry
567 IF $529[0] = 105 THEN 820;
0 REM slave
568 IF $529[0] = 115 THEN 845;
0 REM master
569 IF $529[0] = 109 THEN 830;
0 REM obex
570 IF $529[0] = 111 THEN 756;
0 REM modes
571 IF $529[0] = 97 THEN 630;
0 REM exit
572 IF $529[0] = 101 THEN 584;
0 REM name filter
573 IF $529[0] = 98 THEN 736;
0 REM addr filter
574 IF $529[0] = 103 THEN 741;
0 REM hidden debug settings
575 IF $529[0] = 122 THEN 580;
0 REM reboot
576 IF $529[0] = 114 THEN 782;
0 REM relay mode pair
577 IF $529[0] = 106 THEN 865;
578 PRINTU"Command not found
579 GOTO 557;

580 PRINTU"Input settings: "
581 GOSUB 530
582 $9 = $529
583 GOTO 557

0 REM exit code, we end with slave-1 to ensure
0 REM that @SLAVE starts all again, and that
0 REM we start unvisible
584 PRINTU "Bye!!\n\r
585 GOSUB 105;
586 $3[3] = 48;
587 A = slave -1;
588 A = uartint
589 A = zerocnt
590 RETURN

0 REM ----------------------- Listing Code ------------------------------------
591 PRINTU"Command Line v
592 PRINTU $1
593 PRINTU"\n\rName: ";
594 PRINTU $10;
595 PRINTU"\n\rPin: ";
596 PRINTU$11;
597 A = psget 0;
598 PRINTU"\n\rClass: ";
599 PRINTU $0;
600 PRINTU"\n\rBaud Rate: "
601 GOSUB 624
602 PRINTU"\n\rDate: ";
603 A = date $0;
604 PRINTU $0;
605 A = getaddr;
606 PRINTU"\n\rBT Address:
607 PRINTU $0
608 GOSUB 1000;
609 PRINTU"\n\rBT Status:
610 PRINTU $44;
611 PRINTU"\n\rName Filter:
612 PRINTU $5;
613 PRINTU"\n\rAddr Filter:
614 PRINTU $6;
615 GOSUB 671
616 GOTO 557;

617 PRINTU"Enter new Baud Ra
618 PRINTU"te divide by 100,
619 PRINTU"or 0 for switches
620 PRINTU": "
621 GOSUB 530
622 $15 = $529
623 GOTO 557

624 IF $15[0] = 48 THEN 628
625 PRINTU $15
626 PRINTU "00 bps
627 RETURN
628 PRINTU "External
629 RETURN

0 REM -------------------------- Modes chooser --------------------------------
0 REM the user should select between
0 REM 0: Manual
0 REM 1: Service Slave
0 REM 2: Service Master
0 REM 3: Cable Slave
0 REM 4: Cable Master
0 REM 5: Master Relay Mode
0 REM Mode:
630 PRINTU"Select new mode\n
631 PRINTU"\r0: Manual\n\r1:
632 PRINTU" Service Slave\n
633 PRINTU"\r2: Service Mast
634 PRINTU"er\n\r3: Cable Sl
635 PRINTU"ave\n\r4: Cable M
636 PRINTU"aster\n\r5: Maste
637 PRINTU"r Relay Mode\n\rM
638 PRINTU"ode: "
639 GOSUB 776;
640 IF $529[0] = 48 THEN 648;
641 IF $529[0] = 49 THEN 651;
642 IF $529[0] = 50 THEN 655;
643 IF $529[0] = 51 THEN 659;
644 IF $529[0] = 52 THEN 663;
645 IF $529[0] = 53 THEN 667;
646 PRINTU"\n\rInvalid Option
647 GOTO 557;

648 $3[0]=48;
649 $3[3]=49;
650 GOTO 557;
651 $3[0] = 49;
652 $3[1] = 49;
653 $3[3] = 48;
654 GOTO 557;
655 $3[0] = 51;
656 $3[1] = 49;
657 $3[3] = 48;
658 GOTO 557;
659 $3[0] = 49;
660 $3[1] = 48;
661 $3[3] = 48;
662 GOTO 557;
663 $3[0] = 51;
664 $3[2] = 49;
665 $3[3] = 48;
666 GOTO 557;
667 $3[0] = 53;
668 $3[1] = 50;
669 $3[2] = 48;
670 GOTO 557

0 REM -------------------------- Listing code ---------------------------------
671 PRINTU "\n\rMode: "
672 IF $3[0] > 52 THEN 690
673 IF $3[0] = 48 THEN 688
674 IF $3[1] = 48 THEN 677
675 PRINTU"Service - "
676 GOTO 678;
677 PRINTU"Cable - "
678 IF $3[0] >= 51 THEN 681;
679 PRINTU"Slave"
680 GOTO 682;
681 PRINTU"Master"
682 IF $3[0] = 50 THEN 686;
683 IF $3[0] = 52 THEN 686;
684 PRINTU"\n\rUnpaired"
685 RETURN
686 PRINTU"\n\rPaired"
687 RETURN
688 PRINTU"Idle"
689 RETURN
690 PRINTU"Relay Mode Master
691 RETURN

0 REM ----------------------- Help code ---------------------------------------
0 REM h: help, l: list,
0 REM n: name, p: pin, b: name filter, g: address filter
0 REM c: class of device, u: uart, d: date,
0 REM s: slave, i: inquiry, m: master, a: mode
0 REM o: obex, f: obexftp, j: relay mode pair
0 REM e: exit, r: reboot
692 PRINTU"h: help, l: li
693 PRINTU"st\n\rn: name, p: "
694 PRINTU"pin, b: name filte
695 PRINTU"r, g: address filt
696 PRINTU"er\n\rc: class of "
697 PRINTU"device, u: uart, d
698 PRINTU": date\n\rs: slav
699 PRINTU"e, i: inquiry, m: "
700 PRINTU"master, a: mode\n
701 PRINTU"\ro: obex, j: relay
702 PRINTU" mode pair\n\re: ex
703 PRINTU"it, r: reboot
704 GOTO 557;

0 REM Name Function
706 PRINTU"New Name: "
707 GOSUB 530;
708 $10 = $529;
709 $0[0] = 0;
710 PRINTV $10;
711 PRINTV " ";
712 A = getuniq $44;
713 PRINTV $44;
714 A = name $0;
715 GOTO 557

0 REM Pin Function
716 PRINTU"New PIN: ";
717 GOSUB 530;
718 $11 = $529;
719 GOTO 557

720 PRINTU"Type the class of "
721 PRINTU"device as xxxx xxx"
722 PRINTU"x: "
723 GOSUB 530
724 $0[0] = 0;
725 PRINTV"@0000 =
726 PRINTV$529;
727 $529 = $0;
728 A = psget 0;
729 $528 =$0
730 $0[0]=0;
731 PRINTV $529;
732 $529 = $528[17]
733 PRINTV $529;
734 A = psset 3
735 GOTO 557

0 REM friendly name filter code
736 PRINTU"Enter the new name"
737 PRINTU" filter: "
738 GOSUB 530
739 $5 = $529
740 GOTO 557;

0 REM addr filter code
741 PRINTU"Enter the new addr"
742 PRINTU"ess filter: "
743 GOSUB 530
744 $6 = $529
745 GOTO 557

0 REM date changing methods
746 PRINTU"Insert new dat
747 PRINTU"e, check the manua
748 PRINTU"l for formating: "
749 GOSUB 530;
750 A = strlen $529
751 IF A <> 16 THEN 754
752 A = setdate $529
753 GOTO 557
754 PRINTU"\n\rInvalid format
755 GOTO 557

0 REM activate Obex/ObexFTP
0 REM 0 Enabled only on command line
0 REM 1 Always enabled
0 REM 2 Always Disabled
756 PRINTU"Obex/ObexFTP setti
757 PRINTU"ngs:\n\r0: Enabled
758 PRINTU"only on command li
759 PRINTU"ne\n\r1: Always Ena
760 PRINTU"bled\n\r2: Always D
761 PRINTU"isabled\n\rChoose
762 PRINTU"Option: "
763 GOSUB 776
764 939 $9[3] = $529[0]
765 IF $529[0] = 50 THEN 771
766 $0[0] = 0
767 A = psget 6
768 $0[11] = 48
769 A = psset 3
770 GOTO 557
771 $0[0] = 0
772 A = psget 6
773 $0[11] = 54
774 A = psset 3
775 GOTO 557

0 REM one char read function
776 A = 1
777 $529[0] = 0;
778 UART A
779 PRINTU $0
780 $529 = $0
781 RETURN

0 REM reboot code
782 PRINTU"Rebooting, please "
783 PRINTU"do not disconnect "
784 PRINTU"electric power\n\r
785 $3[3] = 48
786 A = reboot
787 WAIT 2
788 RETURN

0 REM ---------------------- Manual Modes code --------------------------------
789 PRINTU "\n\rThere is BT
790 PRINTU "activity, please
791 PRINTU "wait and try agai
792 PRINTU "n
793 GOTO 557;

0 REM Led STUFF for manual 
794 IF $3[3] = 50 THEN 803
795 IF $3[3] = 51 THEN 808
796 IF $3[3] = 52 THEN 815
0 REM command line has just started?
797 IF $3[3] = 49 THEN 545
798 IF $3[3] = 54 THEN 800
799 RETURN

800 A = pioclr ($8[0]-48);
801 A = pioclr ($8[1]-48);
802 GOTO 557

0 REM slave connecting leds
803 A = pioset ($8[1]-48);
804 A = pioset ($8[0]-48)
805 A = pioclr ($8[0]-48)
806 ALARM 4
807 GOTO 853

0 REM inq leds
808 A = pioset ($8[0]-48);
809 A = pioset ($8[1]-48)
810 A = pioclr ($8[0]-48);
811 A = pioclr ($8[1]-48);
812 ALARM 2
813 GOTO 853


0 REM this line is part of the relay mode
814 A = zerocnt
0 REM master connecting leds
815 A = pioset ($8[0]-48);
816 A = pioset ($8[1]-48)
817 A = pioclr ($8[1]-48);
818 ALARM 4
819 GOTO 853

0 REM inquiry code
0 REM by default we inquiry for 10 seconds
820 GOSUB 1000;
821 IF $44[0] = 49 THEN 789
822 PRINTU"Inquirying for
823 PRINTU" 16s. Please wait.
824 B = inquiry 10
825 $3[3] = 51;
826 GOSUB 1000;
827 A = zerocnt
828 A = nextsns 0
829 GOTO 808;

0 REM master code
830 GOSUB 1000;
831 IF $44[3] = 49 THEN 789
832 PRINTU"Please input "
833 PRINTU"the addr of your "
834 PRINTU"peer:
835 GOSUB 530
836 B = strlen$529
837 IF B<>12 THEN 842
838 $3[3] = 52;
839 B = master $529
840 B = zerocnt
841 GOTO 815

842 PRINTU"Invalid add
843 PRINTU"r, try again.
844 GOTO 557;

0 REM slave code
0 REM manual slave
0 REM by default we open the slave channel for 60 seconds
845 GOSUB 1000;
846 IF $44[4] = 49 THEN 789
847 PRINTU"Slave Open for
848 PRINTU" 16s. Please wait.
849 $3[3] = 50
850 A = slave 15
851 A = zerocnt
852 GOTO 803


0 REM timeout for any manual mode, as this part of the code
0 REM will be called as soon as the slave channel is opened
0 REM we check for activity firstly
853 B = readcnt
854 IF B < 16 THEN 864
855 $3[3] = 49
856 ALARM 0
857 A = cancel
858 A = disconnect 0
859 A = disconnect 1
860 A = pioclr ($8[0]-48)
861 A = pioclr ($8[1]-48)
862 A = nextsns 4
863 GOTO 557

864 RETURN

0 REM ---------------------------- RELAY CODE ----------------------------------

0 REM relay mode pair
0 REM Enter the address of your peer: 
865 PRINTU"Enter the address "
866 PRINTU"of your peer: "
867 GOSUB 530;
868 A = strlen $529;
869 IF A = 12 THEN 872;
870 PRINTU"\n\rNot valid peer
871 GOTO 557
872 PRINTU"\n\rTrying to pair
873 $3[0] = 53;
874 $3[3] = 48;
875 $20 = $529
876 A = zerocnt
877 A = master $20
878 GOTO 815

0 REM relay mode alarm handler
0 REM first check for command line
890 IF $3[3] <> 48 THEN 545
891 ALARM 5
892 IF $3[0] = 53 THEN 815
893 B = status
894 IF $3[0] = 54 THEN 209
895 IF B < 1 THEN 207
896 IF $3[0] = 55 THEN 216
897 IF B > 10 THEN 244
898 A = disconnect 0
899 A = disconnect 1
900 $3[0] = 54
901 GOTO 509

910 IF $3[0] = 53 THEN 917
911 A = pioset ($8[1]-48);
912 A = pioset ($8[0]-48);
913 $3[0] = 56
914 A = link 3;
915 ALARM 4
916 RETURN
917 $3[0]=54
918 A = disconnect 1
919 PRINTU"\n\rPair successfull"
920 PRINTU"\n\rPlease choose "
921 PRINTU"which kind of relay"
922 PRINTU"you want:\n\r1: Serv"
923 PRINTU"ice Relay\n\r2: Cabl"
924 PRINTU"e Relay\n\rMode: "
925 ALARM 0
926 GOSUB 776
927 IF $529[0] = 49 THEN 931
928 IF $529[0] = 50 THEN 931
929 PRINTU"\n\rInvalid Option
930 GOTO 920
931 A = $529[0];
932 $3[4] = A;
933 $3[0] = 54;
934 GOTO 557

950 $3[0] = 55
951 GOTO 215

952 B = readcnt;
953 IF $3[4] = 50 THEN 956
954 A = slave 8;
955 RETURN
956 IF B < 120 THEN 954
957 A = slave -8;
958 RETURN

0 REM -------------------------- END RELAY CODE --------------------------------

0 REM convert status to a string
0 REM store the result on $44
1000 B = status
1001 $44[0] = 0;
1002 $44 = "00000";
1003 IF B < 10000 THEN 1006;
1004 $44[0] = 49;
1005 B = B -10000;
1006 IF B < 1000 THEN 1009;
1007 $44[1] = 49;
1008 B = B -1000;
1009 IF B < 100 THEN 1012;
1010 $44[2] = 49; 
1011 B = B -100;
1012 IF B < 10 THEN 1015;
1013 $44[3] = 49;
1014 B = B -10;
1015 IF B < 1 THEN 1017;
1016 $44[4] = 49;
1017 $44[5] = 0;
1018 RETURN


