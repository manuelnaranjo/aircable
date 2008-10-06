0 REM J = blue led
0 REM K = green led
0 REM U = button

53 J = 20
54 K = 9
55 U = 12

0 REM init UART
0 REM RS232 POWER ON out and on
56 A = pioout 3
57 A = pioset 3
0 REM RS232 POWER OFF out and on
58 A = pioout 11
59 A = pioset 11
0 REM RS232 DTR pin out and on
60 A = pioset 5
61 A = pioout 5

62 A = baud 1152
