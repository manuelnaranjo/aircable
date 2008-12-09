0 REM history file
1020 history.txt

0 REM menu file
1021 menu.txt

0 REM RESERVED
1022 RES

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
34 GOTO 205;
0 REM middle long button press 
0 REM turn off
35 GOTO 410;
0 REM right long button press
0 REM make visible
36 GOTO 430;

0 REM left short button press
37 GOTO 640;
0 REM middle short button press 
38 GOTO 620;
0 REM right short button press
39 GOTO 645;


0 REM state variable O
0 REM O = -1 not showing menu
0 REM O = 0 showing root
0 REM O = 1 showing menu 1
0 REM O = N, N<255 showing menu N
0 REM O = N, N> 255 doing X activity
0 REM K internal counter
0 REM N = 0 no files open
0 REM N = 1 history file opened
0 REM N = 2 menu file opened
0 REM M menu buffer length
0 REM L menu buffer pointer
0 REM K history buffer length (equals pointer)

0 REM hack @PIO_IRQ to make it faster
173 IF O>-1 THEN 690;

0 REM some more init
600 O = -1;
601 M = 0;
602 N = 0;
0 REM we assume there's no buffer at all
0 REM and history buffer has been flused
603 M = 0;
604 L = 0;
605 K = 0;
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
620 IF O > -1 THEN 629;
621 A = exist $1021
622 IF A = 0 THEN 630
0 REM point to root, load menu, start the magic
623 O = 0
624 L = 0
625 GOSUB 700
626 GOTO 780

0 REM RETURN on button release
629 RETURN

0 REM ohoh! no menu file found.
630 A = lcd"NO MENU  "
631 ALARM 10
632 RETURN

0 REM left button
640 IF O>-1 THEN 629;
641 GOTO 400

0 REM right button
645 IF O>-1 THEN 629;
646 GOTO 460

0 REM EO SHORT BUTTON HANDLER --------------------


0 REM ALARM HANDLER ---------------------------------------
0 REM if more than 1 hour happened since last time
0 REM we sent our records, then we send again.
650 A = readcnt;
651 IF A > 3600 THEN 660;
0 REM jf you need any more
0 REM checkings, you can do a GOSUB
0 REM in line 652 to your code.
652 REM reserved
653 IF O > -1 THEN 680;
654 A = lcd "READY     ";
655 ALARM 15;
0 REM if we're not busy then
0 REM get new reading.
656 A = nextsns 1
657 RETURN

0 REM send content
660 A = strlen $5
661 IF A > 11 THEN 670
662 A = zerocnt
663 GOTO 654

0 REM go, get connected
670 A = strlen $5
671 IF A < 12 THEN 676
672 A = master $5
673 ALARM 15
674 $8="CONNECT"
675 GOTO 40

676 $8="NOT PAIR"
677 GOTO 40

0 REM not busy, then scroll screen once
0 REM scroll again in 10 seconds
680 E = 1
681 ALARM 10
682 $8=$(L+960)[8];
683 A = nextsns 4
684 GOTO 41

0 REM EO ALARM HANDLER --------------------------------

0 REM while showing menu detect press
0 REM and not release, so user see things faster
690 IF$0[$1[0]-64]=48THEN760;
691 IF$0[$1[1]-64]=49THEN790;
692 IF$0[$1[2]-64]=48THEN770;
693 W=0
694 RETURN


0 REM MENU HANDLER ---------------------------------------

0 REM MENU READING, BUFFER FILLING ------------
0 REM menu buffer is stored in lines 960 to 979
0 REM history buffer is stored in lines 980 to 999


0 REM check if we have our file opened
700 A = lcd"WAIT . . . "
701 M = 0
702 IF N = 1 THEN 707;
703 IF N = 0 THEN 705;
0 REM time expensive
704 A = close ;
705 A = open $1021 ;
706 N = 1 ;

0 REM move pointer to first byte
707 A = seek 0;

0 REM be FAST! no interrupts what's so ever
708 A = pioirq$12;

0 REM init $1012
709 A = hex8 O;
710 $1022=$0

0 REM go through file until buffer gets filled, or
0 REM there are no more menu options on L level

711 B = read 32;
712 IF B = 0 THEN 718;

