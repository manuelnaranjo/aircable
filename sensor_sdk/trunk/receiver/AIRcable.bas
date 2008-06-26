0 REM serial3 pio list 
1 @L@IT

0 REM name
4 AIRSensorSDK-Receiver

0 REM pio handler
6 P000000000001

0 REM message rate
0 REM never send messages
9 -1

0 REM we need some slight modifications
0 REM to @IDLE
0 REM instead of disabling the radio
0 REM we just go invisible.
101 A = slave -120

104 A = enable 3
105 RETURN

117 A = slave 120


@MESSAGE 950
950 WAIT 1
951 FOR B = 0 TO 3 
952 A = pioset ($1[4]-64)
953 A = pioclr ($1[4]-64)
954 RETURN 

