@ERASE

0 REM Line $1 BT address of the accepted peer
1 0

@INIT 50
0 REM debug
50 Z = 1
51 A = baud 1152
0 REM J stores the pio where the led is attached
53 J = 20
0 REM LED output an off
54 A = pioout J
55 A = pioclr J
56 A = enable 2
0 REM mark we're botting
57 T = 1000
0 REM L is the start line of the inq results table
0 REM M is the index inside the result table
0 REM K is our state variable
59 L = 900
60 M = 0
61 K = 0
62 A = zerocnt
0 REM some extra intialization
63 A = pioout 9
64 A = pioset 9
65 RETURN

0 REM @IDLE, we need this for debugging
@IDLE 90
90 IF T = 1000 THEN 95
91 A = slave -120
92 RETURN

0 REM on first boot we stay visible for 20 secs
95 A = slave 20
96 T = 0
97 ALARM 1
98 RETURN

@ALARM 100
0 REM K state variable
0 REM K = 0 need inq
0 REM K = 1 inq in progress,
0 REM inquiry with results
0 REM or sending message
100 IF K = 0 THEN 120
101 B = status
102 IF B > 0 THEN 130
103 IF K = 1 THEN 140
104 RETURN

0 REM start inquiry
120 M = 0
121 A = inquiry 9
122 K = 1
123 ALARM 20
124 RETURN

0 REM busy or nothing to do
130 A = pioset J;
131 A = pioclr J
132 ALARM 5
133 RETURN

0 REM do we have inquiry results?
140 IF M > 0 THEN 150
141 K = 0
142 GOTO 130

150 $0="Hello from AIRcable"
151 M = M - 1
152 A = message $(M+L)
153 A = pioset J
154 ALARM 10
155 RETURN

@INQUIRY 220
220 ALARM 2
221 $(L+M) = $0
222 M = M+1
223 K = 1
224 RETURN
