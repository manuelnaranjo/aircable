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
0 REM S used for <monitor> (state)
0 REM O used for <monitor> (probe)
0 REM N used for <monitor> (reading)                       
0 REM M used for <monitor> (max val)
0 REM L used for <monitor> (min val)
0 REM K amount of options in the menu 
0 REM J used in @SENSOR 
0 REM I temporary temperature
0 REM H noexit enabled
0 REM ABCDEFG

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

0 REM $22 wake up interrupt (not used)
0 REM $23 non deep sleep interrupts
0 REM $24 middle button not enabled while showing
0 REM 	TAKE TEMP

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
11 I
12 RESERVED
13 RESERVED
14 RESERVED

15 0.5
16 SMARTinteractive
17 SMART

20 RESERVED
21 RESERVED

22 P000000000001
23 P011000000001
24 P011000000000

@INIT 45
45 A = uarton
46 A = baud 1152
47 Z = 0
48 A = disable 3
0 REM LED output and on
49 A = pioout 9
50 A = pioset 9

0 REM LCD contrast between 100 and 200
51 L = atoi $6
52 IF L > 260 THEN 55
53 IF L = 0 THEN 55
54 GOTO 59
55 L = 200
56 $0[0] = 0
57 PRINTV L
58 $6 = $0
0 REM LCD bias
59 A = auxdac L

0 REM show welcome message
60 $0[0] = 0
61 PRINTV $17
62 PRINTV" "
63 PRINTV $7
64 PRINTV"         "
65 A = lcd $0

0 REM set name
66 A = getuniq $18
67 $0 = $16
68 PRINTV " "
69 PRINTV $18
70 A = name $0

0 REM initialize buttons 
0 REM PIO2 right, PIO3 left, PIO12 middle
0 REM PIO12 goes high when pressed, add 
71 A = pioin 12
72 A = pioclr 12
0 REM right button
73 A = pioin 2
74 A = pioset 2
0 REM left button
75 A = pioin 3
76 A = pioset 3

0 REM IR sensor
77 A = pioout 1
78 A = pioclr 1

0 REM button state variable
79 W = 0

0 REM ice water compensation
81 X = atoi $5[0]
82 IF X > 700 THEN 85
83 IF X = 0 THEN 85
84 GOTO 89
85 X = 460
86 $0[0] = 0
87 PRINTV X
88 $5 = $0

89 A = strlen $3
90 IF A >= 12 THEN 100
91 C = lcd"NOT PAIR


0 REM let's start up
97 Q = 0;
0 REM 101 ALARM 10
0 REM mark we are booting
98 U = 1000

0 REM laset pio out and high
100 A = pioset 4
101 A = pioout 4

102 A = uartoff
103 IF $480[0]<>0 THEN 113
104 $480="BT ADDR  "
105 $481="PEER BT  "
106 $482="CONTRAST "
107 $483="PROBE    "
108 $484="CALIBRATE"
109 $486="%F \ %C  "
110 $487="INQUIRY  "
111 $488="PAIR     "
112 $489="BATT    "

0 REM restart counter
113 A = zerocnt
0 REM schedule interrupts.
114  A = pioirq $23
0 REM schedule battery readings
115 A = nextsns 1
116 RETURN


0 REM buttons and power
@PIO_IRQ 120
120 A = zerocnt;

0 REM press button starts alarm for long press recognition
122 IF $0[2]=48 THEN 130;
123 IF $0[3]=48 THEN 130;
124 IF $0[12]=49 THEN 130;
0 REM was it a release, handle it
125 IF W <> 0 THEN 140;
126 RETURN

0 REM button press, save state, start ALARM
130 $2 = $0;
131 W = 1;
132 ALARM 3
133 RETURN


140 IF U < 200 THEN 200;
141 A = status;
142 IF A > 9 THEN 200;
143 A = lcd"Disconnected";
144 U = 0;
145 ALARM 10;
146 W = 0;
147 RETURN

0 REM button handlers -----------------

0 REM long button press
150 A = pioget 12;
151 B = pioget 2;
152 C = pioget 3;
0 REM M = power off
0 REM M + R = visible
0 REM R + L = debug panel
153 IF B = 0 THEN 180;
154 IF A = 1 THEN 160;
0 REM ignore other long presses
155 W = 0;
156 ALARM 1;
157 RETURN

