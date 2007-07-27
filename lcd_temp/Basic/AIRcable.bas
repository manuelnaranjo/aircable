@ERASE

0 REM $2 is for button state
0 REM $3 is for master BT address
0 REM $4 used for transfer rate
0 REM $5-$8 are 4 menu entries
0 REM $9 used for ice water compensation
0 REM $10 used for LCD contrast storage
0 REM $11 used for type of sensor

3 0050C258501B
9 540
10
11 K

@INIT 28
28 A = baud 1152
0 REM debug to uart
29 Z = 1
0 REM LED output and on
30 A = pioout 9
31 A = pioset 9

0 REM LCD contrast between 100 and 200
32 L = atoi $9[0]
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
53 $1="AIRCABLE THERMO TYPE K "
54 A = lcd $1
55 WAIT 1
56 FOR C = 1 TO 15
57   A = lcd $1[C]
58 NEXT C

0 REM button state variable
59 W = 0
0 REM state
60 U = 0

61 A = zerocnt

0 REM strings with spaces
63 $5="CALIBRAT"
64 $6="DISCOVER"
65 $7="SENDRATE"
66 $8="CONTRAST"

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
75 P = atoi $4[0]
75 P = 0
76 IF P > 30 THEN 79
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
85 ALARM 1
86 PRINTU P
87 RETURN


0 REM buttons and power
@PIO_IRQ 90
0 REM press button starts alarm for long press recognition
90 IF $0[2]=48 THEN 96;
91 IF $0[3]=48 THEN 96;
92 IF $0[12]=49 THEN 96;
0 REM ignore button release on rebooting
93 IF W = 3 THEN 95;
0 REM was it a release, handle it
94 IF W <> 0 THEN 200;
95 RETURN

0 REM button press, save state, start ALARM
96 $2 = $0;
97 W = 1;
98 ALARM 3
99 RETURN



@ALARM 100
0 REM rate do their own buttons
100 IF U = 8 THEN 357
0 REM contrast do their own buttons
101 IF U = 9 THEN 520
102 IF U <> 2 THEN 107

0 REM streaming mode U=2
103 C = status
104 IF C < 10 THEN 116
0 REM in streaming mode check very 5 seconds
105 ALARM 5
106 RETURN

107 U = 0;
0 REM blink
108 A = pioset 20;
109 A = pioclr 20
0 REM long press button
110 IF W = 1 THEN 155
0 REM here other alarm things
111 GOTO 120

0 REM get a reading, put it on LCD
120 GOSUB 600
121 Y = Y + X
122 Y = Y / 20
123 $0 = "T "
124 PRINTV Y
125 PRINTV " %C    "
126 A = lcd $0
127 A = strlen $3
128 IF A = 0 THEN 162
0 REM check if P has reached number of seconds
129 IF P = 0 THEN 162
130 A = readcnt
131 IF A < P THEN 162

0 REM prepare OBEX message
132 GOSUB 600
133 $0[0]=0
134 PRINTV"$"
135 PRINTV A
136 PRINTV ":"
137 PRINTV Y
138 PRINTV"!"
139 PRINTV X
140 PRINTV"#K"
141 REM PRINTV $11

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
157 WAIT 1
158 GOTO 120

0 REM ---------------------------
160 A = lcd "   OK   "
161 GOTO 120

0 REM next reading in 20 seconds
162 ALARM 20
0 REM allow deep sleep
163 A = uartoff
164 RETURN

0 REM power button pressed
165 A = pioget 12
166 IF A = 1 THEN 170
0 REM ignore other long presses
167 W = 0
168 ALARM 1
169 RETURN

0 REM long button press
170 A = lcd "GOOD BYE"
171 ALARM 0;
172 A = pioget 12;
173 IF A = 1 THEN 172;
174 A = lcd;
175 W = 3;
176 A = reboot;
177 FOR E = 0 TO 10
178   WAIT 1
179 NEXT E
180 RETURN





0 REM we have button applications
0 REM state variable is U
0 REM U = 0 for main menue
0 REM left means make a streaming connection
0 REM right means send a single message
0 REM middle means display menu entries

0 REM U = 1 for menu select mode
0 REM right means next entry, cycle through
0 REM left means cancel, back to main menu
0 REM middle means start next application

0 REM U = 2 streaming mode
0 REM any button press disconnects 

0 REM U=5, 6, 7, 8 menu entry start

0 REM U = 9 discovered devices selection

