@ERASE

0 REM this is the base code for all the AIRcable OS products
0 REM we take the AIRcable SMD/Mini as our base device

0 REM let's reserve the first 30 lines for internal stuff

0 REM $1 is the version of the command line
1 0.5a

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
0 REM 0 Enabled only on command line
0 REM 1 Always enabled
0 REM 2 Always Disabled
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

0 REM @MASTER part of relay mode, this should be moved !!!!
1050 IF $3[0] = 53 THEN 1057
1051 A = pioset ($8[1]-48);
1052 A = pioset ($8[0]-48);
1053 $3[0] = 56
1054 A = link 3;
1055 ALARM 4
1056 RETURN
1057 $3[0]=54
1058 A = disconnect 1
1059 PRINTU"\n\rPair successful
1060 ALARM 0
1061 GOTO 557

1062 $3[0] = 55
1063 GOTO 215

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
93 GOSUB 799

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
193 IF $3[3] <> 48 THEN 820;
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
204 IF $3[0] = 55 THEN 781
205 A = disconnect 1
206 $3[0] = 54
207 A = uartint
208 B = status
209 IF B > 0 THEN 211
210 A = slave 8
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
233 GOSUB 799

234 IF H = 1 THEN 99

235 IF $3[0] > 52 THEN 845

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
246 IF $3[3] <> 48 THEN 761
0 REM we are on automatic.
0 REM are we on automatic - manual?
247 IF $3[0] = 48 THEN 280
0 REM are we on automatic - service?
248 IF $3[1] = 48 THEN 260

0 REM ok, we are on service mode, are we master or slave?
0 REM both modes have a fast blink in common
0 REM slave  2 fast blink
0 REM master 1 fast blink
249 A = pioset ($8[1]-48);
250 A = pioset ($8[0]-48)
251 A = pioclr ($8[0]-48);
252 IF $3[0] > 50 THEN 256
0 REM we are on service-slave, green on blue fast blink
253 A = pioset ($8[0]-48)
254 A = pioclr ($8[0]-48);
255 GOTO 320

0 REM we are on service-master, blue on, green fast blink
256 GOTO 325

0 REM we are on cable
0 REM both modes have an slow blink in common
0 REM slave  2 slow blink
0 REM master 1 slow blink
260 A = pioset ($8[1]-48)
261 A = pioset ($8[0]-48)
262 A = pioclr ($8[0]-48)
0 REM we are on cable, are we master or slave?
263 IF $3[0] > 50 THEN 340
0 REM we are on cable-slave
264 A = pioset ($8[0]-48)
265 A = pioclr ($8[0]-48)
266 GOTO 340;

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
317 $3[0] = 48;
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
352 IF $3[0] = 54 THEN 1062;
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
391 IF $3[0] > 52 THEN 1050
0 REM if we are on manual master, then we have some requests
392 IF $3[3] = 52 THEN 402
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
546 A = baud 1152
547 A = pioclr ($8[0]-48);
548 A = pioclr ($8[1]-48);
549 $3[3] = 49
0 REM enable FTP again
550 A = enable 3
551 PRINTU "\r\nAIRcable OS "
552 PRINTU "command line v
553 PRINTU $1
554 PRINTU "\r\nType h to
555 PRINTU "see the list of
556 PRINTU "commands";
557 PRINTU "\n\rAIRcable> "
558 GOSUB 805;
559 PRINTU"\n\r

0 REM h: help, l: list,
0 REM n: name, p: pin, b: name filter, g: address filter
0 REM c: class of device, u: uart, d: date,
0 REM s: slave, i: inquiry, m: master, a: mode
0 REM o: obex
0 REM e: exit

0 REM help
560 IF $529[0] = 104 THEN 787;
0 REM info
561 IF $529[0] = 108 THEN 591;
0 REM name
562 IF $529[0] = 110 THEN 801;
0 REM pin
563 IF $529[0] = 112 THEN 811;
0 REM class
564 IF $529[0] = 99 THEN 815;
0 REM uart
565 IF $529[0] = 117 THEN 617;
0 REM date
566 IF $529[0] = 100 THEN 808;
0 REM inquiry
567 IF $529[0] = 105 THEN 787;
0 REM slave
568 IF $529[0] = 115 THEN 812;
0 REM master
569 IF $529[0] = 109 THEN 797;
0 REM obex
570 IF $529[0] = 111 THEN 756;
0 REM modes
571 IF $529[0] = 97 THEN 630;
0 REM exit
572 IF $529[0] = 101 THEN 584;
0 REM name filter
573 IF $529[0] = 98 THEN 798;
0 REM addr filter
574 IF $529[0] = 103 THEN 803;
0 REM hidden debug settings
575 IF $529[0] = 122 THEN 580;
0 REM reboot
576 IF $529[0] = 114 THEN 811;
0 REM relay mode pair
577 IF $529[0] = 106 THEN 832;
578 PRINTU"Command not found
579 GOTO 557;

