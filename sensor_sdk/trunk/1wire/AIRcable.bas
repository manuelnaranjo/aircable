0 REM serial3 pio list
1 @L@IT

0 REM name
4 AIRsensorSDK

0 REM pio handler
6 P000000000001

0 REM set our interrupt points
20 GOTO 950;
30 GOTO 800;


0 REM @INIT
0 REM RS232_off set
950 A = pioout 11
951 A = pioset 11
0 REM RS232_on set
952 A = pioout 3
953 A = pioset 3
0 REM DTR output positive to power sensor
954 A = pioout 5
955 A = pioclr 5
0 REM DSR needs to go low
956 A = pioout 1
957 A = pioclr 1
0 REM baud rate
958 A = baud 96
0 REM go back to original init
959 GOTO 65

0 REM temporary 799
0 REM sensor reading
800 PRINTU"D"
801 TIMEOUTU 10
802 INPUTU $799
803 $10=$799[17]
804 $799="1-WIRE|"
805 PRINTV $10
806 $10=$799
807 RETURN