0 REM long button press
160 A = lcd "GOOD BYE"
161 ALARM 0;
162 A = pioget 12;
163 IF A = 1 THEN 162;
164 A = lcd;
165 A = reboot;
166 FOR E = 0 TO 10
167   WAIT 1
168 NEXT E
169 RETURN

0 REM combinations handler
180 IF A = 1 THEN 185;
181 IF C = 0 THEN 190;
182 GOTO 155;

0 REM discoverable for 2 minutes
185 A = slave 120;
185 A = enable 1;
187 A = lcd "VISIBLE     ";
188 WAIT 3
189 GOTO 155;

0 REM debug mode
190 A = lcd"DEVICE     ";
191 WAIT 2
192 U = 10;
193 V = 0;
194 GOTO 490;

0 REM short press handler
0 REM right, left, middle
200 W = 0;
202 IF U <> 0 THEN 495;
203 A = status;
204 IF A > 1 THEN 208;
205 IF $2[2] = 48 THEN 225;
206 IF $2[3] = 48 THEN 235;
207 IF $2[12] = 49 THEN 210;
208 ALARM 60;
209 RETURN

0 REM connect to peer
210 A = strlen $3;
211 IF A < 12 THEN 220;
212 A = master $3;
213 U = 1;
214 ALARM 20;
215 A = lcd"CONNECTING"
217 RETURN

220 A = lcd"NOT PAIRED"
221 ALARM 60;
222 RETURN

0 REM show current temp on IR
225 A = lcd"WAIT. . .   ";
226 GOSUB 440;
227 I = Y;
228 ALARM 30;
229 GOTO 380;

0 REM show current temp on K
235 A = lcd"WAIT. . .   ";
236 GOSUB 420;
237 I = Y;
238 ALARM 30;
239 GOTO 362 ;



@ALARM 240
240 A = pioset 9;
241 A = uarton;

242 IF U >= 200 THEN 264;
243 IF U = 1 THEN 270;
244 IF U <> 0 THEN 260;
245 IF W = 1 THEN 150;
246 A = lcd"READY        ";
247 A = readcnt;
248 IF A >= 180 THEN 160;

260 ALARM 30;
261 N = 1;
262 A = pioclr 20;
263 RETURN

264 A = readcnt;
265 IF A > 300 THEN 280;
266 IF U = 301 THEN 796;
267 ALARM 10;
268 RETURN

270 A = lcd "Failed    ";
271 U = 0;
272 ALARM 10
273 RETURN

280 PRINTM"\x03";
281 A = lcd "Timeout";
282 WAIT 5
283 GOTO 160;

@SENSOR 300
300 IF N = 2 THEN 335;
301 A = sensor $0;
302 V = atoi $0;
303 J = 0;
304 IF V < 3000 THEN 306;
305 J = J + 20;
306 IF V < 2820 THEN 308;
307 J = J + 20;
308 IF V < 2640 THEN 310;
309 J = J + 20;
310 IF V < 2460 THEN 312;
311 J = J + 20;
312 IF V < 2100 THEN 314;
313 J = J + 20;
314 $0="BAT 
315 PRINTV J;
316 PRINTV"    
317 A = lcd $0;
318 ALARM 2
319 IF J > 30 THEN 321;
320 A = ring;
321 RETURN


335 N = 1;
336 RETURN

0 REM display temp handler ------
360 GOSUB 410;
361 IF $7[0] = 73 THEN 380;
362 $0="K ";
363 Y = Y + X;
364 Y = Y / 20;

0 REM show in ºF or ºC?
365 IF $9[0]=49 THEN 372;
0 REM convert to ºF
366 Y = Y * 9;
367 Y = Y / 5;
368 Y = Y + 32;
369 PRINTV Y;
370 PRINTV"%F         ";
371 GOTO 374;

0 REM display ºC
372 PRINTV Y;
373 PRINTV"%C         ";


0 REM save temp string. then display
374 $8 = $0;
375 A = lcd $8;
376 A = zerocnt;
378 ALARM 10;
379 RETURN

