@ERASE

0 REM PIO LIST:
0 REM 1 IR OFF
0 REM 2 RIGHT BUTTON
0 REM 3 LEFT BUTTON
0 REM 4 LASER
0 REM 9 GREEN LED
0 REM 12 MIDDLE BUTTON
0 REM 20 BLUE LED

0 REM Y used for reading
0 REM X used for calibration
0 REM W used for button
0 REM V used for debug menu
0 REM U used for lcd state
0 REM T, R used for i2c
0 REM ABCDEFGHIJKLMNOPQS

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
0 REM $23 non deep sleep irqs

1 
2 
0 REM 3 0050C2585088
3
4 15
5 540
6 200
7 K
8 XXXºF
9 0

10 K
11 IR
12 RESERVED
13 RESERVED
14 RESERVED

15 0.1.0
16 SMARTauto
17 SMART

20 RESERVED
21 RESERVED


22 P000000000001
23 P011000000001

@INIT 47
47 A = uarton
48 A = baud 1152
49 Z = 0
50 A = disable 3
0 REM LED output and on
51 A = pioout 9
52 A = pioset 9

0 REM LCD contrast between 100 and 200
53 L = atoi $6
54 IF L > 200 THEN 57
55 IF L = 0 THEN 57
56 GOTO 61
57 L = 160
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

0 REM schedule interrupts for deep sleep
80 A = pioirq$23

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
0 REM turn R into minutes
99 P = P * 60

0 REM let's start up
100 Q = 0;
101 ALARM 10
0 REM mark we are booting
102 U = 1000
0 REM mark first battery meassure in half a minute
103 A = nextsns 30
104 N = 1


0 REM laset pio out and high
105 A = pioset 4
106 A = pioout 4
107 A = uartoff
108 IF $540[0]<>0 THEN 115
109 $540="BT ADDR  "
110 $541="PEER BT  "
111 $542="CONTRAST "
112 $543="PROBE    "
113 $544="CALIBRATE"
114 $545="MSG RATE "
115 $546="%F \ %C  "
116 RETURN


0 REM buttons and power
@PIO_IRQ 130
0 REM press button starts alarm for long press recognition
130 IF $0[2]=48 THEN 136;
131 IF $0[3]=48 THEN 136;
132 IF $0[12]=49 THEN 136;
0 REM was it a release, handle it
133 IF W <> 0 THEN 261;
134 RETURN

0 REM button press, save state, start ALARM
136 $2 = $0;
137 W = 1;
138 ALARM 3
139 RETURN



@ALARM 148
148 A = pioset 9;
149 A = uarton;
0 REM check if we just booted, show temp and message
150 IF U = 1000 THEN 160;
0 REM contrast timeout, back to preset value.
151 IF U<> 0 THEN 550;


0 REM display temp handler -----
0 REM check status, if connected trigger
0 REM alarm 10 seconds forward
152 C = status
153 IF C = 0 THEN 160
0 REM in interactive mode check very 10 seconds
154 ALARM 20
155 A = uartoff
156 A = pioclr 9
157 RETURN

160 U = 0;
0 REM long press button recognition
161 IF W = 1 THEN 220

0 REM update temp then display
162 GOSUB 400;
0 REM are we in messaging mode
163 IF P > 0 THEN 170
0 REM not messaging mode, only show temp, allow deep sleep
166 ALARM 60
167 A = uartoff
168 A = pioclr 9
169 RETURN

0 REM we just booted?
170 IF U = 1000 THEN 173
0 REM check timer then
171 A = readcnt
172 IF P > A THEN 166

0 REM get a reading, put it on LCD
173 U = 0
174 A = zerocnt
175 WAIT 2
0 REM are we paired?
176 A = strlen $3
177 IF A < 12 THEN 166

0 REM message handler ------
0 REM prepare OBEX message
180 GOSUB 450;
181 $0[0]=0;
182 PRINTV"$";
183 PRINTV A;
184 PRINTV ":";
185 PRINTV Y;
186 PRINTV"!";
187 PRINTV X;
188 PRINTV"#";
189 PRINTV $7;

190 A = pioset 20

191 A = message $3;
192 A = zerocnt
193 A = lcd " MESSAGE"
194 WAIT 2

0 REM check message transmission
195 C = status
196 IF C < 1000 THEN 199
197 WAIT 2
198 GOTO 195

199 A = pioclr 20
200 A = success
201 IF A > 0 THEN 204
202 A = lcd " FAILED "
203 GOTO 205
 

