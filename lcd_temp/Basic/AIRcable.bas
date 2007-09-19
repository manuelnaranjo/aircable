@ERASE

0 REM $2 is for button state
0 REM $3 is for peer BT address
0 REM $4 used for transfer rate default disabled
0 REM $5-$8 are 4 menu entries
0 REM $9 used for ice water compensation
0 REM $10 used for LCD contrast storage
0 REM $11 used for type of sensor

0 REM $15 - $19 types of sensor

4 15
3 0050C258501B
5 SENSOR
6 DISCOVER
7 SENDRATE
8 CONTRAST
9 540.
10
11 K

15 K
16 IR
17 RESERVED
18 RESERVED
19 RESERVED

0 REM $20 will store min value to compare
0 REM $21 will store max value to compare
20 RESERVED
21 RESERVED

@INIT 28
28 A = baud 1152
0 REM debug to uart
29 A = disable 2
0 REM LED output and on
30 A = pioout 9
31 A = pioset 9

0 REM LCD contrast between 100 and 200
32 L = atoi $10
33 IF L > 200 THEN 36
34 IF L = 0 THEN 36
35 GOTO 40
36 L = 160
37 $0[0] = 0
38 PRINTV L
39 $10 = $0
0 REM LCD bias
40 A = auxdac L

41 A = lcd " Welcome"
42 A = uartoff
0 REM debug
43 A = name "AIRthermo5"

0 REM initialize buttons 
0 REM PIO2 right, PIO3 left, PIO12 middle
0 REM PIO12 goes high when pressed, add 
45 A = pioin 12
46 A = pioclr 12
0 REM right button
47 A = pioin 2
48 A = pioset 2
49 A = pioin 3
50 A = pioset 3

0 REM schedule interrupts
51 A = pioirq "P011000000001"

0 REM
52 $0="AIRCABLE THERMO TYPE "
53 PRINTV $11
54 A = lcd $0
55 WAIT 1
56 FOR C = 1 TO 15
57   A = lcd $0[C]
58 NEXT C

0 REM button state variable
59 W = 0
0 REM state
60 U = 0

61 A = zerocnt

0 REM strings with spaces
62 $5="SENSOR  "
63 $6="DISCOVER"
64 $7="SENDRATE"
65 $8="CONTRAST"


0 REM ice water compensation
67 X = atoi $9[0]
68 IF X > 700 THEN 71
69 IF X = 0 THEN 71
70 GOTO 75
71 X = 460
72 $0[0] = 0
73 PRINTV X
74 $9 = $0

0 REM reading rate restore
75 P = atoi $4
76 IF P > 90 THEN 79
77 IF P = 0 THEN 79
78 GOTO 83
79 P = 0
80 $0[0] = 0
81 PRINTV P
82 $4 = $0
0 REM turn R into minutes
83 P = P * 60

0 REM let's start up
84 Q = 0;
85 ALARM 5
0 REM mark we are booting
86 U = 1000
87 RETURN


0 REM buttons and power
@PIO_IRQ 89
0 REM press button starts alarm for long press recognition
89 IF $0[2]=48 THEN 95;
90 IF $0[3]=48 THEN 95;
91 IF $0[12]=49 THEN 95;
0 REM ignore button release on rebooting
92 IF W = 3 THEN 94;
0 REM was it a release, handle it
93 IF W <> 0 THEN 200;
94 RETURN

0 REM button press, save state, start ALARM
95 $2 = $0;
96 W = 1;
97 ALARM 3
98 RETURN



@ALARM 99
99 IF U = 1000 THEN 118
0 REM contrast timeout, back to preset value.
100 IF U = 8 THEN 506
0 REM inquiry found none results.
101 IF U = 9 THEN 360
102 IF U <> 2 THEN 107

0 REM interactive mode mode U=2
103 C = status
104 IF C < 10 THEN 107
0 REM in interactive mode check very 10 seconds
105 ALARM 10
106 RETURN

107 U = 0;
0 REM blink
108 A = pioset 20;
109 A = pioclr 20
0 REM long press button
110 IF W = 1 THEN 175
0 REM doing <monitor>
112 IF S > 0 THEN 680
0 REM clear lcd
113 A = lcd "           "
0 REM are we in messaging mode?
114 IF P = 0 THEN 120
0 REM if we are, have we reached timer?
115 A = readcnt
116 IF A > P THEN 119
117 GOTO 162