0 REM IR sensor
380 $0 ="IR. ";
381 IF Y  <= -32000 THEN 405;
0 REM ºF or ºC?
382 IF $9[0]=49 THEN 395;
383 Y = Y * 9;
384 Y = Y / 5;
385 Y = Y + 320;
386 C = Y / 10;
387 PRINTV C;
388 PRINTV".";
389 D = C * 10;
390 D = Y-D;
391 PRINTV D;
0 REM 392 A = pioset 1
393 GOTO 370;

395 C = Y / 10;
396 PRINTV C;
397 PRINTV".";
398 D = C * 10;
399 D = Y-D;
400 PRINTV D;
0 REM 401 A = pioset 1
402 GOTO 373;

405 A = lcd"ERR READ"
406 A = zerocnt
407 ALARM 10
408 RETURN

0 REM I2C sensor reading handler
410 IF $7[0] = 75 THEN 420;
411 IF $7[0] = 73 THEN 440;
412 Y = 0;
413 RETURN

0 REM K sensor connected to MCP3421

0 REM tell the MCP4321 to take a reading
420 R = 0;
421 T = 1;
0 REM slave address is 0xD0
422 $1[0] = 208;
423 $1[1] = 143;
424 A = i2c $1;

0 REM read
425 $0[0] = 0;
426 $0[1] = 0;
427 $0[2] = 0;
428 $0[3] = 0;
429 $1[0] = 208;
430 T = 0;
431 R = 4;
432 A = i2c $1;
433 IF $0[3] >= 128 THEN 437;
434 Y = $0[1] * 256;
435 Y = Y + $0[2];
436 RETURN

437 A = lcd"NOT READY";
438 WAIT 1
439 GOTO 425;

0 REM laser on
440 A = pioclr 4;
0 REM read IR Temp module
441 A = pioout 1;
0 REM 481 A = ring
0 REM 442 A = pioclr 1
0 REM temp is in Kelvin
0 REM substract 273.15 to get Celsius
0 REM temp / 0.02 is K
0 REM F = address: 6 is ambient, 7 object
443 F = 6;
0 REM E is repeat limit
444 E = 0;
445 $0[0] = 0;
446 $0[1] = 0;
447 $0[2] = 0;
448 R = 3;
449 T = 1;
0 REM slave address 0x5A
450 $1[0] = 180;
0 REM command read RAM addr 0x06
451 $1[1] = F;
452 A = i2c $1;
453 E = E + 1;
0 REM read until good reading
454 IF E > 10 THEN 468;
455 IF A <> 6 THEN 445;
456 IF $0[2] = 255 THEN 445;
457 IF $0[2] = 0 THEN 445;

0 REM calculate temp, limit 380 C
458 B = $0[1];
459 IF B > 127 THEN 468;
460 B = B * 256;
461 B = B + $0[0];
462 B = B - 13658;
463 B = B / 5;

464 Y = B;
0 REM 465 A = pioset 1
0 REM laser off
466 A = pioset 4;
467 RETURN

0 REM failed reading
468 
0 REM 468 A = pioset 1
0 REM laser off
469 A = pioset 4;
470 Y = -32000;
471 RETURN


0 REM DEBUG MENU
0 REM 480 to 489 RESERVED!!!
480 
481 
482 
483 

490 IF V > 6 THEN 493;
491 A = lcd $(480 + V);
492 RETURN

493 A = lcd"EXIT     ";
494 RETURN

0 REM menu handler
495 IF U > 199 THEN 700;
496 IF U = 20 THEN 546;
497 IF U = 30 THEN 576;
498 IF U = 40 THEN 650;
499 IF U = 50 THEN 680;
0 REM right left middle
500 IF $2[2] = 48 THEN 503;
501 IF $2[3] = 48 THEN 508;
502 IF $2[12] = 49 THEN 515;
503 RETURN

503 IF V > 6 THEN 506;
504 V = V + 1;
505 GOTO 490;

506 V = 0;
507 GOTO 490;

508 IF V < 1 THEN 511;
509 V = V - 1;
510 GOTO 490;

511 V = 7;
512 GOTO 490;

