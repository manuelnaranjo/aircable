@ERASE

0 REM command line version
1 Pre-1.0

0 REM temp
2 TEMP

0 REM mode variable
3 1110

0 REM $4 stores the status variable
0 REM all values must be translated to ASCII
0 REM $4[0] = 0 idle
0 REM $4[0] = 1 manual
0 REM $4[0] = 2 slave
0 REM $4[0] = 3 master
0 REM $4[0] = 4 relay

0 REM $4[1] = 0 cable mode
0 REM $4[1] = 1 service mode

0 REM $4[2] = 0 pairing
0 REM $4[2] = 1 paired

0 REM $4[3] = 0 no relay
0 REM $4[3] = 1 relay not connected
0 REM $4[3] = 2 relay slave connected
0 REM $4[3] = 3 relay connected

0 REM $4[4] = 0 no manual
0 REM $4[4] = 1 slave connecting
0 REM $4[4] = 2 slave connected
0 REM $4[4] = 3 master connecting
0 REM $4[4] = 4 master connected
0 REM $4[4] = 5 inquirying
0 REM $4[4] = 6 relay pairing

0 REM $4[5] connection counter - service master

0 REM status variable - filled in first boot
4 z



0 REM last discovered device
5 0

0 REM friendly name
6 AIRcable

0 REM PIN
7 1234

0 REM baud rate 0 equal external
8 1152

0 REM PIO List
0 REM stored in config.txt, key 9 - HEX values
0 REM $9[0] BLUE LED
0 REM $9[1] GREEN LED
0 REM $9[2] BUTTON
0 REM $9[3] RS232 POWER OFF
0 REM $9[4] RS232 POWER ON
0 REM $9[5] DTR
0 REM $9[6] DSR
0 REM $9[7] POWER SWITCH
9 z


0 REM modes
0 REM cable slave
10 200000
0 REM cable master
11 300000
0 REM service slave
12 210000
0 REM service master
13 310000

0 REM name filter
20 AIRcable

0 REM addr filter
21 0050

0 REM peer addr (slave, master, relay)
22 

0 REM $23[0] = 0 UART command line - Default.
0 REM $23[0] = 1 SPP command line

0 REM $23[1] = 0 default obex visibility
0 REM $23[1] = 1 always visible
0 REM $23[1] = 2 disabled

0 REM $23[2] = 0 no debug
0 REM $23[2] = 1 debug enabled

0 REM $23[3] = 0 Non Modified Name / PIN
0 REM $23[3] = 1 Name + Uniq
0 REM $23[3] = 0 Name + Uniq, PIN = Uniq
23 0000

50 

@INIT 100
100 Z = $23[2]-48;
0 REM 100 Z = 0
0 REM 101 IF $4[0] = 122 THEN 50
102 A = baud 1152
103 B = 0
104 A = uartint
105 RETURN

0 REM generic INPUT
150 IF $23[0]=48 THEN 153;
151 INPUTS$2;
152 RETURN
153 INPUTU$2;
154 RETURN

0 REM generic PRINT
160 IF $23[0]=48 THEN 163;
161 PRINTS$0;
162 GOTO 164 
163 PRINTU$0;
0 REM flush buffer
164 $0[0]=0
165 RETURN

0 REM seek 
0 REM I number of bytes from beggining
170 A = seek I
171 RETURN

0 REM close file
178 A = close;
179 RETURN;

0 REM open file
180 A = open "text";
181 RETURN;

0 REM Print \n\r
185 PRINTV"\n\r";
186 GOSUB 160
187 RETURN;

0 REM read line
188 A = read 32;
189 $2 = $0;
190 $0[0]=0
191 RETURN

0 REM read line + print function
192 GOSUB 160
193 A = read 32;
194 GOSUB 160
195 RETURN;


@UART 196
0 REM 195 GOSUB 150

0 REM welcome message
196 STTYU 7
197 GOSUB 180;
198 $4[0]=49
199 $0="\x1B[2J"
200 GOSUB 185;
202 GOSUB 192;
203 GOSUB 185;
204 GOSUB 192;
206 PRINTV" ";
207 PRINTV $1;
208 GOSUB 185;
209 GOSUB 160
210 X = 0;
211 GOTO 300;


