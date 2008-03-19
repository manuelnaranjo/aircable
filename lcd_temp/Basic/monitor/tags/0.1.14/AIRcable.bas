@ERASE

0 REM PIO LIST:
0 REM 1 IR OFF
0 REM 2 RIGHT BUTTON
0 REM 3 LEFT BUTTON
0 REM 4 LASER
0 REM 9 GREEN LED
0 REM 12 MIDDLE BUTTON
0 REM 20 BLUE LED
0 REM 5 hardware support DEEP SLEEP

0 REM Y used for reading
0 REM X used for calibration
0 REM W used for button
0 REM V used for debug menu
0 REM U used for lcd state
0 REM T, R used for i2c
0 REM S shows deep sleep state
0 REM P is messages interval
0 REM Q is prescaled counter for messages
0 REM O is prescaled counter for updates
0 REM N message flag
0 REM M battery message flag
0 REM L used in some parts of the code as temp
0 REM K ambient sensor available
0 REM J used in @SENSOR
0 REM I hardware supports deep sleep
0 REM H increments on every minute that passes
0 REM ABCDEFG

0 REM S = 1 sleeping
0 REM S = 0 not sleeping

0 REM $1 reserved for i2c
0 REM $2 is for button state
0 REM $3 is for peer BT address
0 REM $4 messages rate, default 15
0 REM $5 used for ice water compensation
0 REM $6 used for LCD contrast storage
0 REM $7 used for type of sensor
0 REM $8 last showed message
0 REM $9 0 for ºF, 1 for ºC

0 REM $15 code version
0 REM $16 device name
0 REM $17 Welcome message
0 REM $18 reserved

0 REM $10 - $14 types of sensor
0 REM $20 min value to compare
0 REM $21 max value to compare

0 REM $22 deep sleep irqs
0 REM $23 working irqs

0 REM $24 update counter it counts from 21 (!)
0 REM to 121 (y)

0 REM $25 last battery reading

0 REM $26 temp

1 
2 
0 REM 3 0050C2585088
3
4 15
5 420
6 200
7 K
8 WAIT
9 0

10 K
11 IR
12 RESERVED
13 RESERVED
14 RESERVED

15 0.1.14
16 SMARTauto
17 SMART

20 RESERVED
21 RESERVED


22 P000000000001
23 P011000000001

24 !

25 0000
26 

@INIT 38
38 A = uarton
39 A = baud 1152
40 Z = 0

0 REM set ADC amplification
41 $0 = "@0008 = 07d0 03E8"
42 A = psset 2

0 REM mark we don't have ambient sensor
43 K = 0

0 REM check if we can do deep sleep
0 REM I = 1 no deep sleep hardware
0 REM I = 0 hardware has deep sleep
45 A = pioclr 5
46 A = pioin 5
47 A = pioset 5
48 I = pioget 5
49 A = pioout 5
50 A = pioclr 5

0 REM 50 A = disable 3
0 REM LED output and on
51 A = pioout 9
52 A = pioset 9

0 REM LCD contrast between 160 and 260
53 L = atoi $6
54 IF L > 260 THEN 57
55 IF L = 0 THEN 57
56 GOTO 61
57 L = 200
58 $0[0] = 0
59 PRINTV L
60 $6 = $0
0 REM LCD bias
61 A = auxdac L

0 REM show welcome message
62 $0[0] = 0
63 PRINTV $17
64 PRINTV" "
65 PRINTV $7
66 PRINTV"         "
67 A = lcd $0

0 REM set name
69 A = getuniq $18
70 $0 = $16
71 PRINTV " "
72 PRINTV $18
73 A = name $0

0 REM initialize buttons 
0 REM PIO2 right, PIO3 left, PIO12 middle
0 REM PIO12 goes high when pressed, add 
74 A = pioin 12
75 A = pioclr 12
0 REM right button
76 A = pioin 2
77 A = pioset 2
78 A = pioin 3
79 A = pioset 3

0 REM non deep sleep while booting please
80 GOSUB 990

0 REM button state variable
81 W = 0

82 A = zerocnt

