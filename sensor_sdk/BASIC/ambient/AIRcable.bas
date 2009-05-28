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

0 REM type
19 MONITOR-AMBIENT

0 REM set our interrupt points
30 GOTO 500;
31 GOTO 520;


0 REM we'll store reading in $980
508 READING

0 REM update reading.
500 $508 = $13[5]
501 $508[4] = 0
502 M = atoi $508
503 M = (M - 520) * 2
504 $0 = "TAMB|
505 PRINTV$508
506 $10 = $0
507 RETURN

0 REM display value generator
520 $0="AMB "
521 N = M / 20
522 PRINTV N
523 PRINTV "%C"
524 $11 = $0
525 RETURN