0 REM option choosen
515 ALARM 0
0 REM own addr
516 IF V = 0 THEN 526;
0 REM peer addr
517 IF V = 1 THEN 532;
0 REM contrast
518 IF V = 2 THEN 540;
0 REM probe
519 IF V = 3 THEN 570;
0 REM calibrate
520 IF V = 4 THEN 590;
0 REM message rate
521 IF V = 5 THEN 642;
0 REM ºF / ºC
522 IF V = 6 THEN 670;
523 U = 0
524 ALARM 1
525 RETURN

0 REM own addr
526 A = getaddr;
527 FOR B = 0 TO 4
528 A = lcd $0[B]
529 WAIT 1
530 NEXT B
531 RETURN

0 REM peer addr
532 A = strlen $3
533 IF A < 12 THEN 536
534 $0 = $3
535 GOTO 527

536 A = lcd"NO PEER "
537 RETURN

0 REM contrast
540 $0="TEST 
541 PRINTV L
542 A = auxdac L
543 A = lcd$0
544 U = 20
545 RETURN

546 IF $2[2] = 48 THEN 550;
547 IF $2[3] = 48 THEN 555;
548 IF $2[12] = 49 THEN 560;
549 RETURN

550 IF L > 260 THEN 540
551 L = L + 10
552 GOTO 540

555 IF L < 160 THEN 540
556 L = L - 10
557 GOTO 540

560 U = 10
561 $0[0]=0
562 PRINTV L
563 $6 = $0
564 ALARM 1
565 RETURN

570 U = 30
571 J = 0

572 $0 = $(10+J)
573 PRINTV"            "
574 A = lcd $0
575 RETURN

0 REM probe selector
576 IF $2[2] = 48 THEN 580;
577 IF $2[3] = 48 THEN 582;
578 IF $2[12] = 49 THEN 585;
579 RETURN

580 J = 0
581 GOTO 572

582 J = 1
583 GOTO 572

585 $7 = $(10+J)
586 U = 10
587 ALARM 1
588 RETURN

0 REM calibration
590 IF $7[0] <> 75 THEN 639
591 ALARM 0
592 $0[0] = 0
593 PRINTV"           PUT PR"
594 PRINTV"OBE IN ICEWATER" 

595 E = strlen $0
596 FOR D = 1 TO 2
597  FOR C = 1 TO E -8
598   A = lcd$0[C];
599  NEXT C;
600  WAIT 1
601 NEXT D
602 $0[0] = 0
603 PRINTV "        STIR"
604 PRINTV " FOR 30 SECONDS "
605 E = strlen $0
606 FOR C = 1 TO E -8
607   A = lcd$0[C];
608 NEXT C;
609 WAIT 1

610 D = 30
611 $0[0] = 0
612 PRINTV"STIR "
613 PRINTV D
614 PRINTV"    "
615 A = lcd $0

0 REM check buttons because we cannot get PIO interrupts here
0 REM we do that instead of 1 sec wait
0 REM 474 WAIT 1 << no can do

616 FOR F = 0 TO 3
617  A = pioget 12;
618  IF A = 1 THEN 631;
619  A = pioget 2;
620  IF A = 0 THEN 631;
621  A = pioget 3;
622  IF A = 0 THEN 631;
623 NEXT F;

0 REM read probe, or we will never calibrate anything
624 GOSUB 420
625 Y = -Y
626 $0="C "
627 PRINTV Y
628 PRINTV"          "

629 D = D -1
630 IF D > 0 THEN 611

631 $0 = "DONE "
632 PRINTV Y
633 PRINTV"          "
634 A = lcd $0

0 REM store X persistently
635 $0[0] = 0
636 PRINTV Y
637 $5 = $0
638 X = Y
639 U = 10
640 RETURN

0 REM message rate
642 U = 40
643 P = P / 60

644 $0[0] = 0
645 PRINTV P
646 PRINTV" MIN         "
647 A = LCD $0
648 RETURN

650 IF $2[2] = 48 THEN 654;
651 IF $2[3] = 48 THEN 657;
652 IF $2[12] = 49 THEN 660;
653 RETURN

654 IF P > 55 THEN 644
655 P = P + 5
656 GOTO 644

657 IF P < 5 THEN 644
658 P = P - 5
659 GOTO 644

