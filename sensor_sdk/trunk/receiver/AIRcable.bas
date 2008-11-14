0 REM serial3 pio list 
1 @L@IT

0 REM name
4 AIRSensorSDK-Receiver

0 REM pio handler
6 P000000000001

0 REM message rate
0 REM never send messages
9 -1


0 REM we our own @IDLE
@IDLE 100
1000 IF Q = 100 THEN 1010
1001 A = slave -120
1002 ALARM 1
1003 RETURN

0 REM first boot, update display
0 REM visible for 30 seconds
0 REM don't message
1010 A = lcd "WAIT . . . "
1011 GOSUB 30
1012 GOSUB 31
1013 $8=$11
1014 GOSUB 40
1015 P = 1
1016 A = nextsns 1
1017 A = slave 30
1018 Q = 0
1019 P = 1
1020 A = pioirq $6
1021 RETURN

@MESSAGE 950
950 WAIT 1
951 FOR B = 0 TO 3 
952 A = pioset ($1[4]-64)
953 A = pioclr ($1[4]-64)
954 RETURN 

