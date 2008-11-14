0 REM MONITOR CODE ------------------------------------------

0 REM this code uses message for interfacing the
0 REM server.

0 REM interrupt insertion point
0 REM user @ALARM pointer
21 GOTO 900;

0 REM left long button press
34 GOTO 630;
0 REM middle long button press
35 GOTO 600;
0 REM right long button press
36 GOTO 660;
0 REM left short button press
37 GOTO 730;
0 REM middle short button press 
38 GOTO 700;
0 REM right short button press
39 GOTO 760;

0 REM LONG BUTTON PRESS HANDLER ----------------

0 REM long button press handler
0 REM long middle off
0 REM long left device menu
0 REM long right visible

0 REM turn off
600 A = lcd "GOOD BYE";
601 ALARM 0;
602 A = pioset($1[3]-64)
603 A = pioclr($1[3]-64);
604 A = pioget($1[1]-64);
605 IF A = 1 THEN 602;
606 A = pioclr($1[4]-64);
607 A = lcd;
608 A = reboot;
609 FOR E = 0 TO 10;
610   WAIT 1
611 NEXT E;
612 RETURN

0 REM enable MENU
630 GOTO 285

0 REM make it visible, enable services
660 A = lcd "VISIBLE  "
661 A = slave 120
662 ALARM 140
663 A = enable 3
664 RETURN

0 REM EO LONG BUTTON HANDLE -----------------------


0 REM SHORT BUTTON PRESS HANDLER --------------
0 REM middle button send message
0 REM left button press update reading
0 REM right button press battery reading

0 REM message
700 A = strlen $5;
701 GOSUB 800;
702 IF A > 11 THEN 940;
703 A = lcd"NOT PAIRED  "
704 ALARM 5
705 RETURN

0 REM battery reading
730 $0 = "BATT "
731 PRINTV $7
732 $8=$0
733 ALARM 5
734 GOTO 40

0 REM update reading
760 ALARM 30 
761 A = lcd"WAIT . . . "
762 GOSUB 30
763 GOSUB 31
764 $8=$11
765 GOSUB 40
766 RETURN

0 REM EO SHORT BUTTON HANDLER --------------------


0 REM ALARM HANDLER ---------------------------------------
0 REM we might be sending a message
0 REM in such case we need to check for status
0 REM this avoids some blocks that might
0 REM happen because we don't let the processor
0 REM do it's work.
900 IF O <> 0 THEN 955;

901 A = pioirq $12;

902 GOSUB 761

0 REM we need to automatically message?
907 IF V > 0 THEN 920;

0 REM @alarm ended
0 REM trigger again
908 ALARM 15;
909 A = pioirq $6;
910 A = nextsns 1;
911 RETURN

0 REM check for time
920 A = strlen $5;
921 IF A < 12 THEN 908;
922 A = readcnt;
923 IF A > V THEN 930;
924 GOTO 908;

0 REM we can't send 2 messages at the same time
930 A = status;
931 IF A > 1000 THEN 908;

0 REM prepare msg
940 A = lcd"MESSAGE     ";
941 $0[0] = 0;
942 PRINTV"BATT|";
943 PRINTV$7;
944 PRINTV"|";
945 PRINTV $10;
946 A = message $5;
947 O = 1;
948 ALARM 5;
949 A = pioset ($1[4]-64);
950 RETURN

0 REM check for message sending
955 A = status;
956 IF A < 1000 THEN 960;
957 ALARM 5;
958 RETURN

960 A = pioclr ($1[4]-64);
961 A = success;
962 IF A > 0 THEN 970;
963 IF A = 0 THEN 966;
964 A = lcd "FAILED      ";
965 GOTO 971;
966 A = lcd "TIMEOUT     ";
967 GOTO 971;

970 A = lcd "SUCCESS    ";

0 REM leave it on the screen
971 A = zerocnt;
972 WAIT 2

973 A = lcd $11;
974 O = 0;
975 GOTO 908;

0 REM EO ALARM HANDLER --------------------------------