0 REM Menu creator
250 B = 1;
251 GOSUB 192;
253 GOSUB 185;
254 GOSUB 188;
255 A = strlen $2;
256 IF A = 0 THEN 264;
257 PRINTV B;
258 PRINTV " - ";
259 PRINTV $2;
260 GOSUB 185;
262 B = B+1;
263 GOTO 254;
264 IF X = 0 THEN 271
265 I = 3 * 32;
266 PRINTV"0 - ";
267 GOSUB 170;
268 GOSUB 192;
270 GOSUB 185;
271 I = 5 * 32;
272 GOSUB 170;
273 GOSUB 192
275 PRINTV " ";
276 GOSUB 160
277 RETURN

300 IF X = 0 THEN 400;
301 IF X = 1 THEN 400;
302 IF X = 2 THEN 410;
303 IF X = 3 THEN 414;
304 IF X = 4 THEN 420;
305 IF X = 5 THEN 425;
306 IF X = 6 THEN 430;
307 IF X = 7 THEN 435;
308 IF X = 8 THEN 399;
309 IF X = 9 THEN 440;
0 REM calc module
310 B = X / 10;
311 B = B * 10;
312 Y = X - B;
313 IF Y = 0 THEN 399;
314 IF B = 20 THEN 460;
315 IF B = 30 THEN 470;
316 IF B = 40 THEN 530;
317 IF B = 50 THEN 550;
318 IF B = 60 THEN 660;
319 IF B = 70 THEN 710;
320 GOTO 450;

350 GOSUB 150;
351 X = X + $2[0]-48;
352 $0 = "\x1B[2J
353 GOSUB 160
354 GOTO 300

399 X = 0
0 REM main
400 I = (29*32);
401 GOSUB 170:
402 GOSUB 250;
403 GOTO 350;

0 REM mode menu
410 I = (58*32);
412 X = X *10;
413 GOTO 401;

0 REM manual mode
414 I = (65*32);
415 GOTO 412;

0 REM relay pair
420 I = (70*32);
421 GOTO 412;

0 REM edit settings
425 I = (75*32);
426 GOTO 412;

0 REM security
430 I = (86*32);
431 GOTO 412;

0 REM debug
435 I = (92*32);
436 GOTO 412;

0 REM reboot
440 A = reboot
441 WAIT 2
442 RETURN

0 REM invalid option
450 I = (27*32);
451 GOSUB 170;
452 GOSUB 192;
454 GOSUB 185;
455 X = 0;
456 GOTO 400;

0 REM mode selector
460 IF Y > 4 THEN 450;
461 $4=$(9+Y);
462 GOTO 399

0 REM manual mode
470 IF Y = 1 THEN 495
471 IF Y = 2 THEN 480
472 IF Y = 3 THEN 510
473 GOTO 450

0 REM manual inquiry
0 REM relay mode inquiry
480 I = (23*32);
481 GOSUB 170;
482 GOSUB 192;
484 PRINTV "18 ";
485 I = (22*32);
486 GOSUB 170;
487 GOSUB 192;
489 GOSUB 185
490 GOTO 399

0 REM open slave channel
495 I = (24*32);
496 GOSUB 170;
497 GOSUB 192;
499 PRINTV "18 ";
500 I = (22*32);
501 GOSUB 170;
502 GOSUB 192;
504 GOSUB 185
505 GOTO 399

0 REM manual master
0 REM relay mode pair
510 I = (99*32);
511 GOSUB 170;
512 GOSUB 192;
514 PRINTV $5;
515 GOSUB 185;
516 GOSUB 192;
518 GOTO 399;

0 REM realy mode menu
530 IF Y = 1 THEN 480;
531 IF Y = 2 THEN 510;
532 IF Y = 3 THEN 540;
533 GOTO 450;

0 REM relay mode settings menu
540 I = (152 * 32);
541 GOSUB 545
542 IF $2[0] < 49 THEN 450
543 IF $2[0] > 50 THEN 450
544 GOTO 399

545 GOSUB 170;
546 GOSUB 250;
547 GOSUB 150
548 RETURN

0 REM edit settings menu
550 IF Y = 1 THEN 565
551 IF Y = 2 THEN 575
552 IF Y = 3 THEN 580
553 IF Y = 4 THEN 590
554 IF Y = 5 THEN 595
555 IF Y = 6 THEN 620
556 IF Y = 7 THEN 630
558 IF Y = 8 THEN 640
559 IF Y = 9 THEN 650
560 GOTO 450

