@ERASE

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
1 CLDIT

0 REM lcd contrast
2 200

0 REM display name
3 AIRcable

0 REM discoverable name
4 AIRsensorSDK

0 REM peer address
5

0 REM pio handler
6 P001100000001

0 REM battery reading
7 0000

0 REM code version
8 SDK.0.1.1

0 REM message rate in seconds (not very precise)
9 1

0 REM sensor code should store message info in
0 REM $10
10 0

0 REM sensor code should store display info in
0 REM $11
11 

0 REM no pioirq
12 P00000000000000

0 REM sensor reading
13 

0 REM pio reading
14 

0 REM 19 is a temporary variable
19 

0 REM sensor code can use from 20 to 29

0 REM non persistance variables -----------------------
0 REM Y = lcd contrast
0 REM X = sensor reading rate
0 REM W = button state
0 REM V = message interval
0 REM U = counter accumulator
0 REM Q = status
0 REM P = @SENSOR flag
0 REM R = inquiry counter
0 REM S = inquiry shift
0 REM T = pioirq flag T = 1 means no irq
0 REM F to L reserved for 'user' sensor code

0 REM END global variables -----------------------------


0 REM display and scroll
30 B = strlen $0
31 $19 = $0
32 FOR D = 1 TO 3
33 FOR C = 1 TO B - 8
34 A = lcd $19[C]
35 NEXT C;
36 WAIT 1
37 NEXT D
38 RETURN

0 REM fill with spaces before displaying
40 $0=$A
41 PRINTV"         "
43 A = lcd $0
44 RETURN

0 REM initializate the device
@INIT 50
50 A = baud 1152
51 Z = 1

0 REM enable lcd
52 Y = atoi $2
53 IF Y > 260 THEN 56
54 IF Y < 0 THEN 56
55 GOTO 60
56 Y = 200
57 $0[0] = 0
58 PRINTV Y 
59 $6 = $0
0 REM LCD bias
60 A = auxdac Y

0 REM show welcome message
61 A = 3
62 GOSUB 40

0 REM setup friendly name
65 A = getuniq $20
66 $0 = $4
67 PRINTV " "
68 PRINTV $19
69 A = name $0

0 REM led setting, green on, blue off
70 A = pioout ($1[3]-64)
71 A = pioset ($1[3]-64)
72 A = pioout ($1[4]-64)
73 A = pioclr ($1[4]-64)

0 REM set up buttons
0 REM left
74 A = pioin  ($1[0]-64) 
75 A = pioset ($1[0]-64)
0 REM right
76 A = pioin  ($1[2]-64)
77 A = pioset ($1[2]-64)
0 REM middle
78 A = pioin  ($1[1]-64)
79 A = pioclr ($1[1]-64)

0 REM show version number
80 A = 8
81 GOSUB 40

0 REM start counters
82 A = zerocnt
83 U = 0

0 REM read message rate
84 V = atoi $9

0 REM mark for botting
85 Q = 100

86 P = 1

87 T = 0
88 A = nextsns 1
89 WAIT 5
90 RETURN

0 REM idle handler
@IDLE 100
100 IF Q = 100 THEN 110
101 A = disable 3
102 IF Q > 0 THEN 104
103 ALARM 1
104 RETURN

0 REM first boot, update display
0 REM visible for 30 seconds
0 REM don't message
110 A = lcd "WAIT . . . "
111 GOSUB 800
112 GOSUB 900
113 A = 11
114 GOSUB 40
115 P = 1
116 A = nextsns 1
117 A = slave 30
118 Q = 0
119 P = 1
120 A = pioirq $6
121 RETURN

0 REM ALARM handler
@ALARM 150

0 REM menu running?
150 IF Q >= 390 THEN 400

0 REM check for long button press
151 IF W <> 0 THEN 350

152 A = pioirq $12

153 A = lcd "WAIT . . . "

0 REM update reading
154 GOSUB 800

0 REM generate friendly value
155 GOSUB 900

156 A = 11
157 GOSUB 40

0 REM we need to automatically message?
158 IF V > 0 THEN 170

0 REM @alarm ended
0 REM trigger again
159 ALARM 15
160 A = pioirq $6
161 A = nextsns 1
162 RETURN

