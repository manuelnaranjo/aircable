@ERASE

@INIT 10
0 REM LED output and on
10 A = pioset 20
11 A = baud 96
0 REM debug
12 Z = 0
14 RETURN

@IDLE 15
0 REM blink LED
15 A = pioset 20;
16 A = pioclr 20
0 REM slave for 5 seconds
17 A = slave 5
18 RETURN


@SLAVE 20
0 REM 5 seconds timeout to start shell with '+' and enter
0 REM when you have a slave connection over air
20 TIMEOUTS 5
21 INPUTS $0
22 IF $0[0] = 43 THEN 26
0 REM LED on
23 B = pioset 20
0 REM connect RS232
24 C = link 1
25 RETURN

0 REM start BASIC shell
26 A = shell
0 REM LED on
27 B = pioset 20
28 RETURN