0 REM ice water compensation
83 X = atoi $5[0]
84 IF X > 700 THEN 87
85 IF X = 0 THEN 87
86 GOTO 91
87 X = 460
88 $0[0] = 0
89 PRINTV X
90 $5 = $0

0 REM reading rate restore
91 P = atoi $4
92 IF P > 90 THEN 95
93 IF P = 0 THEN 95
94 GOTO 99
95 P = 0
96 $0[0] = 0
97 PRINTV P
98 $4 = $0
0 REM P is prescalled, it's supposed to be a multiple
0 REM of five
99 P = P / 5

0 REM start up
0 REM reset counter
100 Q = 0;
0 REM reset minute counter
101 H = 0;

0 REM mark we are booting
102 U = 1000
0 REM mark first battery meassure in two a minute
103 A = nextsns 120
104 M = 1


0 REM laset pio out and high
105 A = pioset 4
106 A = pioout 4

108 IF $540[0]<>0 THEN 118
109 $540="BT ADDR "
110 $541="PEER BT "
111 $542="CONTRAST"
112 $543="PROBE   "
113 $544="CALIBRAT"
114 $545="MSG RATE"
115 $546="%F \ %C "
116 $547="UPDATE    "

0 REM reset prescalled counter
118 Q = 0

0 REM clear message flag
119 N = 0

0 REM check update
120 IF $24[0] >= 57 THEN 936

121 ALARM 5
122 GOSUB 1010
122 RETURN


0 REM buttons and power
@PIO_IRQ 125
0 REM press button starts alarm for long press recognition
125 IF $0[2]=48 THEN 130;
126 IF $0[3]=48 THEN 130;
127 IF $0[12]=49 THEN 130;
0 REM was it a release, handle it
128 IF W <> 0 THEN 310;
129 RETURN

0 REM button press, save state, start ALARM
130 IF I = 1 THEN 132
131 IF S = 1 THEN 136
132 $2 = $0;
133 W = 1;
134 ALARM 3
135 RETURN

0 REM leave deep sleep
136 GOSUB 990
137 ALARM 60;
138 A = pioset 9;
139 GOSUB 400
140 W = 0
141 RETURN


0 REM @ALARM handler
@ALARM 143
143 A = pioset 9;
144 A = pioclr 9

0 REM @INIT doesn't call disable, time to do it.
145 A = disable 3

0 REM first boot?
146 IF U <> 1000 THEN 151
147 Q = 0
148 A = zerocnt
149 A = strlen $3
150 IF A >= 12 THEN 197

0 REM Menu been displayed?
151 IF U <> 0 THEN 550

0 REM check for long button press
152 IF W = 1 THEN 265

0 REM one minute passed?
153 A = readcnt
154 IF A >= 60 THEN 165
155 IF A < 0 THEN 165

0 REM we support deep sleep
156 IF I = 1 THEN 158

0 REM we can do deep sleep,
0 REM and we need to sleep
157 GOSUB 1000

0 REM next alarm in 30 seconds
158 ALARM 30
159 A = pioclr 9
160 RETURN 

0 REM no button press
0 REM update screen
165 GOSUB 990
166 H = H + 1
168 A = zerocnt

0 REM time to send message?
169 IF H >= 5 THEN 197

0 REM we keep showing the temperature
0 REM for the next 5 seconds
170 ALARM 5
171 RETURN

0 REM first update screen
197 A = lcd "WAIT. . . "
198 GOSUB 400
0 REM then reset minute counter, check prescalled
0 REM counter
0 REM increment prescalled counter, and check it
199 H = 0
200 A = zerocnt
201 Q = Q + 1;
202 A = $24[0]+1;
203 $24[0] = A ;

0 REM only message if paired
204 A = strlen $3
205 IF A < 12 THEN 810

206 IF Q >= P THEN 210
207 IF $24[0] >= 57 THEN 936

208 IF U = 1000 THEN 210

0 REM
209 GOTO 158

210 IF N = 0 THEN 212
211 GOTO 207

0 REM send message, check for status first
212 A = status
213 IF A >= 1000 THEN 800

214 N = 1
215 Q = 0
216 U = 0

0 REM prevent any possible interrupt
225 ALARM 0
226 A = pioirq"P000000000000"
227 GOSUB 450;

