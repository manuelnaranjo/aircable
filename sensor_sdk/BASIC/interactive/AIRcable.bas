0 REM history file
1010 history.txt

0 REM menu file
1011 menu.txt

0 REM RESERVED
1012 RES

0 REM lines format XXYYZZMESSAGE
0 REM check Format in sensor_sdk/BASIC/interactive for
0 REM more information about it.

0 REM @INIT extension
20 GOTO 600;

0 REM @ALARM extension
21 GOTO 650;

0 REM @IDLE extension
22 RETURN;

0 REM long button handlers ----------------------------------
0 REM left long button press
0 REM edit menu
34 GOTO 285;
0 REM middle long button press 
0 REM turn off
35 GOTO 550;
0 REM right long button press
0 REM make visible
36 GOTO 570;

0 REM left short button press
37 GOTO 610;
0 REM middle short button press 
38 GOTO 620;
0 REM right short button press
39 GOTO 630;


0 REM state variable L
0 REM L = -1 not showing menu
0 REM L = 0 showing root
0 REM L = 1 showing menu 1
0 REM L = N, N<255 showing menu N
0 REM L = N, N> 255 doing X activity
0 REM K internal counter
0 REM J = 0 no files open
0 REM J = 1 history file opened
0 REM J = 2 menu file opened
0 REM H menu buffer length
0 REM G menu buffer pointer
0 REM F history buffer length (equals pointer)


0 REM some more init
600 L = -1;
601 K = 0;
602 J = 0;
0 REM we assume there's no buffer at all
0 REM and history buffer has been flused
603 H = 0;
604 G = 0;
605 F = 0;
606 RETURN


0 REM SHORT BUTTON PRESS HANDLER --------------
0 REM this buttons have special meaning depend on
0 REM which state the system is.
0 REM 
0 REM if showing menu:
0 REM middle button is SELECT
0 REM left button shows previous menu
0 REM right button shows next menu
0 REM 
0 REM if not showing menu
0 REM middle button show menu
0 REM left button show reading 
0 REM right button show battery

0 REM middle button
610 IF L > -1 THEN
611 A = strlen $5;
612 IF A > 11 THEN ;
613 A = lcd"NOT PAIRED  "
614 ALARM 10
615 RETURN

0 REM left button
620 IF L>-1 THEN
621 $0 = "BATT "
622 PRINTV $7
623 ALARM 5
624 GOTO 41

0 REM right button
630 IF L>-1 THEN 
631 GOSUB 800
632 GOSUB 850
633 A = 11
634 GOSUB 40
635 ALARM 30
636 RETURN

0 REM EO SHORT BUTTON HANDLER --------------------


0 REM ALARM HANDLER ---------------------------------------
0 REM if more than 1 hour happened since last time
0 REM we sent our records, then we send again.
650 A = readcnt;
651 IF A > 3600 THEN 660;
0 REM jf you need any more
0 REM checkings, you can do a GOSUB
0 REM in line 652 to your code.
653 IF L > -1 THEN 675;
654 A = lcd "READY     ";
655 ALARM 15;
656 RETURN

0 REM send content
660 A = strlen $5
661 IF A > 5 THEN 670
662 A = zerocnt
663 GOTO 654

0 REM go, get connected
670 A = master $5
671 ALARM 10
672 RETURN

0 REM not busy, then scroll screen once
0 REM scroll again in 4 seconds
675 E = 1
676 ALARM 4
677 GOTO 41

0 REM EO ALARM HANDLER --------------------------------


0 REM MENU HANDLER ---------------------------------------

0 REM MENU READING, BUFFER FILLING ------------
0 REM menu buffer is stored in lines 900 to 919
0 REM history buffer is stored in lines 920 to 949


0 REM check if we have our file opened
700 IF J = 1 THEN 705;
701 IF J = 0 THEN 703;
0 REM time expensive
702 A = close ;
703 A = open $1011 ;
704 J = 1 ;

0 REM move pointer to first byte
705 A = seek 0;

0 REM be FAST! no interrupts what's so ever
706 A = pioirq"P000000000000000";

0 REM init $1012
707 A = hex L;
708 $1012=$0

0 REM go through file until buffer gets filled, or
0 REM there are no more menu options on L level

709 B = read 32;
710 IF B = 0 THEN 716;

0 REM check level
711 A = strcmp $1012;
712 IF A <> 0 THEN 709;

0 REM same level
713 $(H+900)=$0;
714 H=H+1;

0 REM loop
715 GOTO 709;
0 REM enable interrupts back
716 A = pioirq $6
717 RETURN

0 REM -------------------------------------------------------------------

0 REM HISTORY BUFFER FILLING, FLUSHING
0 REM save it
720 $(H+920)=$0;
721 H=H+1;

0 REM check if we filled the buffer
722 IF H>=20 THEN 725
723 RETURN

0 REM disable interrupts, get lock on files
725 A = pioirq"P00000000000000"
726 A =lcd"FLUSHING"
727 IF J=0 THEN 731;
728 IF J=1 THEN 733;
0 REM menu was opened, now close it
0 REM this will take a while
730 A = close;
731 J = 1;

0 REM open and point to last byte,
0 REM this will create the file if needed
732 A = append $1010;

733 FOR B=0 TO H
734 $0=$(H+920);
0 REM assume length
735 A = write 32;
736 NEXT B

0 REM now do the really time consuming thingy
737 A = close;
738 J=0;
739 H = 0;
0 REM enable interrupts back
740 A = pioirq $6
741 A = lcd"DONE       "
742 RETURN

0 REM -------------------------------------------------------------------



0 REM we got connected to the server
0 REM send our content
@MASTER 950
950 PRINTM"INTERACTIVE\n"
951 INPUTM$0
952 A = enable 3
953 A = strcmp "GO\n"
954 IF A <> 0 THEN
955 IF J = 0 THEN 960; 
956 WAIT 1
957 GOTO 954;

0 REM the semaphore is free
0 REM lock it
960 J = 1;
961 PRINTM"HISTORY READY\n"
0 REM let the server get our history
962 WAIT 10
963 A = status;
964 IF A >= 100 THEN 958;
0 REM release semaphore
965 J = 0

0 REM check for menu lock
967 IF H = 0 THEN 970
968 WAIT 1
969 GOTO 967;

0 REM lock semaphore
970 H = 1
971 PRINTM"MENU READY\n"

