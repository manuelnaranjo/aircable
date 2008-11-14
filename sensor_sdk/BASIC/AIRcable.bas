@ERASE

0 REM this is the common code for both monitor
0 REM and interactive mode

0 REM code structure:
0 REM 1/19   variables
0 REM 20/39 user code jump table
0 REM 40      automatic scrolling display
0 REM @INIT 60
0 REM @IDLE 100
0 REM @SLAVE 140
0 REM @SENSOR 150
0 REM inquiry results from 178 to 199
0 REM @INQUIRY 200
0 REM @PIO_IRQ 210
0 REM @ALARM 250
0 REM settings menu handler 285


0 REM user code is handled with pointers
0 REM we provide some base samples,
0 REM pointers starts at line 20.
0 REM 
0 REM pointers:
0 REM 20 @INIT
0 REM 21 @ALARM (user is responsible of calling 
0 REM 	ALARM for periodic readings)
0 REM 22 @IDLE extra
0 REM 30 sensor reading
0 REM 31 sensor displaying
0 REM 34 left long button press
0 REM 35 middle long button press
0 REM 36 right long button press
0 REM 37 left short button press
0 REM 38 middle short button press
0 REM 39 right short button press

0 REM global variables      -------------------------
0 REM persistance variables -------------------------
0 REM PIO LIST
0 REM this is a simple way to choose pios,
0 REM A = 1, B = 2, C = 3

0 REM left button
0 REM middle button
0 REM rigth button
0 REM green ledF
0 REM blue led
0 REM deep sleep pio
1 CLDIT@

0 REM lcd contrast
2 180

0 REM display name
3 AIRcable

0 REM discoverable name
4 AIRsensorSDK

0 REM peer address
5 RES

0 REM pio handler
6 P001100000001

0 REM battery reading
7 0000

0 REM 8 lcd content
8 RES

0 REM version number
9 SDK.0.1.1

0 REM sensor code should store message info in
0 REM $10
10 0000|0000

0 REM sensor code should store display info in
0 REM $11
11 READING

0 REM no pioirq
12 P00000000000000

0 REM sensor reading
13 RES

0 REM pio reading
14 RES

0 REM address filter
15 0050C2

0 REM message rate in seconds (not very precise)
16 1

0 REM debug
17 0

0 REM uniq
18 RES


0 REM non persistance variables -----------------------
0 REM Y = lcd contrast
0 REM X = sensor reading rate
0 REM W = button state
0 REM V = message interval
0 REM U = counter accumulator
0 REM T = pioirq flag T = 1 means no irq
0 REM S = inquiry shift
0 REM R = inquiry counter
0 REM Q = status
0 REM P = @SENSOR flag
0 REM F to L reserved for 'user' sensor code

0 REM END global variables -----------------------------

0 REM interrupt inputs

0 REM user @INIT pointer
20 RETURN

0 REM user @ALARM pointer
21 GOTO 660;

0 REM user @IDLE
22 RETURN

0 REM sensor reading
30 RETURN

0 REM sensor display
31 RETURN

0 REM left long button press
34 GOTO 600;

0 REM middle long button press
35 GOTO 610;

0 REM right long button press
36 GOTO 620;

0 REM left short button press
37 GOTO 630;

0 REM middle short button press 
38 GOTO 640;

0 REM right short button press
39 GOTO 650;

0 REM display and scroll
40 B = strlen $8
41 PRINTU$8
42 $0 = $8;
43 PRINTV"                  \n";
44 $8 = $0;
45 IF B <= 9 THEN 55
46 FOR D = 1 TO 3
47 FOR C = 0 TO B - 8
48 A = lcd $8[C]
49 NEXT C;
50 WAIT 1
51 NEXT D
52 GOTO 55;

55 A = lcd $8
56 RETURN

0 REM initializate the device
@INIT 60
60 A = baud 1152
61 Z = $17[0]-48

0 REM enable lcd
62 Y = atoi $2
63 IF Y > 260 THEN 66
64 IF Y < 0 THEN 66
65 GOTO 70
66 Y = 200
67 $0[0] = 0
68 PRINTV Y 
69 $0 = $6
0 REM LCD bias
70 A = auxdac Y

0 REM show welcome message
71 $8 = $3
72 GOSUB 40;

0 REM setup friendly name
73 A = getuniq $8
74 $0 = $4
75 PRINTV " "
76 PRINTV $8
77 A = name $0

0 REM led setting, green on, blue off
78 A = pioout ($1[3]-64)
79 A = pioset ($1[3]-64)
80 A = pioout ($1[4]-64)
81 A = pioclr ($1[4]-64)

0 REM set up buttons
0 REM left
82 A = pioin  ($1[0]-64) 
83 A = pioset ($1[0]-64)
0 REM right
84 A = pioin  ($1[2]-64)
85 A = pioset ($1[2]-64)
0 REM middle
86 A = pioin  ($1[1]-64)
87 A = pioclr ($1[1]-64)