228 A =pioset 20

229 $0[0]=0;
230 PRINTV"$";
231 PRINTV $25
232 PRINTV ":";
233 PRINTV Y;
234 PRINTV"!";
235 PRINTV X;
236 PRINTV"#";
237 PRINTV $7;
238 PRINTV"#"
239 PRINTV K


240 A = message $3;
241 A = zerocnt
242 A = lcd " MESSAGE"
243 WAIT 10

0 REM check message transmission
244 C = status
245 IF C < 1000 THEN 250
246 GOTO 243

250 A = pioclr 20
251 A = success
252 IF A > 0 THEN 255
253 A = lcd " FAILED "
254 GOTO 256
 

0 REM ---------------------------
255 A = lcd "   OK   "
256 N = 0
257 WAIT 2
0 REM show last temp again
258 A = lcd $8
259 ALARM 5
260 A = pioirq $23
261 RETURN


0 REM long button press
265 A = pioget 12;
266 B = pioget 2;
267 C = pioget 3;
0 REM M = power off
0 REM M + R = visible
0 REM R + L = debug panel
268 IF B = 0 THEN 286;
269 IF A = 1 THEN 275;
0 REM ignore other long presses
270 W = 0;
271 GOTO 206

0 REM exit
275 A = lcd "GOOD BYE";
276 ALARM 0;
277 A = pioget 12;
278 IF A = 1 THEN 277;
279 A = pioclr 9;
280 A = lcd;
281 A = reboot;
282 FOR E = 0 TO 10;
283   WAIT 1
284 NEXT E;
285 RETURN

0 REM combinations handler
286 IF A = 1 THEN 290;
287 IF C = 0 THEN 300;
288 GOTO 270

0 REM discoverable for 2 minutes
290 A = slave 120;
291 A = enable 1;
292 A = lcd "VISIBLE     ";
293 ALARM 120
294 W = 0
295 RETURN

0 REM debug mode
300 A = lcd"MENU        ";
301 WAIT 2;
302 U = 10;
303 V = 0;
304 $2="00000000000000"
305 GOTO 550

0 REM short press handler
0 REM right, left, middle
310 W = 0
311 ALARM 30
312 IF U <> 0 THEN 560;
313 IF $2[2] = 48 THEN 330;
314 IF $2[3] = 48 THEN 320;
315 IF $2[12] = 49 THEN 325;
316 GOTO 204

0 REM send current temp
320 A = strlen $3
321 IF A < 12 THEN 334
322 A = lcd "WAIT . . . "
323 GOTO 212

0 REM show current temp
325 A = lcd "WAIT . . . "
326 GOSUB 400
327 ALARM 30
328 RETURN

0 REM show batteries level
330 A = lcd "WAIT . . . "
331 U = 100
332 M = 1
333 A = nextsns 1
334 ALARM 30
335 RETURN


@SENSOR 339
0 REM prevent deep sleep
339 A = uarton
340 IF M <> 0 THEN 390;
341 A = pioset 9;
342 A = sensor $25;
343 V = atoi $25;
344 IF V <= 2100 THEN 380;
345 IF U = 100 THEN 360;
0 REM meassure again in 60 minutes
346 M = 1;
347 A = nextsns 3600;
348 U = 0
349 B = atoi $25[5]
350 $25[4] = 0
351 IF B < 400 THEN 354
352 X = (B - 500) * 2
353 K = 1
354 A = pioclr 9
355 RETURN

360 U = 0;
361 J = 0;
362 IF V < 3000 THEN 364;
363 J = J + 20;
364 IF V < 2820 THEN 366;
365 J = J + 20;
366 IF V < 2640 THEN 368;
367 J = J + 20;
368 IF V < 2460 THEN 370;
369 J = J + 20;
370 IF V < 2280 THEN 372;
371 J = J + 20;
372 $0="BAT 
373 PRINTV J;
374 PRINTV"    
375 A = lcd $0;
376 GOTO 347; 

380 $26="LOW BATT";
381 A = lcd $26;
382 A = ring;
383 WAIT 2
384 GOTO 346

