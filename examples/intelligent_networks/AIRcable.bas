@ERASE

0 REM Routing table information:
0 REM BTADDR NEXT JUMP
0 REM Each line has BTADDR between char 0 and 11
0 REM space in char 12
0 REM NEXT (stores a line number) chars 13 - 15
0 REM space in char 16
0 REM JUMP chars 18 and 19, number that tells how many jumps are requested to
0 REM    this device, only used for stadistics
0 REM Routing table stored at: $U
0 REM               size:      K  elements

0 REM state var, and err code table
0 REM E will be used for state
0 REM E = 0 idle (slave channel opened)
0 REM E = 1 slave connected - route
0 REM E = 2 slave connected - connecting to next
0 REM E = 3 slave connected - connected to next
0 REM E = 4 slave connected - end of line device
0 REM E = 5 in command line

0 REM 1 stores the peer we had been requested to route, it is the end of line
0 REM device
1 0

0 REM 2 stores the next device addr
2 0

0 REM 3 is a temp
3 temp

@INIT 50
50 Z = 1
0 REM J stores the pio where the led is attached
51 J = 3
0 REM LED output an done
52 A = pioset J
53 A = baud 1152
54 E = 0
55 A = zerocnt
56 A = uartint
0 REM I stores the amount of times we tried to connect to a device
0 REM F stores the maximun number of trials to get connected
57 F = 5
58 U = 450
59 K = 541
60 RETURN

@IDLE 100
@ALARM 100
100 IF E = 0 THEN 110
101 IF E = 1 THEN 115
102 IF E = 2 THEN 160
103 IF E = 3 THEN 170
104 IF E = 4 THEN 195
105 IF E = 5 THEN 255
106 RETURN

0 REM we are not connected, then we open the slave channel for 5 secs
110 A = pioset J
111 A = pioclr J
112 A = slave 5
113 RETURN

0 REM the slave is connected, we need to route
115 A = strlen $1
116 IF A <> 12 THEN 130
117 $0 = $1
118 GOSUB 150
119 C = strlen $(U + A);
120 IF C <> 19 THEN 130
121 B = atoi $(U+A)[13];
122 IF B = 0 THEN 128 
123 $2 = $(U+B);
124 E = 2
125 ALARM 1
126 I = 0
127 RETURN
128 B = A
129 GOTO 123

0 REM this methods are called when there is a problem in the connection,
0 REM the problem can be that the device is not routed, or that there is a 
0 REM connection problem (next peer not responding)
130 A = status
131 IF A = 0 THEN 139
132 PRINTS"COULDN'T REACH: ";
133 PRINTS $1;
134 PRINTS"\n\rERR CODE:";
135 PRINTS E
136 A = disconnect 0
137 GOTO 144

139 ALARM 1
140 PRINTU"COULDN'T REACH TO: ";
141 PRINTU $1;
142 PRINTU"\n\rERR CODE:";
143 PRINTU E
144 E = 0
145 $1 = "0"
146 A = pioclr J
147 RETURN

0 REM hash calc function
0 REM Prime number to use K
150 A = 0;
151 FOR C = 0 TO 11
152 A = A + $0[C];
153 NEXT C
154 B = A / K
155 B = B * K
156 A = A - B
157 RETURN

0 REM slave connected - connecting to next
160 IF I = F THEN 130
161 A = master $2
162 ALARM 5
163 A = pioclr J
164 A = pioset J
165 I = I + 1;
166 RETURN

0 REM slave connected - connected to next
170 A = status
171 IF A < 11 THEN 175
172 ALARM 10
173 RETURN

175 IF A < 10 THEN 185
176 A = getaddr
177 PRINTM $0
178 PRINTM" is out\n\r"
179 A = disconnect 1
180 E = 0
181 ALARM 5
182 $1="0"
183 $2="0"
184 RETURN

185 A = getaddr
186 PRINTS $0
187 PRINTS" is out\n\r"
188 A = disconnect 0
189 GOTO 180

190 ALARM 10
191 RETURN

0 REM end of line, or shell active
195 A = status
196 IF A > 0 THEN 190
197 E = 0
198 ALARM 5
199 RETURN

@SLAVE 210
210 TIMEOUTS 10
211 INPUTS $0
212 A = strlen $0
213 IF A < 12 THEN 240

0 REM valid input
214 $3 = $0
215 A = getaddr
217 A = strcmp $3
218 IF A = 0 THEN 230

0 REM we haven't reached the end yet.
219 $1 = $3
220 E = 1
221 PRINTS$0
222 PRINTS" ONLINE\n\r";
223 ALARM 1
224 RETURN

