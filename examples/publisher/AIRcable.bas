@ERASE

0 REM Line $1 BT address of the accepted peer
1 0

0 REM file to upload
2 images.jpg
0 REM 2 hello.txt

0 REM number of devices in hash table
3 541

0 REM pin
5 1234

0 REM visible name
6 AIRpublisher

0 REM policy configuration
0 REM if $7[0]=49 '1' then we disconnect after 30
0 REM secs no matter if we're still sending or not
0 REM $7[0]=49 means just uploaded, don't clean
7 11

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
35 X = atoi $3

0 REM set name
37 $0 = $6
38 PRINTV " "
39 PRINTV $5
41 A = name $0


0 REM RS232 POWER ON out and on
42 A = pioout 3
43 A = pioset 3
0 REM RS232 POWER OFF out and on
44 A = pioout 11
45 A = pioset 11
0 REM RS232 DTR pin out and on
46 A = pioset 5
47 A = pioout 5
0 REM PIO12 goes high when pressed, add 
48 A = pioclr 12
49 A = pioin 12
50 A = pioirq "P000000000001"

51 PRINTU "\n\rSTARTUP "
52 PRINTU $0

0 REM button status in V
54 V = 0

55 IF $7[1]= 49 THEN 58
56 A = pioget 12
57 IF A = 0 THEN 280
58 $7[1]=48
59 ALARM 3
60 RETURN

@IDLE 70
70 REM A = slave 8
71 RETURN

90 ALARM 30
91 RETURN


@ALARM 98
0 REM handle button press
98 IF V = 1 THEN 270

0 REM K state variable
0 REM K = 0 need inq
0 REM K = 1 inq in progress
0 REM K = 2 inq with results, need to sort results and send messsages
0 REM K = 3 sending messages
0 REM K = 4 file is beeing sent
100 IF K = 0 THEN 106
101 IF K = 1 THEN 112
102 IF K = 2 THEN 123
103 IF K = 3 THEN 130
104 IF K = 4 THEN 170
105 RETURN

106 PRINTU "\n\rINQUIRY"
107 M = 0
108 A = inquiry 9
109 K = 1
110 ALARM 18
111 RETURN

0 REM inq finished?
112 A = status
113 IF A > 0 THEN 90
0 REM found something?
114 IF M > 0 THEN 119
115 K = 0
116 ALARM 2
117 PRINTU"\n\rNOTHING"
118 RETURN

0 REM we might have a winner
119 PRINTU"\n\rFOUND:
120 PRINTU M 
121 K = 2

0 REM print results
123 D = 0
124 K = 3
125 ALARM 1
126 FOR A = 0 TO M-1
127 PRINTU"\n\rFound: "
128 PRINTU $(A+L)
129 NEXT A

0 REM checked all the devices?
130 IF D = M THEN 165

0 REM generate hash, then check if devices has
0 REM being serviced or not
131 $0 = $(L + D)
132 GOSUB 200
133 B = strlen $(A+E)
134 IF B > 0 THEN 160
135 GOTO 140

0 REM put device into the table
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
149 PRINTU "\n\rto "
150 PRINTU $(L+D)
0 REM set sending name
151 $0=$2
152 A = bizcard $(L+D)

0 REM next state check status of sending in 30 secs
154 K = 4
0 REM next in list
155 D = D + 1
156 A = pioset G
157 ALARM 30
158 RETURN

160 D = D +1
161 A = pioclr G
162 GOTO 130

165 K = 0
166 PRINTU"\n\rDone All"
167 ALARM 2
168 RETURN

0 REM check status
170 A = status
171 K = 3
172 IF A = 0 THEN 185
173 IF $7[1] = 48 THEN 179
0 REM still connected, we disconnect forcefully
174 A = disconnect 3
175 PRINTU "\n\rPOLICY DISCONN"
176 A = pioclr J
177 A = pioset J
178 A = pioclr G
179 ALARM 5
180 RETURN

0 REM back to state send message
185 A = pioclr G
186 B = success
187 IF B > 0 THEN 195
188 IF B = 0 THEN 191
189 PRINTU"\n\rERROR SENDING"
190 GOTO 196
191 PRINTU"\n\rTIMEOUT
192 GOTO 196

195 PRINTU"\n\rFILE SENT"
196 A = close
197 ALARM 5
198 RETURN


0 REM hash calc function
0 REM Prime number to use $3 in X
200 A = 0;
201 FOR C = 0 TO 11
202   A = A + $0[C];
203 NEXT C
204 B = A / X
205 B = B * X
206 A = A - B
207 PRINTU "\n\rhash for "
208 PRINTU $0
209 PRINTU " "
210 PRINTU A
211 RETURN

@INQUIRY 220
220 ALARM 2;
221 $(L+M) = $0;
222 M = M+1;
223 K = 2;
224 A = pioset G;
225 A = pioclr G;
226 RETURN

@SLAVE 240
240 A = shell
241 RETURN

@PIO_IRQ 250
250 IF $0[12]=49 THEN 260;
251 V = 0
0 REM ignore any other event
252 RETURN

0 REM button press, save state, start ALARM
260 $2 = $0;
261 V = 1;
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

280 A = pioclr J; 
281 PRINTU"\n\rCleaning Table";
282 FOR B = 0 TO X;
283 $(B+E)="";
284 A = pioset G;
285 A = pioclr G;
286 NEXT B;
287 PRINTU"\n\rDone";
288 A = pioset J;
289 ALARM 1
290 RETURN

@PIN_CODE 295
295 $0 = $5
296 RETURN