0 REM get a reading, put it on LCD
118 U = 0
119 A = zerocnt
120 GOSUB 570
0 REM show temp for 2 secs
123 WAIT 2
0 REM messaging mode?
124 IF P = 0 THEN 163
0 REM are we paired?
125 A = strlen $3
126 IF A < 12 THEN 162

0 REM prepare OBEX message
132 GOSUB 545
133 $0[0]=0
134 PRINTV"$"
135 PRINTV A
136 PRINTV ":"
137 PRINTV Y
138 PRINTV"!"
139 PRINTV X
140 PRINTV"#"
141 PRINTV $11

142 A = message $3
143 A = zerocnt
144 A = lcd " MESSAGE"
145 WAIT 2
146 GOTO 154

0 REM check message transmission
150 C = status
151 IF C < 1000 THEN 154
152 WAIT 2
153 GOTO 150

154 A = success
155 IF A > 0 THEN 160
156 A = lcd " FAILED "
157 GOTO 162
 

0 REM ---------------------------
160 A = lcd "   OK   "
161 WAIT 5
162 A = lcd "        "

0 REM next reading in P seconds
164 ALARM 60
0 REM reset slave timeout
165 A = slave 30
0 REM allow deep sleep
166 A = uartoff
167 RETURN




0 REM power button pressed
175 A = pioget 12
176 IF A = 1 THEN 180
0 REM ignore other long presses
177 W = 0
178 ALARM 1
179 RETURN

0 REM long button press
180 A = lcd "GOOD BYE"
181 ALARM 0;
182 A = pioget 12;
183 IF A = 1 THEN 182;
184 A = lcd;
185 W = 3;
186 A = reboot;
187 FOR E = 0 TO 10
188   WAIT 1
189 NEXT E
190 RETURN





0 REM we have button applications
0 REM state variable is U
0 REM U = 0 for main menu
0 REM left means make a streaming connection
0 REM right means shows current temp
0 REM middle means display menu entries

0 REM U = 1 for menu select mode
0 REM right means next entry, cycle through
0 REM left means cancel, back to main menu
0 REM middle means start next application

0 REM U = 2 streaming mode
0 REM any button press disconnects 

0 REM U=5, 6, 7, 8 menu entry start

0 REM U = 10 discovered devices selection

0 REM U = 11 type of sensor chooser

0 REM handle BUTTON RELEASE
0 REM after 30 seconds of no button presses, resume temp display
200 ALARM 30;
201 W = 0;
0 REM display temperature
202 IF U = 0 THEN 212;
0 REM show menu
203 IF U = 1 THEN 240;
0 REM interactive mode
204 IF U = 2 THEN 565;

0 REM 5-8 display the menu
205 IF U = 5 THEN 211;
0 REM start inquiry
206 IF U = 6 THEN 280;
0 REM message rate
207 IF U = 7 THEN 300;
0 REM LCD contrast
208 IF U = 8 THEN 485;
0 REM show discovered results
209 IF U = 10 THEN 330;
0 REM type of sensor chooser
210 IF U = 11 THEN 515;
211 RETURN

0 REM state ________________________U = 0
0 REM $MENU code: right, left, middle
212 IF $2[2] = 48 THEN 220;
213 IF $2[3] = 48 THEN 216;
214 IF $2[12] = 49 THEN 235;
215 RETURN

0 REM left
216 A = lcd "CONNECT "
217 A = master $3
218 RETURN

0 REM right
0 REM show temperature
220 GOSUB 570
221 ALARM 20
222 RETURN

0 REM middle
0 REM select function
235 J = 5;
0 REM switch state to menue state
236 U = 1
237 GOTO 263


0 REM _____________________U = 1, function select mode
0 REM right, left, middle
240 IF $2[2] = 48 THEN 260;
241 IF $2[3] = 48 THEN 256;
242 IF $2[12] = 49 THEN 249;
243 RETURN

0 REM middle
0 REM switch state
249 U = J;
0 REM sensor 
250 IF J = 5 THEN 510;
0 REM inquiries
251 IF J = 6 THEN 280;
0 REM send rate
252 IF J = 7 THEN 290;
0 REM contrast
253 IF J = 8 THEN 475;
254 ALARM 1
255 RETURN

0 REM left: cancel
256 A = lcd "        "
257 U = 0
258 ALARM 1
259 RETURN

