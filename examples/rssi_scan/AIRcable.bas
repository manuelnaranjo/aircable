@ERASE

1 P000000000001
2 AIRscanner

@INIT 50
0 REM debugging information will be dumped to LCD
50 Z = 4
51 A = auxdac 210
52 J = 20
53 A = pioset J
54 X = 0
55 A = defpower 0
0 REM K is kind of scan
0 REM K = 0 no scan
0 REM K = 1 rssi
0 REM K = 2 name scan
56 K = 0
57 $0="AIRscanner "
58 A = getuniq $2
59 PRINTV $2
60 A = name $0
61 A = pioclr 12
62 A = pioin 12
63 A = pioirq $1
64 W = 0
65 RETURN

@IDLE 100
100 X = 0
101 A = slave 500
102 A = pioset J
103 A = pioclr J
104 ALARM 1
0 REM 105 Z = 4
106 RETURN

@SLAVE 150
150 ALARM 0
0 REM 151 Z = 2
152 X = 1
153 A = pioset J;
154 PRINTS"Welcome, press r to "
155 PRINTS"start RSSI scan\r\n"
156 GOTO 200;

@ALARM 160
160 IF W = 1 THEN 420;
161 W = 0;
162 B = status;
163 IF B >= 10000 THEN 168;
164 IF X = 1 THEN 180
165 A = slave 500
166 A = pioset J
167 A = pioclr J
168 ALARM 10
169 RETURN

180 IF B = 0 THEN 260;
181 IF K = 1 THEN 310;
182 GOTO 200;

0 REM read blocks until there's
0 REM either an input or
0 REM the connection was lost
200 PRINTS"COMMAND > ";
201 INPUTS $0;
203 A = status;
204 IF A = 0 THEN 260;
205 A = strlen $0;
206 IF A > 0 THEN 211;
207 GOTO 200

0 REM this is the command dispatcher
0 REM help
0 REM 210 IF $0[0] = 104 THEN 250;
0 REM inq
211 IF $0[0] = 105 THEN 270;
0 REM rssi
212 IF $0[0] = 114 THEN 280;
0 REM close connection
213 IF $0[0] = 99 THEN 260;
214 PRINTS"Invalid Command\r\n
215 GOTO 200

0 REM This is the help command
0 REM h help
0 REM i scan
0 REM r rssi scan
0 REM c close connection
250 PRINTS"h help\r\n"
251 PRINTS"i scan\r\n"
252 PRINTS"r rssi scan\r\n"
253 PRINTS"c exit\r\n"
254 GOTO 200

260 PRINTS"Bye Bye\r\n"
261 A = disconnect 0
262 A = slave 1
264 A = pioclr J
264 RETURN

270 PRINTS"Name Scan\r\n
271 K = 2;
272 X = 1;
273 ALARM 15
274 A = inquiry 9;
275 RETURN

280 PRINTS"RSSI scan\r\n
281 T = atoi $0[1];
282 R = 0;
283 K = 1;
284 GOTO 315

@INQUIRY 300
300 PRINTS $0;
0 REM 301 PRINTS" "
0 REM 302 PRINTS A
301 PRINTS"\r\n";
302 IF K = 2 THEN 330;
0 REM RSSI scan
303 B = status;
304 IF B < 10000 THEN 310;
305 ALARM 2
306 RETURN;

310 T = T - 1;
311 IF T <= 0 THEN 320;
315 A = inquiry -24;
316 ALARM 30
317 RETURN

0 REM end of RSSI scan
320 ALARM 2
321 K = 0
322 RETURN

0 REM name scan
0 REM 330 PRINTS A
330 IF A < 0 THEN 340;
332 T = T - 1;
333 IF T <= 0 THEN 345;
0 REM not really needed but
0 REM just in case
334 ALARM 10
335 RETURN

340 T = A;
341 GOTO 332;

0 REM end of named scan
345 ALARM 2
346 RETURN

@PIO_IRQ 400
400 IF $0[12] = 49 THEN 410;
401 RETURN

410 W = 1
411 ALARM 3
412 RETURN

0 REM long button press 
0 REM turn off
420 A = pioget 12
421 IF A = 0 THEN 161;
422 ALARM 0;
423 A = lcd "Bye Bye   "
424 A = pioset 20;
425 A = pioclr 20;
426 A = pioget 12;
427 IF A = 1 THEN 424;
428 A = reboot
429 FOR A = 0 TO 10
430 WAIT 1
431 NEXT E
432 RETURN
