0 REM MONITOR CODE ------------------------------------------

0 REM this code uses message for interfacing the
0 REM server.

0 REM interrupt insertion point
0 REM user @ALARM pointer
21 GOTO 900;

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
0 REM display batt level
37 GOTO 460;
0 REM middle short button press
0 REM send message if paired
38 GOTO 700;
0 REM right short button press
0 REM update reading
39 GOTO 400;

0 REM LONG BUTTON PRESS HANDLER ----------------

0 REM long button press handler
0 REM long middle off
0 REM long left device menu
0 REM long right visible
0 REM we just calls functions from BASE code

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