0 REM right
260 IF J < 8 THEN 262;
261 J = 4;
262 J = J + 1;
263 PRINTU J
264 PRINTU $J
265 PRINTU "\n\r"
266 $0=$J
267 A = lcd $0
268 RETURN


0 REM ________________________U = 2, streaming state
0 REM any button disconnect master
270 A = disconnect 2
271 U = 0
272 ALARM 1
273 RETURN




0 REM ___________________ U = 6, discovery mode
280 A = lcd "INQUIRY "
281 A = inquiry 6
0 REM N is the amount of discovered devices
282 N = 0
0 REM M is the index of the device to show
283 M = 0
0 REM inquiry for 6 seconds, give time to @INQ to work
284 ALARM 20
0 REM next state is "inquiring"
285 U = 9
286 RETURN


0 REM ___________________ U = 7, automatic message rate
290 P = P /60
0 REM buttons right, left, middle
291 $0[0] = 0
292 PRINTV P
293 PRINTV " MINUTES"
294 A = lcd $0
295 ALARM 20
296 RETURN

0 REM 
0 REM right left middle
300 IF $2[2] = 48 THEN 310;
301 IF $2[3] = 48 THEN 315;
302 IF $2[12] = 49 THEN 320;
303 RETURN

310 IF P > 90 THEN 313;
311 P = P + 5;
312 GOTO 291;
313 P = 0
314 GOTO 291

315 IF P = 0 THEN 318;
316 P = P - 5;
317 GOTO 291;
318 P = 90
319 GOTO 291

0 REM store R persistent
320 U = 0
321 $0[0] = 0
322 PRINTV P
323 $4=$0
0 REM change to minutes
324 P = P * 60
325 ALARM 1
326 RETURN

0 REM ___________________ U = 10, discovered devices menu

0 REM right left middle
330 IF $2[2] = 48 THEN 335;
331 IF $2[3] = 48 THEN 344;
332 IF $2[12] = 49 THEN 348;
333 RETURN

0 REM right we show the previous device
335 M = M - 1;
336 IF M > -2 THEN 339;
337 IF N = 0 THEN 360
338 M = N;
339 $0[0] = 0;
340 PRINTV $(389+M);
341 PRINTV "        "
342 A = lcd $0[13]
343 RETURN

0 REM left show next device
344 M = M + 1;
345 IF M < N THEN 339;
346 M = -1;
347 GOTO 339;

0 REM user choose a device
348 IF M < 1 THEN 354
349 A = lcd "SELECTED"
350 $3=$(389 +M)
351 U = 3
352 ALARM 1
353 RETURN

354 IF M = -1 THEN 357
355 A = lcd "UNPAIRED"
356 $3[0]=0
357 U = 3
358 ALARM 1
359 RETURN


0 REM no devices found
360 A = lcd "NOTFOUND"
361 M = 0
362 U = 10
363 RETURN

388 CANCEL
389 UNPAIR

0 REM LINES 390 to 399 are reserved to show discovered devices.
@INQUIRY 400
400 IF N>10 THEN 409;
401 $(390+N)=$0;
402 N = N+1;
403 M = 1;
404 $0[0] = 0;
405 PRINTV "FOUND "
406 PRINTV N;
407 PRINTV " "
408 A = lcd $0;
0 REM next state is "show discovered results"
409 U = 10;
410 RETURN


0 REM __________________ U = 5, calibration mode
420 ALARM 0
421 $0[0] = 0
422 PRINTV"           PUT PR"
423 PRINTV"OBE IN ICEWATER" 

425 E = strlen $0
426 FOR D = 1 TO 2
427  FOR C = 1 TO E -8
428   A = lcd$0[C];
429  NEXT C;
430  WAIT 1
431 NEXT D
432 $0[0] = 0
433 PRINTV "        STIRR"
434 PRINTV " FOR 30 SECONDS "
435 E = strlen $0
436 FOR C = 1 TO E -8
437   A = lcd$0[C];
438 NEXT C;
439 WAIT 1

440 D = 30
441 $0[0] = 0
442 PRINTV"STIRR "
443 PRINTV D
444 PRINTV"    "
445 A = lcd $0

0 REM check buttons because we cannot get PIO interrupts here
0 REM we do that instead of 1 sec wait
0 REM 474 WAIT 1 << no can do