580 PRINTU"Input settings:
581 GOSUB 530
582 $9 = $529
583 GOTO 557

0 REM exit code, we end with slave-1 to ensure
0 REM that @SLAVE starts all again, and that
0 REM we start unvisible
584 PRINTU "Bye!!\n\r
585 GOSUB 105;
586 $3[3] = 48;
587 A = slave-1;
588 A = uartint
589 A = zerocnt
590 RETURN

0 REM info code
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
615 GOSUB 799
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
638 PRINTU"ode:
639 GOSUB 805;
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
799 PRINTU "\n\rMode: "
800 IF $3[0] > 52 THEN 756
801 IF $3[0] = 48 THEN 816
802 IF $3[1] = 48 THEN 805
803 PRINTU"Service - "
804 GOTO 806;
805 PRINTU"Cable - "
806 IF $3[0] >= 51 THEN 809;
807 PRINTU"Slave"
808 GOTO 810;
809 PRINTU"Master"
810 IF $3[0] = 50 THEN 814;
811 IF $3[0] = 52 THEN 814;
812 PRINTU"\n\rUnpaired"
813 RETURN
814 PRINTU"\n\rPaired"
815 RETURN
816 PRINTU"Idle"
817 RETURN
756 PRINTU"Relay Mode Master
786 RETURN

0 REM ----------------------- Help code ---------------------------------------
0 REM h: help, l: list,
0 REM n: name, p: pin, b: name filter, g: address filter
0 REM c: class of device, u: uart, d: date,
0 REM s: slave, i: inquiry, m: master, a: mode
0 REM o: obex, f: obexftp, j: relay mode pair
0 REM e: exit, r: reboot
787 PRINTU"h: help, l: li
788 PRINTU"st\n\rn: name, p:
789 PRINTU"pin, b: name filte
790 PRINTU"r, g: address filt
791 PRINTU"er\n\rc: class of
792 PRINTU"device, u: uart, d
793 PRINTU": date\n\rs: slav
794 PRINTU"e, i: inquiry, m:
795 PRINTU"master, a: mode\n
796 PRINTU"\ro: obex,
797 PRINTU"j: relay
798 PRINTU"mode pair\n\re: exi
671 PRINTU"t, r: reboot
672 GOTO 557;

0 REM Name Function
673 PRINTU"New Name:
674 GOSUB 530;
675 $10 = $529;
0 REM correct when $0 = $(NUMBER) works
676 $0[0] = 0;
677 PRINTV $10;
678 PRINTV " ";
679 A = getuniq $44;
680 PRINTV $44;
681 A = name $0;
682 GOTO 557

0 REM Pin Function
683 PRINTU"New PIN: ";
684 GOSUB 530;
685 $11 = $529;
686 GOTO 557

687 PRINTU"Type the class of
688 PRINTU"device as xxxx xxx
689 PRINTU"x: "
690 GOSUB 530
691 $0[0] = 0;
692 PRINTV"@0000 =
693 PRINTV$529;
694 $529 = $0;
695 A = psget 0;
696 $528 =$0
697 $0[0]=0;
698 PRINTV $529;
699 $529 = $528[17]
700 PRINTV $529;
701 A = psset 3
702 GOTO 557

0 REM friendly name filter code
703 PRINTU"Enter the new name
704 PRINTU" filter:
705 GOSUB 530
706 $5 = $529
707 GOTO 557;

0 REM addr filter code
708 PRINTU"Enter the new addr
709 PRINTU"ess filter:
710 GOSUB 530
711 $6 = $529
712 GOTO 557

0 REM date changing methods
713 PRINTU"Insert new dat
714 PRINTU"e, check the manua
715 PRINTU"l for formating:
716 GOSUB 530;
717 A = strlen $529
718 IF A <> 16 THEN 721
719 A = setdate $529
720 GOTO 557
721 PRINTU"\n\rInvalid format
722 GOTO 557

0 REM activate Obex/ObexFTP
0 REM 0 Enabled only on command line
0 REM 1 Always enabled
0 REM 2 Always Disabled
723 PRINTU"Obex/ObexFTP setti
724 PRINTU"ngs:\n\r0 Enabled
725 PRINTU"only on command li
726 PRINTU"ne\n\r1 Always Ena
727 PRINTU"bled\n\r2 Always D
728 PRINTU"isabled\n\rChoose
729 PRINTU"Option:
730 GOSUB 743
731 939 $9[3] = $529[0]
732 IF $529[0] = 50 THEN 738
733 $0[0] = 0
734 A = psget 6
735 $0[11] = 48
736 A = psset 3
737 GOTO 557
738 $0[0] = 0
739 A = psget 6
740 $0[11] = 54
741 A = psset 3
742 GOTO 557

