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
0 REM reading update handler starts at line 800
0 REM reading display handler needs to start at
0 REM line 900.

0 REM set our interrupt points
30 GOTO 800;
31 GOTO 850;


0 REM we'll store reading in $799


0 REM update reading.
800 $799 = $13[5]
801 $799[4] = 0
802 M = atoi $799
803 M = (M - 520) * 2
804 $0 = "TAMB|
805 PRINTV$799
806 $10 = $0
807 RETURN

0 REM display value generator
850 $0="AMB "
851 N = M / 20
852 PRINTV N
853 PRINTV "%C"
854 $11 = $0
855 RETURN