390 ALARM 20
391 M = M -1;
392 RETURN

0 REM display temp handler ------
400 GOSUB 450
401 IF $7[0] = 73 THEN 420;
402 $0="T ";
403 Y = Y + X;
404 Y = Y / 20;

0 REM show in ºF or ºC?
405 IF $9[0]=49 THEN 412;
0 REM convert to ºF
406 Y = Y * 9;
407 Y = Y / 5;
408 Y = Y + 32;
409 PRINTV Y;
410 PRINTV"%F         ";
411 GOTO 415;

0 REM display ºC
412 PRINTV Y;
413 PRINTV"%C         ";


0 REM save temp string. then display
415 $8 = $0;
416 A = lcd $8;
417 RETURN

0 REM IR sensor
420 $0 ="IR. ";
421 IF Y  <= -32000 THEN 445;
0 REM ºF or ºC?
422 IF $9[0]=49 THEN 435;
423 Y = Y * 9;
424 Y = Y / 5;
425 Y = Y + 320;
426 C = Y / 10;
427 PRINTV C;
428 PRINTV".";
429 D = C * 10;
430 D = Y-D;
431 PRINTV D;
432 A = pioset 1;
433 GOTO 410;

435 C = Y / 10;
436 PRINTV C;
437 PRINTV".";
438 D = C * 10;
439 D = Y-D;
440 PRINTV D;
441 A = pioset 1;
442 GOTO 413;

445 $0="ERR READ";
446 A = lcd $0;
447 RETURN

0 REM I2C sensor reading handler
450 IF $7[0] = 75 THEN 460;
451 IF $7[0] = 73 THEN 479;
452 Y = 0;
453 RETURN

0 REM K sensor connected to MCP3421
460 R = 0;
0 REM 461 A=ring
462 T = 1;
0 REM slave address is 0xD0
463 $1[0] = 208;
464 $1[1] = 143;
465 A = i2c $1;
466 $0[0] = 0;
467 $0[1] = 0;
468 $0[2] = 0;
469 $0[3] = 0;

470 $1[0] = 208;
471 T = 0;
472 R = 4;
473 A = i2c $1;
474 Y = $0[1] * 256;
475 Y = Y + $0[2];
476 RETURN

0 REM laser on
479 A = pioclr 4;
0 REM read IR Temp module
480 A = pioout 1;
0 REM 481 A = ring
482 A = pioclr 1;
0 REM temp is in Kelvin
0 REM substract 273.15 to get Celsius
0 REM temp / 0.02 is K
0 REM F = address: 6 is ambient, 7 object
483 F = 7;
0 REM E is repeat limit
484 E = 0;
485 $0[0] = 0;
486 $0[1] = 0;
487 $0[2] = 0;
488 R = 3;
489 T = 1;
0 REM slave address 0x5A
490 $1[0] = 180;
0 REM command read RAM addr 0x06
491 $1[1] = F;
492 A = i2c $1;
493 E = E + 1;
0 REM read until good reading
494 IF E > 10 THEN 508;
495 IF A <> 6 THEN 485;
496 IF $0[2] = 255 THEN 485;
497 IF $0[2] = 0 THEN 485;

0 REM calculate temp, limit 380 C
498 B = $0[1];
499 IF B > 127 THEN 508;
500 B = B * 256;
501 B = B + $0[0];
502 B = B - 13658;
503 B = B / 5;

504 Y = B;
505 A = pioset 1;
0 REM laser off
506 A = pioset 4;
507 RETURN

0 REM failed reading
508 A = pioset 1;
0 REM laser off
509 A = pioset 4;
510 Y = -32000;
511 RETURN


0 REM DEBUG MENU
0 REM 540 to 549 RESERVED!!!
540 
541 
542 
543 

550 IF V > 7 THEN 555;
551 A = lcd $(540 + V);
552 RETURN

555 A = lcd"EXIT     ";
556 RETURN

0 REM debug mode handler
560 IF U = 20 THEN 626
561 IF U = 30 THEN 656
562 IF U = 40 THEN 737
563 IF U = 50 THEN 770
0 REM right left middle
564 IF $2[2] = 48 THEN 570;
565 IF $2[3] = 48 THEN 580;
566 IF $2[12] = 49 THEN 590;
567 RETURN