0 REM check level
713 A = strcmp $1022;
714 IF A <> 0 THEN 711;

0 REM same level
715 $(M+960)=$0;
716 M=M+1;

0 REM loop
717 GOTO 711;
0 REM enable interrupts back
718 A = pioirq $6
719 RETURN

0 REM -------------------------------------------------------------------

0 REM HISTORY BUFFER FILLING, FLUSHING
0 REM save it
730 $(K+980)=$0;
731 K=K+1;

0 REM check if we filled the buffer
732 IF K>=20 THEN 740
733 RETURN

0 REM disable interrupts, get lock on files
740 A = pioirq$12
741 A =lcd"FLUSHING"
742 IF N=0 THEN 745;
743 IF N=1 THEN 747;
0 REM menu was opened, now close it
0 REM this will take a while
744 A = close;
745 N = 1;

0 REM open and point to last byte,
0 REM this will create the file if needed
746 A = append $1020;

747 FOR B=0 TO K-1
748 $0=$(B+980);
0 REM assume length
749 A = write 32;
750 NEXT B

0 REM now do the really time consuming thingy
751 A = close;
752 N = 0;
753 K = 0;
0 REM enable interrupts back
754 A = pioirq $6
755 A = lcd"DONE       "
756 RETURN

0 REM -------------------------------------------------------------------

0 REM short button press handlers for while in menu
0 REM left button press, decrement menu options
760 L=L-1;
761 IF L>-1 THEN 780;
762 L=M-1;
763 GOTO 780;

0 REM right button press, increment menu options
770 L=L+1
771 IF L<M THEN 780;
772 L=0;
773 GOTO 780;

0 REM real display handler
0 REM register for ALARM so we give some time
0 REM to the user to think before we start scrolling
780 $8=$(L+960)[8];
781 E=0;
782 ALARM 10
783 GOTO 41;

0 REM middle button press, here's where the real
0 REM magic takes place....
0 REM first check for action
790 $0=$(L+960)[6];
791 A = strcmp"!!" ;
792 IF A=0 THEN 820;
793 A = strcmp"ex";
794 IF A=0 THEN 830;
795 A = strcmp"HI"
796 IF A=0 THEN 670;
0 REM you could add more options here
0 REM just overwrite line 795
0 REM up to line 819 are free because of API
797 RETURN

0 REM show next level
0 REM update history (might sound crazy in
0 REM production enviroment, but while testing
0 REM this allows you to tell which options your users
0 REM uses most).
820 $0=$(L+960);
821 GOSUB 730;
0 REM get new pointers
822 O=x8toi$(L+960)[2];
823 A=x8toi$(L+960)[4];
824 L=A;
0 REM update menu
825 GOSUB 700;
0 REM display menu
826 GOTO 780;

0 REM exit from the menu
830 O = -1
831 A =lcd"BYE            "
832 ALARM 3
833 RETURN


0 REM we got connected to the server
0 REM send our content
@MASTER 897
897 $8="SUCCESS"
898 GOSUB 40
899 ALARM 0
900 PRINTM"INTERACTIVE\n"
901 TIMEOUTM 20
902 INPUTM$0
903 A = enable 3
904 A = strcmp "GO"
905 IF A <> 0 THEN 931
906 IF N = 0 THEN 910; 

0 REM the semaphore is free
0 REM lock it
907 N = 1;
908 A = append $1020
910 PRINTM"HISTORY\n"
0 REM flush history to file first
912 GOSUB 740
914 A = lcd "SENDING "
915 A = open $1020
916 GOSUB 470
917 A = close
918 A = delete $1020

0 REM now open the other file
921 N = 2
922 PRINTM"MENU\n"
923 A = open $1021
924 GOSUB 470
925 A = close
926 N = 0 
927 A = disconnect 1
928 ALARM 5
929 $8="DONE
930 GOTO 40

0 REM check if we need to get
0 REM into service mode, otherwise
0 REM there isn't much we can do now.
931 A=strcmp"SERVICE"
932 IF A = 0 THEN 940
933 GOTO 924

0 REM service mode, you can do something
0 REM fancy here
940 $8="SERVICE"
941 GOSUB 40
942 A = slave 20
943 A = enable 3
944 RETURN