660 U = 10
661 $0[0]=0
662 PRINTV P
663 $4 = $0
664 P = P * 60
665 ALARM 1
666 RETURN

0 REM ºF / ºC changer
670 U = 50
671 J = 0

672 IF J > 0 THEN 676
673 A = lcd "%F              "
674 ALARM 0
675 RETURN

676 A = lcd "%C              "
677 GOTO 674

0 REM right left middle
680 IF $2[2] = 48 THEN 685;
681 IF $2[3] = 48 THEN 687;
682 IF $2[12] = 49 THEN 689; 
683 RETURN

685 J = 0
686 GOTO 672

687 J = 1
688 GOTO 672

689 $0[0] = 0
690 PRINTV J
691 $9=$0
692 U = 10
693 ALARM 1
694 RETURN

0 REM __________INTERACTIVE MODE_______
@MASTER 695
695 ALARM 0
696 A = lcd "WAIT . . .   "
697 U = 200;
698 A = pioset 20;
699 GOTO 706;

0 REM __interactive mode button handler __
0 REM $MENU code: right, left, middle
700 IF U >= 300 THEN 758;
701 IF $2[2] = 48 THEN 818;
702 IF $2[3] = 48 THEN 823;
703 IF $2[12] = 49 THEN 830;
704 RETURN

0 REM __generate menu __
705 RESERVED
0 REM __send our current temp__
706 A = zerocnt
707 PRINTM"!"
708 GOSUB 410;
709 PRINTM Y;
710 PRINTM ":";
711 PRINTM X;
712 PRINTM "#";
713 PRINTM $7;
714 PRINTM "\n";

0 REM H = 1 noexit
0 REM H = 0 exit
716 H=0

0 REM __ get amount of messages __
717 ALARM 90;
718 TIMEOUTM 60;
719 INPUTM $0;
720 IF $0[0] = 63 THEN 750;
721 IF $0[0] = 37 THEN 725;
722 IF $0[0] = 35 THEN 920;
723 IF $0[0] = 43 THEN 955;
0 REM check if still connected
724 GOTO 900

725 $705 = $0[1]
726 $0 = $705
0 REM M amount of options
727 K = atoi $0;
728 C = 0;
729 IF K > 45 THEN 745;
730 IF K = 0 THEN 745;

0 REM __get each menu entry __
731 TIMEOUTM 20;
732 INPUTM $0;
733 $(960+C)=$0[2];
734 C = C +1;
735 IF C>= K THEN 738;
736 PRINTM"&";
737 GOTO 739;
738 PRINTM"$";
739 A = hex8 C;
740 PRINTM$0;
741 PRINTM"\n";
742 IF C < K THEN 731;
0 REM V is index
0 REM K is amout of messages
743 V = 0;
744 GOTO 800;

745 A = lcd"ERROR. . .    ";
746 A = disconnect 1
747 U = 0;
748 ALARM 10
749 RETURN

0 REM <monitor> handler
0 REM so far there's no need for hexa
750 A = $0[4]-48;
751 PRINTM $0;
752 PRINTM"\n";
0 REM FDISPLAY_TEMP 	1
0 REM FRETURN_TEMP	2
0 REM FCOMPAR_TEMP	4
753 S = A;
754 U = 300;
755 A = lcd "TAKE TEMP";
756 A = pioirq $24;
757 RETURN

0 REM <monitor> button handler
0 REM right, left, middle
0 REM right show temp in IR probe
0 REM left show temp in K probe
0 REM middle send temp, make compare
758 A = pioirq $23;
759 IF U = 301 THEN 796;
760 IF $2[2] = 48 THEN 764;
761 IF $2[3] = 48 THEN 766;
762 IF $2[12] = 49 THEN 769;
763 RETURN

0 REM O = 1 using IR
0 REM O = 2 using K
0 REM O = 3 comparing

0 REM show IR
764 O = 1 ;
765 GOTO 225;

0 REM show K
766 O = 2;
767 GOTO 235;

