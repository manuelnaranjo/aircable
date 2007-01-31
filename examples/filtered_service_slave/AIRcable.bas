@ERASE

0 REM Line $1 will store the address filter we are going to target
1 00A8FF

@INIT 10
0 REM LED output and on
10 A = pioset 20
11 A = baud 96
0 REM debug
12 Z = 1
14 RETURN

@IDLE 15
0 REM blink LED
15 A = pioset 20;
16 A = pioclr 20
0 REM slave for 5 seconds
17 A = slave 5
18 RETURN


@SLAVE 20
0 REM If we now call to getconn, we will get the peer addr that wants to connect
0 REM with us on $0
20 A = getconn
21 PRINTU $0
22 A = strcmp $1;
23 IF A <> 0 THEN 33
0 REM 5 seconds timeout to start shell with '+' and enter
0 REM when you have a slave connection over air
24 TIMEOUTS 5
25 INPUTS $0
26 IF $0[0] = 43 THEN 30
0 REM LED on
27 B = pioset 20
0 REM connect RS232
28 C = link 1
29 RETURN

0 REM start BASIC shell
30 A = shell
0 REM LED on
31 B = pioset 20
32 RETURN

33 A = disconnect 0
34 RETURN