0 REM show version number
88 $8 = $9
89 GOSUB 40

0 REM start counters
90 A = zerocnt
91 U = 0

0 REM read message rate
162 V = atoi $16

0 REM mark for botting
93 Q = 100

94 P = 1

95 T = 0
96 A = nextsns 1
97 WAIT 5
98 GOTO 20;

0 REM idle handler
@IDLE 100
100 IF Q = 100 THEN 110
101 A = disable 3
102 IF Q > 0 THEN 104
103 ALARM 1
104 GOTO 22

0 REM first boot, update display
0 REM visible for 30 seconds
0 REM don't message
110 A = lcd "WAIT . . . "
111 GOSUB 30
112 GOSUB 31
113 $8=$11
114 GOSUB 40
115 P = 1
116 A = nextsns 1
117 A = slave 30
118 Q = 0
119 P = 1
120 A = pioirq $6
121 RETURN

0 REM @SLAVE enable shell
0 REM THIS IS NOT SECURE!!! 
0 REM don't use this in production
@SLAVE 140
140 A = pioset($1[4]-64);
141 A = shell;
142 RETURN

0 REM BATTERY READING
@SENSOR 150
150 IF P > 0 THEN 160;

151 A = sensor $13;
152 $7 = $13;
153 $7[4] = 0;
154 RETURN;

0 REM wait for both readings
160 P = P - 1;
161 RETURN;


0 REM we need this so free line calculator
0 REM can do it's job.
178 CANCEL
179 UNPAIR
180 RESULTS
181 RESULTS
182 RESULTS
183 RESULTS
184 RESULTS
185 RESULTS
186 RESULTS
187 RESULTS
188 RESULTS
189 RESULTS
190 RESULTS
191 RESULTS
192 RESULTS
193 RESULTS
194 RESULTS
195 RESULTS
196 RESULTS
197 RESULTS
198 RESULTS
199 RESULTS

0 REM 180 RESULTS
0 REM  ...
0 REM 199 RESULTS
0 REM inquiry results
@INQUIRY 200
0 REM we can store as much as 20 results
200 IF R >= 20 THEN 208;
0 REM check filter
201 A= strcmp $15;
202 IF A <> 0 THEN 208;
0 REM passed, might be a target
203 $(180+R) = $0;
204 R=R+1;
205 $0=$8;
206 PRINTV R;
207 A = lcd $0
208 RETURN

0 REM PIO interrupts
@PIO_IRQ 210
0 REM check for flag
210 IF T = 1 THEN 216;
0 REM button press while in settings menu?
211 IF Q > 200 THEN 310;
0 REM button press starts long button recognition
212 IF$0[$1[0]-64]=48THEN220;
213 IF$0[$1[1]-64]=49THEN220;
214 IF$0[$1[2]-64]=48THEN220;
0 REM was it a release for a short press?
215 IF W <> 0 THEN 225;
216 RETURN

0 REM this was a new press
220 $14 = $0;
221 W = 1;
222 ALARM 3;
223 RETURN


0 REM button released for a short press
225 W = 0;
226 ALARM 0
0 REM left button
227 IF$14[$1[0]-64]=48THEN37;
0 REM middle button
228 IF$14[$1[1]-64]=49THEN38;
0 REM right button
229 IF$14[$1[2]-64]=48THEN39;
230 RETURN


0 REM ALARM handler
@ALARM 250

0 REM settings menu running?
250 IF Q >= 390 THEN 300;

0 REM check for long button press
251 IF W <> 0 THEN 260;

0 REM no more to do on vanilla code we call your
0 REM your code
252 GOTO 21;

0 REM long button press
260 W = 0;
0 REM long left
261 IF$14[$1[0]-64]=48THEN34;
0 REM long middle
262 IF$14[$1[1]-64]=49THEN35;
0 REM long right
263 IF$14[$1[2]-64]=48THEN36;
0 REM should never get here
264 A = lcd "ALRM ERROR      "
265 ALARM 5
266 RETURN


0 REM settings menu handler
0 REM menu prepare
285 Q = 290
286 GOTO 300

0 REM options to show
290 ADDRESS
291 PEER
292 CONTRAST
293 RATE
294 INQUIRY
295 EXIT

300 IF Q = 520 THEN 540;
301 A = pioirq $6;
302 $8=$Q;
303 T = 0;
304 GOTO 40

0 REM menu button manager
310 ALARM 0;
311 IF Q = 500 THEN 380;
312 IF Q = 510 THEN 420;
313 IF Q = 520 THEN 480;
314 IF$0[$1[0]-64]=48THEN320;
315 IF$0[$1[1]-64]=49THEN340;
316 IF$0[$1[2]-64]=48THEN330;
317 RETURN

0 REM decrease
320 IF Q < 291 THEN 323;
321 Q = Q - 1;
322 GOTO 300;

323 Q = 295;
324 GOTO 300;

0 REM increase
330 IF Q > 294 THEN 333;
331 Q = Q + 1;
332 GOTO 300;

