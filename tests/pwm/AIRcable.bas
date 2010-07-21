@ERASE

@INIT 10
10 A = pioset 20
11 A = pioout 9
12 A = pioclr 9
13 RETURN

@IDLE 20
@ALARM 20
20 FOR A = 0 TO 100
21 R = A;
22 B = pwm 9;
23 B = delayms 10
24 NEXT A
25 FOR A = 0 TO 100
26 R = 100-A;
27 B = pwm 9;
28 B = delayms 10
29 NEXT A
30 ALARM 1
31 RETURN
 