0 REM one char read function
743 A = 1
744 $529[0] = 0;
745 UART A
746 PRINTU $0
747 $529 = $0
748 RETURN

0 REM reboot code
749 PRINTU"Rebooting, please
750 PRINTU"do not disconnect
751 PRINTU"electric power\n\r
752 $3[3] = 48
753 A = reboot
754 WAIT 2
755 RETURN

0 REM ---------------------- Manual Modes code --------------------------------

756 PRINTU "\n\rThere is BT
757 PRINTU "activity, please
758 PRINTU "wait and try agai
759 PRINTU "n
760 GOTO 557;

0 REM Led STUFF for manual 
761 IF $3[3] = 50 THEN 770
762 IF $3[3] = 51 THEN 775
763 IF $3[3] = 52 THEN 782
0 REM command line has just started?
764 IF $3[3] = 49 THEN 546
765 IF $3[3] = 54 THEN 767
766 RETURN

767 A = pioclr ($8[0]-48);
768 A = pioclr ($8[1]-48);
769 GOTO 557

0 REM slave connecting leds
770 A = pioset ($8[1]-48);
771 A = pioset ($8[0]-48)
772 A = pioclr ($8[0]-48)
773 ALARM 4
774 GOTO 820

0 REM inq leds
775 A = pioset ($8[0]-48);
776 A = pioset ($8[1]-48)
777 A = pioclr ($8[0]-48);
778 A = pioclr ($8[1]-48);
779 ALARM 2
780 GOTO 820


0 REM this line is part of the relay mode
781 A = zerocnt
0 REM master connecting leds
782 A = pioset ($8[0]-48);
783 A = pioset ($8[1]-48)
784 A = pioclr ($8[1]-48);
785 ALARM 4
786 GOTO 820

0 REM inquiry code
0 REM by default we inquiry for 10 seconds
787 GOSUB 1000;
788 IF $44[0] = 49 THEN 756
789 PRINTU"Inquirying for
790 PRINTU" 16s. Please wait.
791 B = inquiry 10
792 $3[3] = 51;
793 GOSUB 1000;
794 A = zerocnt
795 A = nextsns 0
796 GOTO 775;

0 REM master code
797 GOSUB 1000;
798 IF $44[3] = 49 THEN 756
799 PRINTU"Please input
800 PRINTU"the addr of your
801 PRINTU"peer:
802 GOSUB 530
803 B = strlen$529
804 IF B<>12 THEN 809
805 $3[3] = 52;
806 B = master $529
807 B = zerocnt
808 GOTO 782

809 PRINTU"Invalid add
810 PRINTU"r, try again.
811 GOTO 557;

0 REM slave code
0 REM manual slave
0 REM by default we open the slave channel for 60 seconds
812 GOSUB 1000;
813 IF $44[4] = 49 THEN 756
814 PRINTU"Slave Open for
815 PRINTU" 16s. Please wait.
816 $3[3] = 50
817 A = slave 15
818 A = zerocnt
819 GOTO 770


0 REM timeout for any manual mode, as this part of the code
0 REM will be called as soon as the slave channel is opened
0 REM we check for activity firstly
820 B = readcnt
821 IF B < 16 THEN 831
822 $3[3] = 49
823 ALARM 0
824 A = cancel
825 A = disconnect 0
826 A = disconnect 1
827 A = pioclr ($8[0]-48)
828 A = pioclr ($8[1]-48)
829 A = nextsns 4
830 GOTO 557

831 RETURN

0 REM ---------------------------- RELAY CODE ----------------------------------

0 REM relay mode pair
0 REM Enter the address of your peer: 
832 PRINTU"Enter the address
833 PRINTU"of your peer:
834 GOSUB 530;
835 A = strlen $529;
836 IF A = 12 THEN 839;
837 PRINTU"\n\rNot valid peer
838 GOTO 557
839 PRINTU"\n\rTrying to pair
840 $3[0] = 53;
841 $20 = $529
842 A = zerocnt
843 A = master $20
844 GOTO 782

0 REM relay mode alarm handler
0 REM first check for command line
845 IF $3[3] <> 48 THEN 546
846 ALARM 5
847 IF $3[0] = 53 THEN 782
848 B = status
849 IF $3[0] = 54 THEN 209
850 IF B < 1 THEN 207
851 IF $3[0] = 55 THEN 216
852 IF B > 10 THEN 244
853 A = disconnect 0
854 A = disconnect 1
855 $3[0] = 54
856 GOTO 509

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