333 Q = 290;
334 GOTO 300;

0 REM option selected
0 REM self address
340 IF Q = 290 THEN 350;
0 REM peer address
341 IF Q = 291 THEN 360;
0 REM contrast
342 IF Q = 292 THEN 370;
0 REM message rate
343 IF Q = 293 THEN 410;
0 REM inquiry
344 IF Q = 294 THEN 460;
0 REM exit
345 IF Q = 295 THEN 450;
0 REM just in case.
346 A = lcd"MENU ERROR"
347 RETURN

0 REM show own address
350 A = getaddr $8;
351 GOSUB 40;
352 WAIT 3
353 GOTO 300

0 REM show peer address
360 A = strlen $5;
361 IF A < 12 THEN 365; 
362 $8=$5;
363 GOSUB 40;
364 GOTO 352

365 $8="NO PAIR";
366 GOTO 363

0 REM contrast handler
370 $0="TEST "
371 PRINTV Y;
372 PRINTV"    "
373 A = auxdac Y;
374 A = lcd $0;
375 Q = 500 ;
376 RETURN

380 IF$0[$1[0]-64]=48THEN390;
381 IF$0[$1[1]-64]=49THEN400;
382 IF$0[$1[2]-64]=48THEN385;
383 RETURN

385 IF Y > 260 THEN 370;
386 Y = Y + 10;
387 GOTO 370;

390 IF Y < 160 THEN 370;
391 Y = Y - 10;
392 GOTO 370;

400 Q = 290;
401 $0[0]=0;
402 PRINTV Y;
403 $2 = $0;
404 ALARM 1;
405 RETURN

0 REM rate setting
410 $0="SEGS ";
411 PRINTV V;
412 PRINTV"    ";
413 A = lcd $0;
414 Q = 510 ;
415 RETURN

420 IF$0[$1[0]-64]=48THEN430;
421 IF$0[$1[1]-64]=49THEN440;
422 IF$0[$1[2]-64]=48THEN425;
423 RETURN

425 V = V + 10;
426 GOTO 410;

430 IF V < 0 THEN 435;
431 V = V - 10;
432 GOTO 410;

435 V = 0;
436 GOTO 410;

440 Q = 290;
441 $0[0]=0;
442 PRINTV V;
443 $16 = $0;
444 ALARM 1;
445 RETURN

0 REM exit handler
450 Q = 0;
451 A=lcd"BYE       "
452 ALARM 1
453 RETURN

0 REM inquiry handler
460 $8="FOUND "
461 R = 0;
462 Q = 520;
463 S = 0;
464 A = lcd "SCAN. . . ";
465 T = 1;
466 A = pioirq $12;
467 A = inquiry 9;
468 ALARM 30;
469 RETURN

0 REM inquiry button handler
480 IF$0[$1[0]-64]=48THEN490;
481 IF$0[$1[1]-64]=49THEN520;
482 IF$0[$1[2]-64]=48THEN505;
483 RETURN

0 REM left handler shows previous result
490 IF S = 0 THEN 500;
491 S = S - 1;
492 GOTO 515;

500 S = R+2;
501 GOTO 515;

0 REM right handler shows next result
505 IF S >= R+1 THEN 510;
506 S = S + 1;
507 GOTO 515;

510 S = 0;
511 GOTO 515;

0 REM show on screen
515 A = lcd "            ";
516 $8=$(178+S);
517 GOTO 40 

0 REM middle is option chooser
520 IF S < 2 THEN 530;
521 $5 = $(178+S);
522 Q = 290;
523 A = lcd"DONE         "
524 ALARM 3;
525 RETURN

0 REM cancel or unpair?
530 IF S = 0 THEN 522;
0 REM unpair
531 $5 = "";
532 GOTO 522;

540 A = pioirq $6;
541 T = 0;
542 GOTO 515;



0 REM sample handling code

0 REM long button press handlers -------------------------
0 REM don't forget to call ALARM before calling 
0 REM RETURN when needed

600 A = lcd"Long Left "
0 REM we suggess this handler to display settings
0 REM menu
601 ALARM 5
602 RETURN


610 A = lcd"Long Mid  "
0 REM we suggest this handler turn off
611 GOTO 601

620 A = lcd "Long Right"
0 REM we suggest this handler to make visible
621 GOTO 601

0 REM -------------------------------------------------------------------


0 REM short button press handlers -------------------------
0 REM don't forget to call ALARM before calling 
0 REM RETURN

630 A = lcd"Short Left "
631 ALARM 5
632 RETURN


0 REM 700 short middle button handler starts here
640 A = lcd"Short Mid  "
641 GOTO 631

0 REM 730 short left button handler starts here

0 REM 760 short right button handler starts here
650 A = lcd"Short Right"
651 GOTO 631
0 REM -------------------------------------------------------------------


0 REM User ALARM code, user is responsable
0 REM of calling ALARM again.
660 ALARM 15
661 RETURN