0 REM check for time
170 A = strlen $5
171 IF A < 12 THEN 159
172 A = readcnt
173 IF A > V THEN 180
174 GOTO 159

0 REM we can't send 2 messages at the same time
180 A = status
181 IF A > 1000 THEN 159

0 REM prepare msg
183 A = lcd"MESSAGE     "
184 $0[0] = 0
185 PRINTV"BATT|"
186 PRINTV$7
187 PRINTV"|"
188 PRINTV $10
189 A = message $5
190 WAIT 5

0 REM wait for completion
191 A = status
192 IF A > 1000 THEN 188

193 A = success
194 IF A > 0 THEN 205
195 IF A = 0 THEN 198
196 A = lcd "FAILED      "
197 GOTO 206
198 A = lcd "TIMEOUT     "
199 GOTO 206

205 A = lcd "SUCCESS    "

0 REM leave it on the screen
206 A = zerocnt
207 WAIT 2

208 A = lcd $11
209 GOTO 159

0 REM PIO interrupts
@PIO_IRQ 299
299 IF T = 1 THEN 305;
0 REM button press while in menu?
300 IF Q > 300 THEN 410;
0 REM button press starts long button recognition
301 IF$0[$1[0]-64]=48THEN310;
302 IF$0[$1[1]-64]=49THEN310;
303 IF$0[$1[2]-64]=48THEN310;
0 REM was it a release for a short press?
304 IF W <> 0 THEN 320;
305 RETURN

0 REM this was a new press
310 $14 = $0;
311 W = 1;
312 ALARM 3;
313 RETURN


0 REM button released for a short press
320 W = 0;
321 ALARM 0
0 REM middle send message
322 IF$14[$1[1]-64]=49THEN330;
323 IF$14[$1[0]-64]=48THEN110;
324 IF$14[$1[2]-64]=48THEN340;
325 RETURN

0 REM short left button press: message
330 A = strlen $5;
331 GOSUB 800
332 IF A > 11 THEN 183;
333 RETURN

0 REM short left button press: battery reading
340 $0 = "BATT "
341 PRINTV $7
342 GOTO 41

0 REM long button press handler
0 REM long left device menu
0 REM long middle off
0 REM long right visible
350 W = 0
351 IF$14[$1[0]-64]=48THEN385;
352 IF$14[$1[1]-64]=49THEN370;
353 IF$14[$1[2]-64]=48THEN360;
354 RETURN

0 REM make it visible, enable services
360 A = lcd "VISIBLE  "
361 A = slave 120
362 ALARM 0
362 A = enable 3
363 RETURN

0 REM turn off
370 A = lcd "GOOD BYE";
371 ALARM 0;
372 A = pioset($1[3]-64)
373 A = pioclr($1[3]-64);
374 A = pioget($1[1]-64);
375 IF A = 1 THEN 372;
376 A = pioclr($1[4]-64);
377 A = lcd;
378 A = reboot;
379 FOR E = 0 TO 10;
380   WAIT 1
381 NEXT E;
382 RETURN

0 REM menu prepare
385 Q = 390
386 GOTO 400

0 REM options to show
390 ADDRESS
391 PEER
392 CONTRAST
393 RATE
394 INQUIRY
395 EXIT

400 IF Q = 520 THEN 640
401 A = pioirq $6
402 A = Q
403 T = 0
404 GOTO 40

0 REM menu button manager
410 ALARM 0;
411 IF Q = 500 THEN 480;
412 IF Q = 510 THEN 520;
413 IF Q = 520 THEN 570;
414 IF$0[$1[0]-64]=48THEN420;
415 IF$0[$1[1]-64]=49THEN440;
416 IF$0[$1[2]-64]=48THEN430;
417 RETURN

0 REM decrease
420 IF Q < 391 THEN 423
421 Q = Q - 1
422 GOTO 400

423 Q = 395
424 GOTO 400

0 REM increase
430 IF Q > 394 THEN 433
431 Q = Q + 1
432 GOTO 400

433 Q = 390
434 GOTO 400