0 REM send to the server, he knows what to do
769 IF S < 2 THEN 796;
770 ALARM 0;
771 A = lcd "WAIT . . .     ";
772 PRINTM"!";
0 REM use old reading instead of a new one
0 REM 773 IF O = 1 THEN 776
0 REM 774 GOSUB 420
0 REM 775 GOTO 777
0 REM 776 GOSUB 440
773 PRINTM I;
774 PRINTM ":";
775 PRINTM X ;
776 PRINTM "#";
777 IF O = 1 THEN 780;
778 PRINTM"K\n"
779 GOTO 781;
780 PRINTM"I\n"
781 A = zerocnt;
783 IF S < 4 THEN 796;
784 TIMEOUTM 15;
785 INPUTM $0;
786 A = lcd $0[1];
787 WAIT 1
788 IF $0[0] = 48 THEN 790;
789 A = ring;
790 U = 301;
791 ALARM 10;
792 RETURN

796 U = 200;
797 A = lcd"WAIT . . .     ";
798 GOTO 706;

0 REM clear lcd then display menu
800 $0=$(960+V);
801 O = 0;
802 E = strlen $0;
803 PRINTV"           ";
804 IF E < 9 THEN 810
805 FOR B = 0 TO E-5
806 C = lcd $0[B]
807 NEXT B
808 O = O+1;
809 IF O < 2 THEN 805;
810 A = lcd $0;
811 A = zerocnt;
812 ALARM 10
813 RETURN

0 REM if line is empty then we show the
0 REM exit option
815 A = lcd "EXIT     ";
816 V = -1;
817 GOTO 811;

0 REM __right button pressed
818 V = V + 1;
819 IF V = K THEN 910;
821 GOTO 800;

0 REM __left button pressed
823 IF V =-1 THEN 828;
824 IF V = 0 THEN 915;
825 V = V-1;
826 GOTO 800;

828 V = K-1;
829 GOTO 800;

0 REM __middle button pressed
830 IF V = -1 THEN 840;
831 A = lcd"WAIT . . . ";
832 PRINTM "@";
833 A = V+1;
834 B = hex8 A;
835 PRINTM$0;
836 GOTO 706;

0 REM __choose exit, tell NSLU2
840 PRINTM"\x03";
841 A = lcd"Finished";
842 ALARM 3;
843 U = 0;
844 A = pioclr 20;
845 RETURN


@SLAVE 850
0 REM LED on
850 ALARM 0
851 Q = 0
852 A = pioset 20
853 A = shell
854 RETURN

0 REM do we need this at all???
@CONTROL 860
0 REM remote request for DTR, disconnect
860 IF $0[0] = 49 THEN 862;
861 REM A = disconnect 1
862 RETURN 

0 REM slave for 60 seconds after boot
0 REM then stop FTP too
@IDLE 870
870 A = pioclr 9
871 A = pioset 9
872 IF Q = 1 THEN 890
873 IF Q = 2 THEN 894
874 A = slave -1
875 Q = 1
0 REM startup the automatic again
876 IF U = 2 THEN 991
877 U = 0
878 W = 0
879 ALARM 2
880 RETURN

0 REM after some time disable FTP
890 A = disable 3;
891 WAIT 3;
892 A = slave -1;
893 Q = 2;
894 RETURN


0 REM check if we still connected before
0 REM telling the server we need to resync
900 A = status;
901 IF A > 9 THEN 745;
902 U = 0;
903 A = lcd"Disconnected";
904 ALARM 10;
905 RETURN

0 REM end of noexit handler
910 IF H = 0 THEN 815;
911 V = 0;
912 GOTO 800;

915 IF H = 0 THEN 815;
916 GOTO 828;

0 REM generate update message
920 A = lcd "UPDATING"
921 $0[0]=0
922 PRINTV $3
923 PRINTV "|"
924 PRINTV $4
925 PRINTV "|"
926 PRINTV $5
927 PRINTV "|"
928 PRINTV $6
929 PRINTV "|"
930 PRINTV $7
931 PRINTV "|"
932 PRINTV $9
933 PRINTV "|"
934 PRINTV $15
935 PRINTV "|"
936 PRINTV $16
937 PRINTV "|"
938 PRINTV $17
939 PRINTV "\n\r"

945 PRINTM $0
946 A = enable 3;
947 ALARM 60;
948 O = 0;
949 U = 1001
950 RETURN

955 H = 1;
956 GOTO 725;

0 REM 960 and higher used for storing menu values.

