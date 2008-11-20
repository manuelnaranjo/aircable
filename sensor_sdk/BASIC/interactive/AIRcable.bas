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
20 GOTO 700;

0 REM @ALARM extension
21 GOTO 750;

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
37 GOTO 740;
0 REM middle short button press 
38 GOTO 720;
0 REM right short button press
39 GOTO 745;


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
212 IF O>-1 THEN 790;

0 REM some more init
700 O = -1;
701 M = 0;
702 N = 0;
0 REM we assume there's no buffer at all
0 REM and history buffer has been flused
703 M = 0;
704 L = 0;
705 K = 0;
706 RETURN


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
720 IF O > -1 THEN 729;
721 A = exist $1011
722 IF A = 0 THEN 730
0 REM point to root, load menu, start the magic
723 O = 0
724 L = 0
725 GOSUB 800
726 GOTO 880

0 REM RETURN on button release
729 RETURN

0 REM ohoh! no menu file found.
730 A = lcd"NO MENU  "
731 ALARM 10
732 RETURN

0 REM left button
740 IF O>-1 THEN 729;
741 GOTO 590

0 REM right button
745 IF O>-1 THEN 729;
746 GOTO 540

0 REM EO SHORT BUTTON HANDLER --------------------


0 REM ALARM HANDLER ---------------------------------------
0 REM if more than 1 hour happened since last time
0 REM we sent our records, then we send again.
750 A = readcnt;
751 IF A > 3600 THEN 760;
0 REM jf you need any more
0 REM checkings, you can do a GOSUB
0 REM in line 652 to your code.
752 REM reserved
753 IF O > -1 THEN 780;
754 A = lcd "READY     ";
755 ALARM 15;
0 REM if we're not busy then
0 REM get new reading.
756 A = nextsns 1
757 RETURN

0 REM send content
760 A = strlen $5
761 IF A > 11 THEN 770
762 A = zerocnt
763 GOTO 754

0 REM go, get connected
770 A = master $5
771 ALARM 10
772 RETURN

0 REM not busy, then scroll screen once
0 REM scroll again in 4 seconds
780 E = 1
781 ALARM 5
782 $8=$(L+960)[8];
783 A = nextsns 4
784 GOTO 41

0 REM EO ALARM HANDLER --------------------------------

0 REM while showing menu detect press
0 REM and not release, so user see things faster
790 IF$0[$1[0]-64]=48THEN860;
791 IF$0[$1[1]-64]=49THEN890;
792 IF$0[$1[2]-64]=48THEN870;
793 W=0
794 RETURN


0 REM MENU HANDLER ---------------------------------------

0 REM MENU READING, BUFFER FILLING ------------
0 REM menu buffer is stored in lines 960 to 979
0 REM history buffer is stored in lines 980 to 999


0 REM check if we have our file opened
800 A = lcd$19[1]
801 M = 0
802 IF N = 1 THEN 807;
803 IF N = 0 THEN 805;
0 REM time expensive
804 A = close ;
805 A = open $1011 ;
806 N = 1 ;

0 REM move pointer to first byte
807 A = seek 0;

0 REM be FAST! no interrupts what's so ever
808 A = pioirq$12;

0 REM init $1012
809 A = hex8 L;
810 $1012=$0

0 REM go through file until buffer gets filled, or
0 REM there are no more menu options on L level

811 B = read 32;
812 IF B = 0 THEN 818;

0 REM check level
813 A = strcmp $1012;
814 IF A <> 0 THEN 811;

0 REM same level
815 $(M+960)=$0;
816 M=M+1;

0 REM loop
817 GOTO 811;
0 REM enable interrupts back
818 A = pioirq $6
819 RETURN

0 REM -------------------------------------------------------------------

0 REM HISTORY BUFFER FILLING, FLUSHING
0 REM save it
830 $(K+980)=$0;
831 K=K+1;

0 REM check if we filled the buffer
832 IF K>=20 THEN 840
833 RETURN

0 REM disable interrupts, get lock on files
840 A = pioirq$12
841 A =lcd"FLUSHING"
842 IF N=0 THEN 845;
843 IF N=1 THEN 847;
0 REM menu was opened, now close it
0 REM this will take a while
844 A = close;
845 N = 1;

0 REM open and point to last byte,
0 REM this will create the file if needed
846 A = append $1010;

847 FOR B=0 TO K
848 $0=$(B+980);
0 REM assume length
849 A = write 32;
850 NEXT B

0 REM now do the really time consuming thingy
851 A = close;
852 N = 0;
853 K = 0;
0 REM enable interrupts back
854 A = pioirq $6
855 A = lcd"DONE       "
856 RETURN

0 REM -------------------------------------------------------------------

0 REM short button press handlers for while in menu
0 REM left button press, decrement menu options
860 L=L-1;
861 IF L>-1 THEN 880;
862 L=M-1;
863 GOTO 880;

0 REM right button press, increment menu options
870 L=L+1
871 IF L<M THEN 880;
872 L=0;
873 GOTO 880;

0 REM real display handler
0 REM register for ALARM so we give some time
0 REM to the user to think before we start scrolling
880 $8=$(L+960)[8];
881 E=0;
882 ALARM 7
883 GOTO 41;

0 REM middle button press, here's where the real
0 REM magic takes place....
0 REM first check for action
890 $0=$(L+960)[6];
891 A = strcmp"!!" ;
892 IF A = 0 THEN 910;
894 A = strcmp"ex";
895 IF A =0 THEN 920;
0 REM you could add more options here
0 REM just overwrite line 896
0 REM up to line 909 are free because of API
896 RETURN

0 REM show next level
0 REM update history (might sound crazy in
0 REM production enviroment, but while testing
0 REM this allows you to tell which options your users
0 REM uses most).
910 $0=$(L+960);
911 GOSUB 830;
0 REM get new pointers
912 O=x8toi$(L+960)[2];
913 A=x8toi$(L+960)[4];
914 G=A;
0 REM update menu
915 GOSUB 800;
0 REM display menu
916 GOTO 880;

0 REM exit from the menu
920 O = -1
921 A =lcd"BYE            "
922 ALARM 3
923 RETURN


0 REM we got connected to the server
0 REM send our content
@MASTER 930
930 PRINTM"INTERACTIVE\n"
931 INPUTM$0
932 A = enable 3
933 A = strcmp "GO\n"
934 IF A <> 0 THEN
935 IF N = 0 THEN 938; 
936 WAIT 1
937 GOTO 934;

0 REM the semaphore is free
0 REM lock it
938 N = 1;
939 PRINTM"HISTORY\n"
0 REM let the server get our history
940 WAIT 10
941 A = status;
942 IF A >= 100 THEN 948;
0 REM release semaphore
943 N = 0

0 REM check for menu lock
944 IF N = 0 THEN 947
945 WAIT 1
946 GOTO 944;

0 REM lock semaphore
947 N = 2
948 PRINTM"MENU READY\n"
949 RETURN