0 REM new name
565 I = (102 * 32);
566 A = 6
567 GOSUB 570
568 GOTO 399

570 GOSUB 170;
571 GOSUB 610;
572 GOSUB 150;
573 RETURN

0 REM new pin
575 I = (104 * 32);
576 GOSUB 570
577 $7=$2
578 GOTO 399

0 REM interface settings
580 I = (106 * 32);
581 GOSUB 545
582 IF $0[0] < 49 THEN 450
583 IF $0[0] > 50 THEN 450
584 GOTO 399

0 REM baud rate
590 I = (110*32);
591 GOSUB 570
592 $8=$2
593 GOTO 399

0 REM parity
595 I = (113*32);
596 GOSUB 545
597 IF $2[0] < 49 THEN 450
598 IF $2[0] > 51 THEN 450
599 GOTO 399

0 REM string input.
610 GOSUB 188;
611 A = strlen $2;
612 IF A = 0 THEN 616;
613 PRINTV $2;
614 GOSUB 185;
615 GOTO 610
616 RETURN;

0 REM stop bits
620 I = (119*32);
621 GOSUB 545
622 IF $2[0] < 49 THEN 450
623 IF $2[0] > 50 THEN 450
624 GOTO 399

0 REM pio list
630 I = (122*32);
631 GOSUB 570
632 $9=$2
633 GOTO 399

0 REM Class of Device
640 I = (124*32);
641 GOSUB 570;
642 GOTO 399;

0 REM Date
650 I = (127*32);
651 GOSUB 570;
652 GOTO 399;

0 REM security menu.
660 IF Y = 1 THEN 670
661 IF Y = 2 THEN 680
662 IF Y = 3 THEN 690
664 IF Y = 4 THEN 700
665 GOTO 450

0 REM obex/obexftp settings
670 I = (130*32);
671 GOSUB 545
672 IF $2[0] < 49 THEN 675;
673 IF $2[0] > 52 THEN 675;
674 GOTO 399;
675 C = $2[0];
676 $23[1] = C-1;
677 GOTO 450

0 REM PIN/settings settings
680 I = (135*32);
681 GOSUB 545
682 IF $2[0] < 49 THEN 685;
683 IF $2[0] > 52 THEN 685;
684 GOTO 399;
685 C = $2[0];
686 $23[3] = C-1;
686 GOTO 450;

0 REM Name Filter
690 I = (140*32);
691 GOSUB 570;
692 $20=$2;
693 GOTO 399;

0 REM Addr Filter
700 I = (142*32);
701 GOSUB 570;
702 $21=$2;
703 GOTO 399;

0 REM debug menu
710 IF Y = 1 THEN 716
711 IF Y = 2 THEN 730
712 IF Y = 3 THEN 755
713 IF Y = 4 THEN 780
714 IF Y = 5 THEN 800
715 GOTO 450;

0 REM shell
716 IF $23[0] = 48 THEN 719
717 A = shell
718 RETURN

719 I=(146*32);
720 GOSUB 170;
721 GOSUB 193;
722 GOSUB 185;
723 GOTO 399;

0 REM enable trace
730 I = (144*32);
731 GOSUB 570;
732 IF $2[0]=121 THEN 735;
733 $23[2]=48;
734 GOTO 399;
735 $23[2]=49;
736 Z=1
737 GOTO 399

0 REM print line
755 GOSUB 770;
756 GOTO 399;

0 REM read input / print line
770 I = (148*32);
771 GOSUB 170
772 GOSUB 192
773 GOSUB 150
774 A = atoi$2;
775 $0=$A;
776 GOSUB 194;
777 GOSUB 185;
778 RETURN

0 REM change line
780 GOSUB 770;
781 R = A;
782 I = (150*32);
783 GOSUB 170;
784 GOSUB 192;
785 A = 2;
786 GOSUB 572;
787 $R=$2;
788 GOTO 399;

0 REM list code
800 FOR A = 0 TO 1024
801 C = strlen $A
802 IF C = 0 THEN 809
803 $0[0] = 0
804 PRINTV A
805 PRINTV" "
806 PRINTV $A
807 PRINTV"\n\r
808 GOSUB 160;
809 NEXT A
810 GOTO 399

@IDLE 1000
1000 A = slave 15
1001 RETURN

@SLAVE 1002
1002 A = shell
1003 RETURN

