@ERASE

0 REM ERROR TABLE:
0 REM 1: Not Paired
0 REM 2: Target not respoding
0 REM 

0 REM Line $1 stores the slave peer address.
1 

0 REM $2 stores the Name filter
2 AIRcableRelay

0 REM $3 used for generating pioirq string
3 P0000000000000

0 REM $4 used on @PIO_IRQ
4 RESERVED

0 REM $5 PIN CODE
5 1234

0 REM $6 Name
6 AIRelay

0 REM $7 uniq
7 RESERVED


0 REM E is the state variable
0 REM E = 0 means slave disconnected
0 REM E = 1 slave connected - master connecting
0 REM E = 2 slave connected - master connected
0 REM E = 3 scanning

0 REM W is the button state variable

0 REM J is the first LED  (blue)
0 REM K is the second LED
0 REM U is the button PIO

0 REM @INIT, system initialization
@INIT 50
0 REM mark we're booting
50 T = 1000
51 Z = 0
52 E = 0
53 J = 20
54 K = 0
55 U = 12

0 REM init UART
0 REM RS232 POWER ON out and on
56 A = pioout 3
57 A = pioset 3
0 REM RS232 POWER OFF out and on
58 A = pioout 10
59 A = pioset 10
0 REM RS232 DTR pin out and on
60 A = pioset 5
61 A = pioout 5

62 A = baud 1152

0 REM you can add any extra init here

0 REM don't touch from now on
70 $3[U] = 49

71 A = pioout J
72 A = pioclr J
73 A = pioclr U
74 A = pioin U
75 A = pioout K
76 A = pioset K
77 A = pioset J;
78 A = pioclr J
79 A = pioirq $3

80 W = 0
81 A = uartint

0 REM set name
82 A = getuniq $7
83 $0=$6
84 PRINTV " "
85 PRINTV $7
86 A = name $0

0 REM let's be nice and disable
0 REM all the profiles
87 A = disable 3

88 A = pioget U
89 IF A = 1 THEN 310

0 REM check if all ready paired
90 A = strlen $1
91 IF A < 11 THEN 310

92 RETURN

@SLAVE 99
99 PRINTU"@SLAVE\n\r"
100 A = strlen $1
101 IF A < 12 THEN 110
102 E = 1
103 ALARM 1
104 RETURN

110 PRINTU"NOT PAIRED\n\r"
111 PRINTU"ERR:1\n\r"
112 A = disconnect 0
113 E = 0
114 ALARM 1
115 RETURN


@MASTER 158
158 IF T >= 100 THEN 165
159 PRINTU"@MASTER\n\r"
160 A = link 3
161 E = 2
162 ALARM 10
163 A = pioset J
164 RETURN

165 T = 0
166 E = 0
167 A = disconnect 1
168 ALARM 3
169 RETURN

@IDLE 178
178 IF T = 100 THEN 186
179 PRINTU"@IDLE\n\r"
180 A = slave 200
181 ALARM 3
182 A = status
183 IF A < 2 THEN 185
184 A = disconnect 1
185 E = 0
186 RETURN

@ALARM 199
199 PRINTU"@ALARM\n\r"
200 IF W = 1 THEN 340
201 IF T = 100 THEN 207
202 T = 0
203 IF E = 0 THEN 210
204 IF E = 1 THEN 220
205 IF E = 2 THEN 250
206 IF E = 3 THEN 280
207 RETURN

210 A = pioset J;
211 A = pioclr J
212 A = slave 20
213 PRINTU"A = slave\n\r
214 ALARM 10
215 RETURN

220 A = pioset J;
221 A = pioclr J
222 A = status
223 IF A > 1 THEN 228
224 PRINTU"A = master "
225 PRINTU  $1
226 PRINTU"\n\r
227 A = master $1
228 ALARM 20
229 RETURN

250 A = status
251 IF A < 10000 THEN 253
252 A = A - 10000
253 IF A < 1000 THEN 255
254 A = A - 1000
255 IF A < 100 THEN 257
256 A = A - 100
257 IF A <> 11 THEN 270
258 ALARM 10
259 RETURN

270 A = disconnect 0
271 A = disconnect 1
272 E = 0
273 ALARM 1
274 RETURN

0 REM inquiry timeout, we are not paired
0 REM we need to scan again
280 GOTO 317


@PIO_IRQ 299
299 PRINTU"@PIO_IRQ\n\r"
300 IF $0[U]=49 THEN 330;
301 W = 0
302 RETURN

310 T = 100
311 ALARM 0
312 W = 0
313 $4=""
314 $1=""
315 E = 3
316 A = inquiry 18
317 PRINTU "SCANNING\n\r"
318 FOR B = 0 TO 2
319 A = pioset J;
320 A = pioclr J
321 NEXT B
322 ALARM 30
323 RETURN

330 W = 1
331 ALARM 3
332 RETURN

340 ALARM 0
341 A = pioset J;
342 A = pioclr J
343 A = pioget U;
344 IF A = 1 THEN 341
345 A = reboot
346 FOR B = 0 TO 10
347 WAIT 1
348 NEXT B
349 RETURN


@INQUIRY 349
349 IF T = 101 THEN 358
350 PRINTU"Found: 
351 PRINTU $0
352 PRINTU"\n\r"
353 $349=$0
354 $0=$0[13]                              
355 A = strcmp $2
356 IF A = 0 THEN 360
357 PRINTU"NO MATCH\n\r"
358 RETURN

360 ALARM 0
361 A = cancel
362 PRINTU"MATCH\n\r"
363 $1=$349
364 E = 0
366 A = unlink $1
367 FOR B = 0 TO 3
368 A = pioset J;
369 A = pioclr J
370 NEXT B
371 A = master $1
372 ALARM 20
373 T = 101
374 RETURN

@UART 400
400 INPUTU $0
401 A = strlen $0
402 IF $0[A-1] <> 43 THEN 404
403 IF $0[A-3] = 43 THEN 410
404 A = uartint
405 RETURN

410 A = status
411 PRINTU"\n\rStatus: "
412 PRINTU A
413 PRINTU"\n\rName Filter: "
414 PRINTU $2
415 PRINTU"\n\rRelay Pair: "
416 PRINTU $1
417 PRINTU"\n\rn: name filter 
418 PRINTU"\n\ru: unpair
419 PRINTU"\n\re: exit\n\r> "
420 INPUTU $0
421 IF $0[0] = 110 THEN 430
422 IF $0[0] = 117 THEN 440
423 IF $0[0] = 101 THEN 450
424 GOTO 410

0 REM set name filter
430 PRINTU"\n\rNew Filter: 
431 INPUTU $2
432 GOTO 410

0 REM unpair
440 PRINTU"\n\rUnpairing"
441 $1=""
442 GOTO 410

0 REM exit command line
450 PRINTU"\n\rBye"
451 A=uartint
452 T = 0
454 E = 0
455 ALARM 1
456 RETURN

@PIN_CODE 500
500 PRINTU"@PIN_CODE\n\r"
501 $0=$5;
502 RETURN
