@ERASE

0 REM addr
1 0050C2585EAA

@INIT 10
10 A = baud 1152
11 Z = 1
12 A = pioout 10
13 A = pioout 9
14 A = pioclr 10
15 A = pioset 9
16 A = disable 3
17 U = 0
18 RETURN

@IDLE 19
19 ALARM 0
20 A = slave 10
21 A = pioset 10
22 A = pioclr 10
23 A = status
24 IF A < 10 THEN 27
25 A = disconnect 1
26 ALARM 0
27 RETURN

@SLAVE 30
30 A = pioset 10
31 A = pioclr 9
32 ALARM 1
33 RETURN

@ALARM 40
40 A = pioset 9
41 A = pioclr 9
42 A = status
43 IF A > 10 THEN 46
44 A = master $1
45 ALARM 10
46 RETURN

@MASTER 50
50 A = pioset 10
51 A = link 3
52 RETURN


