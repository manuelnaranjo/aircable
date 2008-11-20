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
30 GOTO 600;
31 GOTO 610;


0 REM we'll store reading in $980
609 READING

0 REM update reading.
600 $609 = $13[5]
601 $609[4] = 0
602 M = atoi $609
603 M = (M - 520) * 2
604 $0 = "TAMB|
605 PRINTV$609
606 $10 = $0
607 RETURN

0 REM display value generator
610 $0="AMB "
611 N = M / 20
612 PRINTV N
613 PRINTV "%C"
614 $11 = $0
615 RETURN



