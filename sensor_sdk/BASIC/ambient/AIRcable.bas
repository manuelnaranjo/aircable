0 REM sample: ambient sensor handler
0 REM this sample shows how to do basic
0 REM sensor handling.
0 REM 
0 REM ambient sensor is attached to one of
0 REM the analog inputs, so we need to use
0 REM information provided by the sdk regarding
0 REM sensor reading. That information is on $13.
0 REM SDK will expect us to store messaging
0 REM information on $10, and display stuff in
0 REM $11.
0 REM reading update handler starts at line 980
0 REM reading display handler needs to start at
0 REM line 990.

0 REM set our interrupt points
30 GOTO 981;
31 GOTO 990;


0 REM we'll store reading in $980
980 READING

0 REM update reading.
981 $980 = $13[5]
982 $980[4] = 0
983 M = atoi $980
984 M = (M - 520) * 2
985 $0 = "TAMB|
986 PRINTV$980
987 $10 = $0
988 RETURN

0 REM display value generator
990 $0="AMB "
991 N = M / 20
992 PRINTV N
993 PRINTV "%C"
994 $11 = $0
995 RETURN