0 REM ---------------------------
204 A = lcd "   OK   "
205 WAIT 5
0 REM show last temp again, until the processor
0 REM falls to sleep
206 A = lcd $8
0 REM next reading in P seconds
207 GOTO 166



0 REM button handlers -----------------

0 REM long button press
220 A = pioget 12;
221 B = pioget 2;
222 C = pioget 3;
0 REM M = power off
0 REM M + R = visible
0 REM R + L = debug panel
223 IF B = 0 THEN 245;
224 IF A = 1 THEN 230;
0 REM ignore other long presses
225 W = 0;
226 ALARM 1;
227 A = pioclr 9;
228 RETURN

0 REM long button press
230 A = lcd "GOOD BYE";
231 ALARM 0;
232 A = pioget 12;
233 IF A = 1 THEN 232;
234 A = pioclr 9;
235 A = lcd;
236 A = reboot;
237 FOR E = 0 TO 10;
238   WAIT 1;
239 NEXT E;
240 RETURN

0 REM combinations handler
245 IF A = 1 THEN 250;
246 IF C = 0 THEN 255;
247 GOTO 225

0 REM discoverable for 2 minutes
250 A = slave 120;
251 A = enable 1;
252 A = lcd "VISIBLE     ";
253 WAIT 3;
254 GOTO 225

0 REM debug mode
255 A = lcd"MENU        ";
256 WAIT 2;
257 U = 10;
258 V = 0;
259 $2="00000000000000"
260 GOTO 550

0 REM short press handler
0 REM right, left, middle
261 W = 0
262 IF U <> 0 THEN 560;
263 IF $2[2] = 48 THEN 290;
264 IF $2[3] = 48 THEN 270;
265 IF $2[12] = 49 THEN 280;
266 RETURN

0 REM send current temp
270 GOSUB 400
271 GOTO 176

0 REM show current temp
280 GOSUB 400
281 RETURN

0 REM show batteries level
290 U = 100
291 N = 1
292 A = nextsns 1
293 RETURN

@SENSOR 297
297 IF N <> 0 THEN 350;
298 A = pioset 9;
299 A = uarton;
300 A = sensor $0;
301 V = atoi $0;
302 IF U = 100 THEN 310;
303 IF V <= 2100 THEN 330;
0 REM meassure again in 30 minutes
304 N = 1;
305 A = nextsns 1800;
306 A = uartoff;
307 A = pioclr 9
308 RETURN;

310 U = 0;
311 J = 0;
312 IF V < 3000 THEN 314;
313 J = J + 20;
314 IF V < 2820 THEN 316;
315 J = J + 20;
316 IF V < 2640 THEN 318;
317 J = J + 20;
318 IF V < 2460 THEN 320;
319 J = J + 20;
320 IF V < 2100 THEN 322;
321 J = J + 20;
322 $0="BAT 
323 PRINTV J;
324 PRINTV"    
325 A = lcd $0;
326 WAIT 20;
327 GOTO 304; 

330 $0="LOW BATT";
331 A = lcd $0;
332 A = ring;
333 WAIT 1;
334 $0 = "#LB%";
335 PRINTV V;
336 A = strlen $3;
337 IF A < 12 THEN 304;
338 A = pioset 20;
339 A = message $3;
340 WAIT 20
341 A = status;
342 IF A < 100 THEN 344
343 A = disconnect 3;
344 A = pioclr 20
345 GOTO 304;

350 N = N -1;
351 RETURN;

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

550 IF V > 6 THEN 555;
551 A = lcd $(540 + V);
552 RETURN;

555 A = lcd"EXIT     ";
556 RETURN;

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

570 IF V > 6 THEN 573
571 V = V + 1
572 GOTO 550

573 V = 0
574 GOTO 550

580 IF V < 1 THEN 583
581 V = V - 1
582 GOTO 550

583 V = 7
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
598 U = 0
599 ALARM 1
600 A = pioclr 9
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

630 IF L > 220 THEN 620
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

704 D = D -1
705 IF D > 0 THEN 691

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
731 P = P / 60

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
751 P = P * 60
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

0 REM do we need this at all???
@CONTROL 910
0 REM remote request for DTR, disconnect
910 IF $0[0] = 49 THEN 912;
911 REM A = disconnect 1
912 RETURN 

@SLAVE 950
0 REM LED on
950 ALARM 0
951 Q = 0
952 A = pioset 20
953 A = shell
954 RETURN


0 REM slave for 60 seconds after boot
0 REM then stop FTP too
@IDLE 980
980 A = pioset 9;
981 A = disable 3;
982 U = 0;
983 W = 0;
984 ALARM 2;
985 A = pioclr 9;
986 RETURN;