0 REM handle BUTTON RELEASE
0 REM after 30 seconds of no button presses, resume temp display
200 ALARM 30;
201 W = 0;
0 REM display temperature
202 IF U = 0 THEN 212;
0 REM show menue
203 IF U = 1 THEN 240;
0 REM interactive mode
204 IF U = 2 THEN 660;

0 REM 5-8 display the menu
205 IF U = 5 THEN 210;
0 REM start inquiry
206 IF U = 6 THEN 290;
0 REM message rate
207 IF U = 7 THEN 310;
0 REM LCD contrast
208 IF U = 8 THEN 510;

0 REM nothing found will restart
209 IF U = 9 THEN 370;
0 REM show discovered results
210 IF U = 10 THEN 340;
210 RETURN

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
220 A = lcd " MESSAGE"
221 $0 = "$"
222 A = readcnt
223 PRINTV A;
224 PRINTV ":"
225 T = alink 0;
226 PRINTV T;
227 PRINTV "!"
228 PRINTV X;
229 A = message $3
230 A = zerocnt
231 ALARM 5
232 RETURN

0 REM middle
0 REM select function
235 J = 5;
236 A = lcd $J
0 REM switch state to menue state
237 U = 1
238 RETURN



0 REM _____________________U = 1, function select mode
0 REM right, left, middle
240 IF $2[2] = 48 THEN 260;
241 IF $2[3] = 48 THEN 256;
242 IF $2[12] = 49 THEN 249;
243 RETURN

0 REM middle
0 REM switch state
249 U = J;
0 REM cablibration 
250 IF J = 5 THEN 449;
0 REM inquiries
251 IF J = 6 THEN 290;
0 REM send rate
252 IF J = 7 THEN 300;
0 REM contrast
253 IF J = 8 THEN 510;
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
262 J = J + 1 ;
263 A = lcd $J
264 RETURN


0 REM ________________________U = 2, streaming state
0 REM any button disconnect master
270 A = disconnect 2
271 U = 0
272 ALARM 1
273 RETURN




0 REM ___________________ U = 6, discovery mode
290 A = lcd "INQUIRY "
291 A = inquiry 6
0 REM N is the amount of discovered devices
292 N = 0
0 REM M is the index of the device to show
293 M = 0
0 REM inquiry for 6 seconds, give time to @INQ to work
294 ALARM 20
0 REM next state is "inquiring"
295 U = 9
296 RETURN


0 REM ___________________ U = 7, automatic message rate
0 REM buttons right, left, middle
300 $0[0] = 0
301 PRINTV P
302 PRINTV " MINUTES"
303 A = lcd $0
304 RETURN

0 REM 
0 REM right left middle
310 IF $2[2] = 48 THEN 320;
311 IF $2[3] = 48 THEN 325;
312 IF $2[12] = 49 THEN 330;
313 RETURN

320 IF P >= 30 THEN 323;
321 P = P + 1;
322 GOTO 300;
323 P = 0
324 GOTO 300

325 IF P = 0 THEN 328;
326 P = P - 1;
327 GOTO 300;
328 P = 30
329 GOTO 300

0 REM store R persistent
330 U = 0
331 $0[0] = 0
332 PRINTV P
333 $4=$0
0 REM change to minutes
334 P = P * 60
335 ALARM 1
336 RETURN

0 REM ___________________ U = 10, discovered devices menu

0 REM right left middle
340 IF $2[2] = 48 THEN 345;
341 IF $2[3] = 48 THEN 355;
342 IF $2[12] = 49 THEN 359;
343 RETURN

0 REM right we show the previous device
345 M = M - 1;
346 IF M > 0 THEN 348;
347 M = N;
348 $0[0] = 0;
349 PRINTV $(389+M);
350 PRINTV "        "
351 A = lcd $0[13]
352 RETURN

0 REM left show next device
355 M = M + 1;
356 IF M < N THEN 348;
357 M = 1;
358 GOTO 348;

0 REM user choose a device
359 A = lcd "SELECTED"
360 $3=$(389 +M)
361 U = 3
362 ALARM 1
363 RETURN

0 REM no devices found
370 A = lcd "NOTFOUND"
371 $3[0] = 0
372 U = 0
373 ALARM 1
374 RETURN


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
449 ALARM 0
450 $0[0] = 0
451 PRINTV"           PUT PR"
452 PRINTV"OBE IN ICEWATER" 