570 IF V > 7 THEN 573
571 V = V + 1
572 GOTO 550

573 V = 0
574 GOTO 550

580 IF V < 1 THEN 583
581 V = V - 1
582 GOTO 550

583 V = 8
584 GOTO 550

0 REM option choosen
590 ALARM 0
0 REM own addr
591 IF V = 0 THEN 605
0 REM peer addr
592 IF V = 1 THEN 611
0 REM contrast
593 IF V = 2 THEN 620
0 REM probe
594 IF V = 3 THEN 650
0 REM calibrate
595 IF V = 4 THEN 670
0 REM message rate
596 IF V = 5 THEN 730
0 REM ºF / ºC
597 IF V = 6 THEN 760
0 REM launch update
598 IF V = 7 THEN 936
599 U = 0
600 ALARM 1
601 RETURN

0 REM own addr
605 A = getaddr
606 FOR B = 0 TO 4
607 A = lcd $0[B]
608 WAIT 1
609 NEXT B
610 RETURN

0 REM peer addr
611 A = strlen $3
612 IF A < 12 THEN 615
613 $0 = $3
614 GOTO 606

615 A = lcd"NO PEER "
616 RETURN

0 REM contrast
620 $0="TEST 
621 PRINTV L
622 A = auxdac L
623 A = lcd$0
624 U = 20
625 RETURN

626 IF $2[2] = 48 THEN 630;
627 IF $2[3] = 48 THEN 635;
628 IF $2[12] = 49 THEN 640;
629 RETURN

630 IF L > 260 THEN 620
631 L = L + 10
632 GOTO 620

635 IF L < 160 THEN 620
636 L = L - 10
637 GOTO 620

640 U = 10
641 $0[0]=0
642 PRINTV L
643 $6 = $0
644 ALARM 1
645 RETURN

650 U = 30
651 J = 0

652 $0 = $(10+J)
653 PRINTV"            "
654 A = lcd $0
655 RETURN

0 REM probe selector
656 IF $2[2] = 48 THEN 660;
657 IF $2[3] = 48 THEN 662;
658 IF $2[12] = 49 THEN 665;
659 RETURN

660 J = 0
661 GOTO 652

662 J = 1
663 GOTO 652

665 $7 = $(10+J)
666 U = 10
667 ALARM 1
668 RETURN

0 REM calibration
670 IF $7[0] <> 75 THEN 720
671 ALARM 0
672 $0[0] = 0
673 PRINTV"           PUT PR"
674 PRINTV"OBE IN ICEWATER" 

675 E = strlen $0
676 FOR D = 1 TO 2
677  FOR C = 1 TO E -8
678   A = lcd$0[C];
679  NEXT C;
680  WAIT 1
681 NEXT D
682 $0[0] = 0
683 PRINTV "        STIRR"
684 PRINTV " FOR 30 SECONDS "
685 E = strlen $0
686 FOR C = 1 TO E -8
687   A = lcd$0[C];
688 NEXT C;
689 WAIT 1

690 D = 30
691 $0[0] = 0
692 PRINTV"STIRR "
693 PRINTV D
694 PRINTV"    "
695 A = lcd $0

0 REM check buttons because we cannot get PIO interrupts here
0 REM we do that instead of 1 sec wait
0 REM 474 WAIT 1 << no can do

696 FOR F = 0 TO 3
697  A = pioget 12;
698  IF A = 1 THEN 712;
699  A = pioget 2;
700  IF A = 0 THEN 712;
701  A = pioget 3;
702  IF A = 0 THEN 712;
703 NEXT F;

704 GOSUB 460                      
705 Y = -Y;
706 $0="C "
707 PRINTV Y
708 PRINTV"          "

709 A = lcd $0;

710 D = D -2;
711 IF D > 0 THEN 691;

712 $0 = "DONE "
713 PRINTV Y
714 PRINTV"          "
715 A = lcd $0

0 REM store X persistently
716 $0[0] = 0
717 PRINTV Y
718 $5 = $0
719 X = Y
720 U = 10
721 ALARM 1
722 RETURN