0 REM option selected
0 REM self address
440 IF Q = 390 THEN 450
0 REM peer address
441 IF Q = 391 THEN 460
0 REM contrast
442 IF Q = 392 THEN 470
0 REM message rate
443 IF Q = 393 THEN 510
0 REM inquiry
444 IF Q = 394 THEN 560
0 REM exit
445 IF Q = 395 THEN 550
0 REM just in case.
446 RETURN

0 REM show own address
450 A = getaddr
451 GOTO 30

0 REM show peer address
460 A = strlen $5
461 IF A < 12 THEN 465 
462 $0=$5
463 GOTO 30

465 $19="NO PAIR"
466 A = 19
467 GOTO 40

0 REM contrast handler
470 $0="TEST "
471 PRINTV Y
472 PRINTV"    "
473 A = auxdac Y
474 A = lcd $0
475 Q = 500 
476 RETURN

480 IF$0[$1[0]-64]=48THEN490;
481 IF$0[$1[1]-64]=49THEN500;
482 IF$0[$1[2]-64]=48THEN485;
483 RETURN

485 IF Y > 260 THEN 470
486 Y = Y + 10
487 GOTO 470

490 IF Y < 160 THEN 470
491 Y = Y - 10
492 GOTO 470

500 Q = 390
501 $0[0]=0
502 PRINTV Y
503 $2 = $0
504 ALARM 1
505 RETURN

0 REM rate setting
510 $0="SEGS "
511 PRINTV V
512 PRINTV"    "
513 A = lcd $0
514 Q = 510 
515 RETURN

520 IF$0[$1[0]-64]=48THEN530;
521 IF$0[$1[1]-64]=49THEN540;
522 IF$0[$1[2]-64]=48THEN525;
523 RETURN

525 V = V + 10
526 GOTO 510

530 IF V < 0 THEN 535
531 V = V - 10
532 GOTO 510

535 V = 0
536 GOTO 510

540 Q = 390
541 $0[0]=0
542 PRINTV V
543 $9 = $0
544 ALARM 1
545 RETURN

0 REM exit handler
550 Q = 0
551 GOTO 150

0 REM inquiry handler
560 $19="FOUND: "
561 R = 0
562 Q = 520
563 S = 0
564 A = lcd "SCAN. . . "
565 T = 1
566 A = pioirq $12
567 A = inquiry 8
568 ALARM 30
569 RETURN

0 REM inquiry button handler
570 IF$0[$1[0]-64]=48THEN580;
571 IF$0[$1[1]-64]=49THEN610;
572 IF$0[$1[2]-64]=48THEN590;
573 RETURN

0 REM left handler shows previous result
580 IF S = 0 THEN 585;
581 S = S - 1;
582 GOTO 600;

585 S = R+2;
586 GOTO 600;

0 REM right handler shows next result
590 IF S >= R+2 THEN 595;
591 S = S + 1;
592 GOTO 600;

595 S = 0;
596 GOTO 600;

0 REM show on screen
600 A = lcd "            "
601 $0=$(688+S)
602 GOTO 30 

0 REM middle is option chooser
610 IF S < 2 THEN 620
611 $5 = $(688+R)
612 Q = 390
613 ALARM 1
614 RETURN

0 REM cancel or unpair?
620 IF S = 0 THEN 612
0 REM unpair
621 $5 = ""
622 GOTO 612

0 REM inquiry results
@INQUIRY 630
630 $(690+R) = $0;
631 R=R+1;
632 $0=$19;
633 PRINTV R;
634 A = lcd $0
635 RETURN

640 A = pioirq $6
641 T = 0
642 GOTO 600

@SLAVE 650
650 A = pioset($1[4]-64)
651 A = shell
652 RETURN


0 REM 690 TO 699
0 REM for inquiry results
688 CANCEL
689 UNPAIR

0 REM BATTERY READING
@SENSOR 750
750 IF P > 0 THEN 760;

751 A = sensor $13;
752 $7 = $13;
753 $7[4] = 0;
754 RETURN;

0 REM wait for both readings
760 P = P - 1;
761 RETURN;

0 REM 800 put your sensor reading code here
800 $10 = "0000|0000"
801 RETURN

0 REM 900 put your sensor display code here
900 $11 = "READING    "
901 RETURN