0 REM we reached the end of line
230 PRINTS $0
231 PRINTS" REACHED\n\r";
232 A = link 1
233 E = 4
234 RETURN

240 IF $0[0] = 43 THEN 257
241 PRINTS"TIMEOUT\n\r"
242 A = disconnect 0
243 E = 0
244 ALARM 5
245 RETURN

246 A = shell
247 E = 5
248 ALARM 0
249 RETURN

@MASTER 250
250 PRINTM $1
251 E = 3
252 A = link 3
253 ALARM 10
254 RETURN

0 REM s shell
0 REM i inquiry
0 REM r route
0 REM l list
0 REM e exit
257 E = 5
258 PRINTS "\n\r> "
0 REM 259 TIMEOUTS 5
260 INPUTS $0
261 IF $0[0] = 105 THEN 290
262 IF $0[0] = 115 THEN 246
263 IF $0[0] = 114 THEN 267
264 IF $0[0] = 97 THEN 279
265 IF $0[0] = 101 THEN 188
266 GOTO 259

267 PRINTS"Who you want to "
268 PRINTS"reach: "
269 INPUTS $0
270 A = strlen $0
271 IF A <> 12 THEN 277
272 $1 = $0
273 $4 = "1"
274 A = inquiry 10
275 ALARM 20
276 RETURN

277 PRINTS"ERROR"
278 GOTO 255

279 PRINTS"I'll try to pair to
280 PRINTS"anyone
281 $4 = "2"
289 GOTO 274

290 $4 = "0
291 GOTO 274

300 RESERVED
@INQUIRY 301
301 $300 = $0;
302 GOSUB 150;
303 C = strlen$(U+A);
304 IF C = 19 THEN 310;
305 $0[12] = 0;
306 PRINTV" 000 00";
307 $(U+A) = $0;
308 PRINTS $0
309 PRINTS" ROUTED\n\r"
310 IF $4[0] = 49 THEN 313;
311 IF $4[0] = 50 THEN 319;
312 RETURN

313 $0[0] = 0;
314 PRINTV"KNOW ";
315 PRINTV$1;
316 A = message $300;
317 ALARM 60;
318 RETURN

319 $0[0] = 0;
320 A = getaddr $3;
321 PRINTV"LIST ";
322 PRINTV$3
323 GOTO 316

0 REM message format:
0 REM <REQUESTER> <COMMAND> <TARGET>
0 REM where COMMANDS are:
0 REM KNOW
0 REM YES
0 REM NO
0 REM LIST
0 REM ITEM
0 REM NEXT
327 REQUESTER
328 COMMAND TARGET
329 RESERVED
@MESSAGE 330
330 $327 = $0;
331 $328 = $0[13];
332 $0 = $328;
333 $329 = "KNOW ";
334 A = strcmp $329;
335 IF A = 0 THEN 360;
336 $329 = "YES ";
337 A = strcmp $329;
338 IF A = 0 THEN 390;
339 $329 = "NO "
340 A = strcmp $329
341 IF A = 0 THEN 342
342 RETURN
0 REM 412 $329 = "LIST "
0 REM 413 A = strcmp $329
0 REM 414 IF A = 0 THEN
0 REM 415 $329 = "ITEM "
0 REM 416 A = strcmp $329
0 REM 417 IF A = 0 THEN
0 REM 418 $329 = "NEXT "
0 REM 419 A = strcmp $329
0 REM 420 IF A = 0 THEN
0 REM 421 RETURN

0 REM KNOW
360 $0 = $328[5];
361 GOSUB 150;
362 C = strlen $(U + A);
363 IF C <> 19 THEN 380;

0 REM YES
370 $0[0] = 0;
371 PRINTV"YES ";
372 PRINTV $(U+A);
373 $0[17] = 0;
374 PRINTV $(U+A)[18];
375 PRINTV $(U+A)[19];
376 A = message $327
377 RETURN

0 REM NO
380 $0[0] = 0;
381 PRINTV"NO "
382 GOTO 372

390 $1 = $0[4]
391 $0 = $327
392 GOSUB 150
393 $0[0] = 0
394 PRINTV $1
395 $0[13] = 0
0 REM we complete with spaces and zeros
396 IF A > 100 THEN 400
397 PRINTV "0"
398 IF A > 10 THEN 400
399 PRINTV "0"
400 PRINTV A
401 PRINTV " "
402 A = (atoi $328[17])
403 A = A+1
404 IF A > 10 THEN 406
405 PRINTV "0"
406 PRINTV A
407 $3 = $0
408 $0 = $1
409 GOSUB 150
410 $(U+A) = $3
411 PRINTS $(U+A)
412 PRINTS " ROUTED
413 ALARM 1
414 RETURN