446 FOR F = 0 TO 3
447  A = pioget 12;
448  IF A = 1 THEN 456;
449  A = pioget 2;
450  IF A = 0 THEN 456;
451  A = pioget 3;
452  IF A = 0 THEN 456;
453 NEXT F;

454 GOSUB 545
455 Y = -Y
456 $0[0] = 0
457 PRINTV"C "
458 PRINTV Y
459 PRINTV"     "
460 A = lcd $0

461 D = D - 1
462 IF D > 0 THEN 441


463 $0[0] = 0
464 PRINTV "DONE "
465 PRINTV Y
466 PRINTV "   "
467 A = lcd $0

0 REM store X persistently
468 $0[0] = 0
469 PRINTV Y
470 $9 = $0
471 U = 0
472 ALARM 1
473 X = Y
474 RETURN

0 REM ___________________ U = 8, LCD contrast
0 REM buttons right, left, middle
475 $0[0] = 0
476 PRINTV L
477 PRINTV"  LCD"
0 REM show new contrast
478 A = auxdac L
479 A = lcd $0
480 RETURN

0 REM 
0 REM right left middle
485 IF $2[2] = 48 THEN 490;
486 IF $2[3] = 48 THEN 495;
487 IF $2[12] = 49 THEN 500;
488 RETURN

490 IF L >= 200 THEN 494;
491 L = L + 10;
492 GOTO 475;
493 L = 150
494 GOTO 475

495 IF L <= 150 THEN 499;
496 L = L - 10;
497 GOTO 475;
498 L = 200
499 GOTO 475

0 REM store L persistent
500 U = 0
501 $0[0] = 0
502 PRINTV L
503 $10=$0
504 ALARM 1
505 RETURN

0 REM contrast timeout, we go back to the value
0 REM stored in $10
506 L = atoi $10
507 A = auxdac L
508 GOTO 107

0 REM type of sensor chooser
510 V = 0
511 U = 11
512 GOTO 532

0 REM button handler
0 REM rigth, left, middle
515 IF $2[2] = 48 THEN 518;
516 IF $2[3] = 48 THEN 520;
517 IF $2[12] = 49 THEN 522;

518 V = V+1
519 GOTO 530

520 V = V-1
521 GOTO 530

522 $11=$(15+V)
523 IF V = 0 THEN 420
524 A = lcd"DONE     "
525 U = 0
526 ALARM 2
527 RETURN

530 IF V < 0 THEN 540
531 IF V > 1 THEN 542
532 $0[0] = 0
533 PRINTV$(15+V)
534 PRINTV"              "
535 A = lcd $0
536 RETURN

540 V = 1
541 GOTO 532

542 V = 0
543 GOTO 532

0 REM I2C sensor reading handler
545 IF $11[0] = 75 THEN 550
546 IF $11[0] = 73 THEN 829
547 Y = 0
548 RETURN

0 REM sensor connected to MCP3421
550 A=ring
551 R = 0;
552 T = 1;
0 REM slave address is 0xD0
553 $1[0] = 208;
554 $1[1] = 143;
555 A = i2c $1;
556 $0[0] = 0;
557 $0[1] = 0;
558 $0[2] = 0;
559 $0[3] = 0;

560 $1[0] = 208;
561 T = 0;
562 R = 4;
563 A = i2c $1;
564 Y = $0[1] * 256;
565 Y = Y + $0[2];
566 RETURN

570 GOSUB 545
571 IF $11[0] = 73 THEN 580
572 $0="T "
573 Y = Y + X
574 Y = Y / 20
0 REM should add the ºF thing here
575 PRINTV Y
576 PRINTV" %C         "
577 A = lcd $0
578 RETURN

0 REM IR sensor
580 $0 ="IR. "
581 C = Y / 10
582 PRINTV C
583 PRINTV"."
584 D = C * 10
585 D = Y-D
586 PRINTV D
587 A = pioset 1
588 GOTO 576



0 REM __________INTERACTIVE MODE_______
@MASTER 590
590 A = lcd "WAIT . . ."
591 U = 2
592 A = pioset 20
593 GOTO 600

0 REM __interactive mode button handler __
0 REM $MENU code: right, left, middle
594 IF $2[2] = 48 THEN 730;
595 IF $2[3] = 48 THEN 740;
596 IF $2[12] = 49 THEN 750;
597 RETURN

0 REM __generate menu __
599 RESERVED
0 REM __send our current temp__
600 PRINTM"!"
601 GOSUB 545
602 PRINTM Y
603 PRINTM":"
604 PRINTM X
605 PRINTM"#"
606 PRINTM$11
607 PRINTM"\n"

