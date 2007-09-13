@ERASE

0 REM Line $1 BT address of the accepted peer
1 0

0 REM file to upload
2 images.jpg

0 REM number of devices in hash table
3 541

0 REM pin
5 1234

0 REM visible name
6 AIRpublisher

0 REM time to resend to same device in minutes 
7 2

0 REM last counter time.
8 0

0 REM temp
19 temp

@INIT 20
0 REM debug
20 Z = 1
21 A = baud 1152
0 REM we must be visible
22 A = slave 5
0 REM J stores the pio where the led is attached
23 J = 20
0 REM LED output an don
24 A = pioout J
25 A = pioset J
26 A = enable 2
0 REM E is the start line of the hash table
27 E = 300
0 REM L is the start line of the inq results table
0 REM M is the index inside the result table
28 L = 900
29 M = 0
30 K = 0
31 A = zerocnt
0 REM X stores the amount of devices in the hash table
0 REM w stores the time window.
33 X = atoi $3
34 W = atoi $7

35 WAIT 3

0 REM set name
36 $0 = $6
37 PRINTV " "
38 PRINTV $5
39 PRINTU $0
40 A = name $0

41 ALARM 3

42 RETURN

@PIN_CODE 50
50 $0 = $5
51 RETURN

@IDLE 60
0 REM 60 A = slave 8
61 RETURN

90 ALARM 30
91 RETURN


@ALARM 99
99 GOSUB 230

0 REM K state variable
0 REM K = 0 need inq
0 REM K = 1 inq in progress
0 REM K = 2 inq with results, need to sort results and send messsages
0 REM K = 3 sending messages
0 REM K = 4 file needs to be closed
100 IF K = 0 THEN 109
101 B = status
102 IF B > 0 THEN 90
103 IF K = 1 THEN 114
104 IF K = 2 THEN 125
105 IF K = 3 THEN 130
106 IF K = 4 THEN 170
107 RETURN

109 M = 0
110 A = inquiry 9
111 K = 1
112 ALARM 10
113 RETURN

114 A = status
115 IF A > 0 THEN 118
116 IF M > 0 THEN 120
117 K = 0
118 ALARM 2
119 RETURN

120 K = 2
121 GOTO 118

125 D = 0
126 K = 3
127 ALARM 1
128 RETURN

130 $0 = $(L + D)
131 GOSUB 200
0 REM we will forget about collisions
132 GOSUB 230
133 B = strlen $(A+E)
134 IF B > 0 THEN 160
135 GOTO 140

140 $0[0] = 0
141 FOR B = 0 TO 11
142 PRINTV $(L+D)[B]
143 NEXT B
144 $19 = $0
145 PRINTV " "
146 PRINTV C
147 $(A+E) = $0

0 REM obex the file
148 A = open $2
149 $0 = $2
150 A = bizcard $(L+D)
151 D = D +1                             
152 IF D = M THEN 165
153 ALARM 60
154 RETURN

160 B = atoi $0(L+D)[13]
161 IF (B-C) > W THEN 140
162 GOTO 151

165 K = 4
166 ALARM 30
167 RETURN

170 A = status
171 IF A = 0 THEN 175
172 ALARM 5
173 RETURN

175 K = 0
176 ALARM 2
177 RETURN

0 REM hash calc function
0 REM Prime number to use $3
200 A = 0;
201 FOR C = 0 TO 11
202 A = A + $0[C];
203 NEXT C
204 B = A / X
205 B = B * X
206 A = A - B
207 RETURN

@INQUIRY 220
220 ALARM 2
221 $(L+M) = $0
222 M = M+1
223 K = 2
224 RETURN

0 REM update partial counter
230 A = readcnt
231 B = atoi $8
232 C = A + B
233 $0[0] = 0
234 PRINTV C
235 $8 = $0
236 A = zerocnt
237 RETURN

@SLAVE 240
240 A = shell
241 RETURN