0 REM message rate
730 U = 40
731 P = P * 5

732 $0[0] = 0
733 PRINTV P
734 PRINTV" MIN         "
735 A = lcd $0
736 RETURN

737 IF $2[2] = 48 THEN 741;
738 IF $2[3] = 48 THEN 744;
739 IF $2[12] = 49 THEN 747;
740 RETURN

741 IF P > 55 THEN 732
742 P = P + 5
743 GOTO 732

744 IF P < 5 THEN 732
745 P = P - 5
746 GOTO 732

747 U = 10
748 $0[0]=0
749 PRINTV P
750 $4 = $0
751 P = P / 5
752 ALARM 1
753 RETURN

0 REM ºF / ºC changer
760 U = 50
761 J = 0

762 IF J > 0 THEN 766
763 A = lcd "%F              "
764 ALARM 0
765 RETURN

766 A = lcd "%C              "
767 GOTO 764

0 REM right left middle
770 IF $2[2] = 48 THEN 775;
771 IF $2[3] = 48 THEN 777;
772 IF $2[12] = 49 THEN 779; 
773 RETURN

775 J = 0
776 GOTO 762

777 J = 1
778 GOTO 762

779 $0[0] = 0
780 PRINTV J
781 $9=$0
782 U = 10
783 ALARM 1
784 RETURN

0 REM print errors
0 REM --- print status
800 $0="ST "
801 PRINTV A
802 PRINTV"        "
803 B = lcd $0
804 GOTO 158

0 REM --- print not paired
810 A = lcd"NOT PAIRED"
811 GOTO 156

0 REM do we need this at all???
@CONTROL 910
0 REM remote request for DTR, disconnect
910 IF $0[0] = 49 THEN 912;
911 REM A = disconnect 1
912 RETURN 

@SLAVE 920
0 REM LED on
920 ALARM 0
921 Q = 0
922 A = pioset 20
923 A = shell
924 RETURN


0 REM slave for 60 seconds after boot
0 REM then stop FTP too
@IDLE 929
929 IF U=1001 THEN 934
930 A = pioset 9;
931 A = disable 3;
932 ALARM 2;
933 A = pioclr 9;
934 RETURN

0 REM prepare for updates
936 A = pioirq"P000000000000"
937 ALARM 0
938 A = strlen $3;
939 IF A < 12 THEN 985;
940 IF N <> 0 THEN 976;
941 N = 1
0 REM make sure battery readings don't bother us
942 A =  nextsns 3600
944 $24 = "!"
945 A = pioset 9;
946 A = uarton;
947 A = lcd "UPDATING.  ";
948 $0="?UPDATE|";
949 PRINTV $3
950 PRINTV "|"
951 PRINTV $4
952 PRINTV "|"
953 PRINTV $5
954 PRINTV "|"
955 PRINTV $6
956 PRINTV "|"
957 PRINTV $7
958 PRINTV "|"
959 PRINTV $9
960 PRINTV "|"
961 PRINTV $15
962 PRINTV "|"
963 PRINTV $16
964 PRINTV "|"
965 PRINTV $17


969 A = zerocnt
970 A = message $3;
971 WAIT 10
972 A = status
973 IF A < 1000 THEN 975
974 GOTO 971
975 A = enable 3;
976 ALARM 60;
977 O = 0;
978 U = 0
979 A = pioirq $23
980 N = 0
981 RETURN

985 A = lcd "not paired"
986 A = pioirq $23
987 ALARM 1
988 RETURN

0 REM disable deep sleep
990 S = 0
991 A = pioirq $23
992 A = uarton
933 A = pioclr 5
994 RETURN

0 REM enable deep sleep
1000 IF I = 1 THEN 1005
1001 S = 1
1002 A = pioirq $22
1003 A = uartoff 
1004 A = pioset 5
1005 RETURN

1010 $0[0] = 0
1011 A = getuniq $0
1011 PRINTV " "
1012 PRINTV $15
1013 PRINTV " "
1014 PRINTV I 
1015 E = strlen $0
1016 FOR B = 0 TO E - 8
1017 A = lcd $0[B]
1018 NEXT B
1019 RETURN