453 E = strlen $0
454 FOR D = 1 TO 2
455  FOR C = 1 TO E -8
456   A = lcd$0[C];
457  NEXT C;
458  WAIT 1
459 NEXT D
460 $0[0] = 0
461 PRINTV "        STIRR"
462 PRINTV " FOR 30 SECONDS "
463 E = strlen $0
464 FOR C = 1 TO E -8
465   A = lcd$0[C];
466 NEXT C;
467 WAIT 1

468 D = 30
469 $0[0] = 0
470 PRINTV"STIRR "
471 PRINTV D
472 PRINTV"    "
473 A = lcd $0

0 REM check buttons because we cannot get PIO interrupts here
0 REM we do that instead of 1 sec wait
0 REM 474 WAIT 1 << no can do

474 FOR F = 0 TO 3
475  A = pioget 12;
476  IF A = 1 THEN 484;
477  A = pioget 2;
478  IF A = 0 THEN 484;
479  A = pioget 3;
480  IF A = 0 THEN 484;
481 NEXT F;

482 GOSUB 600
483 Y = -Y
484 $0[0] = 0
485 PRINTV"C "
486 PRINTV Y
487 PRINTV"     "
488 A = lcd $0

489 D = D - 1
490 IF D > 0 THEN 469


491 $0[0] = 0
492 PRINTV "DONE "
493 PRINTV Y
494 PRINTV "   "
495 A = lcd $0

0 REM store X persistently
496 $0[0] = 0
497 PRINTV Y
498 $9 = $0
499 U = 0
500 ALARM 1
501 RETURN

0 REM ___________________ U = 8, LCD contrast
0 REM buttons right, left, middle
510 $0[0] = 0
511 PRINTV L
512 PRINTV " LCD"
513 A = lcd $0
514 RETURN

0 REM 
0 REM right left middle
520 IF $2[2] = 48 THEN 530;
511 IF $2[3] = 48 THEN 535;
512 IF $2[12] = 49 THEN 540;
513 RETURN

530 IF L >= 200 THEN 533;
531 L = L + 10;
532 GOTO 510;
533 L = 150
534 GOTO 510

535 IF L = 0 THEN 528;
536 L = L - 10;
537 GOTO 510;
538 R = 200
539 GOTO 510

0 REM store R persistent
540 U = 0
541 $0[0] = 0
542 PRINTV L
543 $10=$0
545 ALARM 1
546 RETURN



0 REM I2C reading sensor routine for ThermoCouple on MCP3421
600 R = 0
601 T = 1
602 $1[0] = 208
603 $1[1] = 143
604 A = i2c $1
605 $0[0] = 0;
606 $0[1] = 0;
607 $0[2] = 0;
608 $0[3] = 0;
609 $1[0] = 208
610 T = 0;
611 R = 4;
612 A = i2c $1
613 Y = $1[1] * 256
614 Y = B + $1[2]
615 RETURN

0 REM read IR Temp module
0 REM ....



0 REM __________INTERACTIVE MODE_______
@MASTER 650
650 A = lcd "WAIT..."
651 U = 2
652 A = pioset 20
653 GOTO 670

0 REM __interactive mode button handler __
0 REM $MENU code: right, left, middle
660 IF $2[2] = 48 THEN 730;
661 IF $2[3] = 48 THEN 740;
662 IF $2[12] = 49 THEN 750;
663 RETURN

0 REM __generate menu __
669 RESERVED
0 REM __send our current temp__
670 PRINTM"!"
671 A = alink 0
672 PRINTM A
673 PRINTM":"
674 PRINTM X
675 PRINTM"#"
676 PRINTM$11
677 PRINTM"\n"

0 REM __ get amount of messages __
678 TIMEOUTM 5
679 INPUTM $0
680 $669 = $0[1]
681 $0 = $669
0 REM M amount of options
682 K = atoi $0
683 C = 0
684 IF K > 100 THEN

0 REM __get each menu entry __
685 TIMEOUTM 20
686 INPUTM $0
687 $(800+C)=$0[2]
688 C = C +1
689 IF C>= K THEN 692
690 PRINTM"&"
691 GOTO 693
692 PRINTM"$"
693 A = hex8 C
694 PRINTM$0
695 PRINTM"\n"
696 IF C < K THEN 685
0 REM V is index
0 REM K is amout of messages
697 V = 0
698 GOTO 705

700 A = lcd"ERROR...    "
701 RETURN

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
754 GOTO 670

0 REM __choose exit, tell NSLU2
760 PRINTM"\x03"
761 A = lcd"Finished"
762 ALARM 3
763 U = 0
764 RETURN

0 REM 800-899 RESERVED FOR MENU!!!!



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
@IDLE 982
982 A = pioclr 20
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