0 REM __ get amount of messages __
608 TIMEOUTM 5
609 INPUTM $0
610 IF $0[0] = 63 THEN 660
611 IF $0[0] = 37 THEN 625
612 PRINTM"@@@@\n\r"
613 WAIT 3
614 GOTO 600

625 $599 = $0[1]
626 $0 = $599
0 REM M amount of options
627 K = atoi $0
628 C = 0
629 IF K > 100 THEN 655

0 REM __get each menu entry __
630 TIMEOUTM 20
631 INPUTM $0
632 $(800+C)=$0[2]
633 C = C +1
634 IF C>= K THEN 637
635 PRINTM"&"
636 GOTO 638
637 PRINTM"$"
638 A = hex8 C
639 PRINTM$0
640 PRINTM"\n"
641 IF C < K THEN 630
0 REM V is index
0 REM K is amout of messages
642 V = 0
643 GOTO 705

655 A = lcd"ERROR...    "
656 RETURN

0 REM <monitor> handler
660 A = xtoi $0[1]
661 S = A
662 IF A < 4 THEN 669
0 REM we receive max and min
663 PRINTM"&MIN\n\r"
664 INPUTM $20
665 PRINTM $20
666 PRINTM"\n\r&MAX\n\r
667 INPUTM $21
668 A = A - 4
669 IF A < 2 THEN 671
670 A = A -2
671 IF A < 1 THEN 680
672 U = 0
673 GOTO 220

680 U = 2
681 IF S < 4 THEN 690
0 REM PLACE TO COMPARE
690 S = 0
691 GOTO 580

0 REM clear lcd then display menu
705 $0=$(800+V)
706 A = strlen $0
707 PRINTV"          "
708 A = lcd $0
709 RETURN

0 REM if line is empty then we show the
0 REM exit option
720 A = lcd "EXIT     "
721 V = -1
722 RETURN

0 REM __right button pressed
730 V = V + 1
731 IF V = K THEN 720
732 GOTO 705

0 REM __left button pressed
740 IF V =-1 THEN 745
741 IF V = 0 THEN 720
742 V = V-1
743 GOTO 705

745 V = K-1
746 GOTO 705

0 REM __middle button pressed
750 IF V = -1 THEN 760
751 PRINTM"@"
752 A = V+1
753 PRINTM A
754 GOTO 580

0 REM __choose exit, tell NSLU2
760 PRINTM"\x03"
761 A = lcd"Finished"
762 ALARM 3
763 U = 0
764 RETURN

0 REM 800-828 RESERVED FOR MENU!!!!


0 REM read IR Temp module
829 A = ring
830 A = pioout 1
831 A = pioclr 1
0 REM temp is in Kelvin
0 REM substract 273.15 to get Celsius
0 REM temp / 0.02 is K
0 REM F = address: 6 is ambient, 7 object
832 F = 7
0 REM E is repeat limit
833 E = 0;
834 $0[0] = 0;
835 $0[1] = 0;
836 $0[2] = 0;
837 R = 3;
838 T = 1;
8 REM slave address 0x5A
839 $1[0] = 180;
8 REM command read RAM addr 0x06
840 $1[1] = F;
842 A = i2c $1;
843 E = E + 1;
0 REM read until good reading
844 IF E > 10 THEN 870;
845 IF A <> 6 THEN 834;
846 IF $0[2] = 255 THEN 834;
847 IF $0[2] = 0 THEN 834;

0 REM calculate temp, limit 380 C
848 B = $0[1];
849 IF B > 127 THEN 870;
850 B = B * 256;
851 B = B + $0[0];
852 B = B - 13658;
853 B = B / 5;

854 Y = B
855 A = pioset 1
856 RETURN

0 REM failed reading
870 A = pioset 1
871 Y = -32000
872 RETURN




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
@IDLE 981
981 A = pioclr 9
982 A = pioset 9
983 REM IF Q = 1 THEN 992
984 REM IF Q = 2 THEN 996
985 A = slave 30
986 Q = 1
0 REM startup the automatic again
987 IF U = 2 THEN 991
988 U = 0
989 W = 0
990 ALARM 2
991 RETURN

0 REM after some time disable FTP
992 A = disable 3
993 WAIT 3
994 A = slave -1
995 Q = 2
996 RETURN


