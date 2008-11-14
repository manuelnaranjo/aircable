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
37 GOTO 630;
0 REM middle short button press 
38 GOTO 610;
0 REM right short button press
39 GOTO 640;


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

0 REM hack @PIO_IRQ to make it faster
212 IF L>-1 THEN 680;

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

0 REM middle button, show menu,
0 REM but first check there's something to show
610 IF L > -1 THEN 619;
611 A = exist $1011
612 IF A = 0 THEN 620
0 REM point to root, load menu, start the magic
613 L = 0
614 G = 0
615 GOSUB 700
616 GOTO 760

0 REM RETURN on button release
619 RETURN

0 REM ohoh! no menu file found.
620 A = lcd"NO MENU  "
621 ALARM 10
622 RETURN

0 REM left button
630 IF L>-1 THEN 619;
631 GOSUB 590

0 REM right button
640 IF L>-1 THEN 619;
641 GOTO 540

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
661 IF A > 11 THEN 670
662 A = zerocnt
663 GOTO 654

0 REM go, get connected
670 A = master $5
671 ALARM 10
672 RETURN

0 REM not busy, then scroll screen once
0 REM scroll again in 4 seconds
675 E = 1
676 ALARM 5
677 $8=$(G+900)[8];
678 GOTO 41

0 REM EO ALARM HANDLER --------------------------------

0 REM while showing menu detect press
0 REM and not release, so user see things faster
680 IF$0[$1[0]-64]=48THEN750;
681 IF$0[$1[1]-64]=49THEN770;
682 IF$0[$1[2]-64]=48THEN755;
683 W=0
684 RETURN


0 REM MENU HANDLER ---------------------------------------

0 REM MENU READING, BUFFER FILLING ------------
0 REM menu buffer is stored in lines 900 to 919
0 REM history buffer is stored in lines 920 to 949


0 REM check if we have our file opened
700 A = lcd$19[1]
701 H = 0
702 IF J = 1 THEN 707;
703 IF J = 0 THEN 705;
0 REM time expensive
704 A = close ;
705 A = open $1011 ;
706 J = 1 ;

0 REM move pointer to first byte
707 A = seek 0;

0 REM be FAST! no interrupts what's so ever
708 A = pioirq$12;

0 REM init $1012
709 A = hex8 L;
710 $1012=$0

0 REM go through file until buffer gets filled, or
0 REM there are no more menu options on L level

711 B = read 32;
712 IF B = 0 THEN 718;

0 REM check level
713 A = strcmp $1012;
714 IF A <> 0 THEN 711;

0 REM same level
715 $(H+900)=$0;
716 H=H+1;

0 REM loop
717 GOTO 711;
0 REM enable interrupts back
718 A = pioirq $6
719 RETURN

0 REM -------------------------------------------------------------------

0 REM HISTORY BUFFER FILLING, FLUSHING
0 REM save it
720 $(F+920)=$0;
721 F=F+1;

0 REM check if we filled the buffer
722 IF F>=20 THEN 725
723 RETURN

0 REM disable interrupts, get lock on files
725 A = pioirq$12
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

0 REM short button press handlers for while in menu
0 REM left button press, decrement menu options
750 G=G-1;
751 IF G>-1 THEN 760;
752 G=H-1;
753 GOTO 760;

0 REM right button press, increment menu options
755 G=G+1
756 IF G<H THEN 760;
757 G=0;
758 GOTO 760;

0 REM real display handler
0 REM register for ALARM so we give some time
0 REM to the user to think before we start scrolling
760 $8=$(G+900)[8];
761 E=0;
762 ALARM 7
763 GOTO 41;

0 REM middle button press, here's where the real
0 REM magic takes place....
0 REM first check for action
770 $0=$(G+900)[6];
771 A = strcmp"!!" ;
772 A = strcmp"ex";
773 IF A =0 THEN 800;
0 REM you could add more options here
0 REM just overwrite line 775
0 REM up to line 789 are free because of API
774 RETURN

0 REM show next level
0 REM update history (might sound crazy in
0 REM production enviroment, but while testing
0 REM this allows you to tell which options your users
0 REM uses most).
790 $0=$(G+900);
791 GOSUB 720;
0 REM get new pointers
792 L=x8toi$(G+900)[2];
793 A=x8toi$(G+900)[4];
794 G=A;
0 REM update menu
795 GOSUB 700;
0 REM display menu
796 GOTO 760;

0 REM exit from the menu
800 L = -1
801 A =lcd"BYE            "
802 ALARM 3
803 RETURN


0 REM we got connected to the server
0 REM send our content
@MASTER 850
850 PRINTM"INTERACTIVE\n"
851 INPUTM$0
852 A = enable 3
853 A = strcmp "GO\n"
854 IF A <> 0 THEN
855 IF J = 0 THEN 860; 
856 WAIT 1
857 GOTO 854;

0 REM the semaphore is free
0 REM lock it
860 J = 1;
861 PRINTM"HISTORY READY\n"
0 REM let the server get our history
862 WAIT 10
863 A = status;
864 IF A >= 100 THEN 958;
0 REM release semaphore
865 J = 0

0 REM check for menu lock
866 IF H = 0 THEN 870
867 WAIT 1
868 GOTO 866;

0 REM lock semaphore
870 H = 1
871 PRINTM"MENU READY\n"

