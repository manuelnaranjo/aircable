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
20 Z = 0
21 A = baud 1152
0 REM we must be visible
22 A = slave 5
0 REM J stores the pio where green the led is attached
23 J = 9
0 REM LED output and on
24 A = pioout J
25 A = pioset J
0 REM G stores the pio where the blue led is attached
26 G = 20
27 A = pioout G
28 A = pioclr G
0 REM make ftp visible
29 A = enable 2
0 REM E is the start line of the hash table
30 E = 300
0 REM L is the start line of the inq results table
0 REM M is the index inside the result table
31 L = 900
32 M = 0
33 K = 0
34 A = zerocnt
0 REM X stores the amount of devices in the hash table
0 REM w stores the time window.
35 X = atoi $3
36 W = atoi $7

0 REM set name
37 $0 = $6
38 PRINTV " "
39 PRINTV $5
40 PRINTU $0
41 A = name $0

0 REM start button
42 A = pioclr 12
43 A = pioin 12
44 A = pioirq "P000000000001"

45 ALARM 3
46 W = 0

47 RETURN

@PIN_CODE 50
50 $0 = $5
51 RETURN

@IDLE 60
60 REM A = slave 8
61 RETURN

90 ALARM 30
91 RETURN


@ALARM 98
0 REM handle button press
98 IF W = 1 THEN 270
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
112 ALARM 12
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
150 PRINTU "to "
151 PRINTU $(L+D)
152 PRINTU "\r\n"
153 A = bizcard $(L+D)
154 D = D +1
155 A = pioset G
156 K = 4
157 ALARM 30
158 RETURN

160 B = atoi $0(L+D)[13]
161 IF (B-C) > W THEN 140
162 GOTO 151

0 REM check status
170 A = status
171 IF A = 0 THEN 180
172 A = disconnect 3
173 A = pioclr J
174 A = pioset J
175 GOTO 180

180 K = 3
181 ALARM 2
182 A = pioclr G
183 RETURN

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

@INQUIRY 217
217 ALARM 2;
218 $(L+M) = $0;
0 REM debug
219 PRINTU "found "
220 PRINTU $0
221 PRINTU "\r\n"
222 M = M+1;
223 K = 2;
224 A = pioset G;
225 A = pioclr G;
226 RETURN

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

@PIO_IRQ 250
250 IF $0[12]=49 THEN 260;
0 REM ignore any other event
251 W = 0;
252 RETURN

0 REM button press, save state, start ALARM
260 $2 = $0;
261 W = 1;
262 ALARM 3
263 RETURN

0 REM as button wasn't released yet, we wait until it's
0 REM released and turn off the device
270 ALARM 0
271 A = pioclr G
272 A = pioclr J
273 A = pioget 12
274 IF A = 1 THEN 273
275 A = reboot
276 FOR E = 0 TO 10
277 WAIT 1
273 NEXT E
274 RETURN

