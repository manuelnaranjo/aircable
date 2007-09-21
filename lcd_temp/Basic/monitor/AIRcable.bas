@ERASE

0 REM $1 welcome message
0 REM $2 is for button state
0 REM $3 is for peer BT address
0 REM $4 messages rate, default 0
0 REM $5 used for ice water compensation
0 REM $6 used for LCD contrast storage
0 REM $7 used for type of sensor
0 REM $8 last showed message
0 REM $9 0 for ºF, 1 for ºC

0 REM $10 - $14 types of sensor
0 REM $20 min value to compare
0 REM $21 max value to compare


1 
2 
3 
4 0
5 540.
6
7 K
8 XXXºF
9 0

10 K
11 IR
12 RESERVED
13 RESERVED
14 RESERVED

20 RESERVED
21 RESERVED

@INIT 50
50 A = disable 2
0 REM LED output and on
51 A = pioout 9
52 A = pioset 9

0 REM LCD contrast between 100 and 200
53 L = atoi $6
54 IF L > 200 THEN 57
55 IF L = 0 THEN 57
56 GOTO 61
57 L = 160
58 $0[0] = 0
59 PRINTV L
60 $6 = $0
0 REM LCD bias
61 A = auxdac L

0 REM show welcome message
62 $0[0] = 0
63 $1="SMART Tempurature Device"

65 A = lcd $1
66 C = strlen$1
67 FOR B = 0 TO C - 8
68 A = lcd $1[B]
69 NEXT B

0 REM debug
70 Z = 0
0 REM 71 A = baud 1152
71 A = uartoff

72 A = name "AIRautomatic"

0 REM initialize buttons 
0 REM PIO2 right, PIO3 left, PIO12 middle
0 REM PIO12 goes high when pressed, add 
73 A = pioin 12
74 A = pioclr 12
0 REM right button
75 A = pioin 2
76 A = pioset 2
77 A = pioin 3
78 A = pioset 3

0 REM schedule interrupts
79 A = pioirq "P011000000001"

0 REM display type
80 $0="TYPE "
81 PRINTV $7
82 A = lcd $0
83 WAIT 3

0 REM button state variable
84 W = 0

85 A = zerocnt

0 REM ice water compensation
86 X = atoi $5[0]
87 IF X > 700 THEN 90
88 IF X = 0 THEN 90
89 GOTO 94
90 X = 460
91 $0[0] = 0
92 PRINTV X
93 $5 = $0

0 REM reading rate restore
94 P = atoi $4
95 IF P > 90 THEN 98
96 IF P = 0 THEN 98
97 GOTO 102
98 P = 0
99 $0[0] = 0
100 PRINTV P
101 $4 = $0
0 REM turn R into minutes
102 P = P * 60

0 REM let's start up
103 Q = 0;
104 ALARM 5
0 REM mark we are booting
105 U = 1000
106 A = nextsns 10
107 RETURN


0 REM buttons and power
@PIO_IRQ 130
0 REM press button starts alarm for long press recognition
130 IF $0[2]=48 THEN 136;
131 IF $0[3]=48 THEN 136;
132 IF $0[12]=49 THEN 136;
0 REM was it a release, handle it
133 IF W <> 0 THEN 260;
134 RETURN

0 REM button press, save state, start ALARM
136 $2 = $0;
137 W = 1;
138 ALARM 3
139 RETURN



@ALARM 150
0 REM check if we just booted, show temp and message
150 IF U = 1000 THEN 160
0 REM contrast timeout, back to preset value.
151 IF U = 8 THEN 506


0 REM display temp handler -----
0 REM check status, if connected trigger
0 REM alarm 10 seconds forward
152 C = status
153 IF C = 0 THEN 160
0 REM in interactive mode check very 10 seconds
154 ALARM 10
155 RETURN

160 U = 0;
0 REM blink
161 A = pioset 20;
162 A = pioclr 20
0 REM long press button recognition
163 IF W = 1 THEN 220

0 REM update temp then display
164 GOSUB 400
0 REM are we in messaging mode
165 IF P > 0 THEN 170
0 REM not messaging mode, only show temp, allow deep sleep
166 ALARM 60
167 A = uartoff
168 RETURN

0 REM we just booted?
170 IF U = 1000 THEN 173
0 REM check timer then
171 A = readcnt
172 IF P > A THEN 166

0 REM get a reading, put it on LCD
173 U = 0
174 A = zerocnt
175 WAIT 2
0 REM are we paired?
176 A = strlen $3
177 IF A < 12 THEN 166

0 REM message handler ------
0 REM prepare OBEX message
180 GOSUB 450
181 $0[0]=0
182 PRINTV"$"
183 PRINTV A
184 PRINTV ":"
185 PRINTV Y
186 PRINTV"!"
187 PRINTV X
188 PRINTV"#"
189 PRINTV $7

190 A = message $3
191 A = zerocnt
192 A = lcd " MESSAGE"
193 WAIT 2

0 REM check message transmission
194 C = status
195 IF C < 1000 THEN 200
196 WAIT 2
197 GOTO 194

200 A = success
201 IF A > 0 THEN 204
202 A = lcd " FAILED "
203 GOTO 205
 

0 REM ---------------------------
204 A = lcd "   OK   "
205 WAIT 5
0 REM show last temp again, until the processor
0 REM falls to sleep
206 A = lcd $8
0 REM next reading in P seconds
207 GOTO 166



0 REM button handlers -----------------

0 REM long button press
220 A = pioget 12
221 B = pioget 2
222 C = pioget 3
0 REM M = power off
0 REM M + R = visible
0 REM R + L = debug panel
223 IF B = 0 THEN 245
224 IF A = 1 THEN 230
0 REM ignore other long presses
225 W = 0
226 ALARM 1
227 RETURN

0 REM long button press
230 A = lcd "GOOD BYE"
231 ALARM 0;
232 A = pioget 12;
233 IF A = 1 THEN 232;
234 A = lcd;
235 A = reboot;
236 FOR E = 0 TO 10
237   WAIT 1
238 NEXT E
239 RETURN

0 REM combinations handler
245 IF A = 1 THEN 250
246 IF C = 0 THEN 255
247 GOTO 225

0 REM discoverable for 2 minutes
250 A = slave 120
251 GOTO 225

255 A = lcd"DEBUG     "
0 REM implement this
256 GOTO 225

0 REM short press handler
0 REM right, middle, left
260 W = 0
261 IF $2[2] = 48 THEN 270;
262 IF $2[3] = 48 THEN 280;
263 IF $2[12] = 49 THEN 290;
264 RETURN

0 REM send current temp
270 GOSUB 400
271 GOTO 176

0 REM show current temp
280 GOSUB 400
281 RETURN

0 REM show batteries level
290 U = 100
291 A = nextsns 1
292 RETURN

@SENSOR 300
300 A = sensor $0
301 IF U = 100 THEN 310
0 REM meassure again in 30 minutes
302 A = nextsns 1800
303 RETURN


310 A = lcd $0
311 GOTO 302 

0 REM display temp handler ------
400 GOSUB 450
401 IF $7[0] = 73 THEN 420
402 $0="T "
403 Y = Y + X
404 Y = Y / 20

0 REM show in ºF or ºC?
405 IF $9[0]=49 THEN 412
0 REM convert to ºF
406 Y = Y * 9
407 Y = Y / 5
408 Y = Y + 32
409 PRINTV Y
410 PRINTV" %F         "
411 GOTO 415

0 REM display ºC
412 PRINTV Y
413 PRINTV" %C         "


0 REM save temp string. then display
415 $8 = $0
416 A = lcd $8
417 RETURN

0 REM IR sensor
420 $0 ="IR. "
421 IF Y  <= -32000 THEN 445
0 REM ºF or ºC?
422 IF $9[0]=49 THEN 435
423 Y = Y * 9
424 Y = Y / 5
425 Y = Y + 320
426 C = Y / 10
427 PRINTV C
428 PRINTV"."
429 D = C * 10
430 D = Y-D
431 PRINTV D
432 A = pioset 1
433 GOTO 410

435 C = Y / 10
436 PRINTV C
437 PRINTV"."
438 D = C * 10
439 D = Y-D
440 PRINTV D
441 A = pioset 1
442 GOTO 412

445 $0="ERR READ"
446 A = lcd $0
447 RETURN

0 REM I2C sensor reading handler
450 IF $7[0] = 75 THEN 460
451 IF $7[0] = 73 THEN 480
452 Y = 0
453 RETURN

0 REM K sensor connected to MCP3421
460 A=ring
461 R = 0;
462 T = 1;
0 REM slave address is 0xD0
463 $1[0] = 208;
464 $1[1] = 143;
465 A = i2c $1;
466 $0[0] = 0;
467 $0[1] = 0;
468 $0[2] = 0;
469 $0[3] = 0;

470 $1[0] = 208;
471 T = 0;
472 R = 4;
473 A = i2c $1;
474 Y = $0[1] * 256;
475 Y = Y + $0[2];
476 RETURN

0 REM read IR Temp module
480 A = ring
481 A = pioout 1
482 A = pioclr 1
0 REM temp is in Kelvin
0 REM substract 273.15 to get Celsius
0 REM temp / 0.02 is K
0 REM F = address: 6 is ambient, 7 object
483 F = 7
0 REM E is repeat limit
484 E = 0;
485 $0[0] = 0;
486 $0[1] = 0;
487 $0[2] = 0;
488 R = 3;
489 T = 1;
0 REM slave address 0x5A
490 $1[0] = 180;
0 REM command read RAM addr 0x06
491 $1[1] = F;
492 A = i2c $1;
493 E = E + 1;
0 REM read until good reading
494 IF E > 10 THEN 507;
495 IF A <> 6 THEN 485;
496 IF $0[2] = 255 THEN 485;
497 IF $0[2] = 0 THEN 485;

0 REM calculate temp, limit 380 C
498 B = $0[1];
499 IF B > 127 THEN 507;
500 B = B * 256;
501 B = B + $0[0];
502 B = B - 13658;
503 B = B / 5;

504 Y = B
505 A = pioset 1
506 RETURN

0 REM failed reading
507 A = pioset 1
508 Y = -32000
509 RETURN



0 REM do we need this at all???
@CONTROL 910
0 REM remote request for DTR, disconnect
910 IF $0[0] = 49 THEN 912;
911 REM A = disconnect 1
912 RETURN 

@SLAVE 950
0 REM LED on
950 ALARM 0
951 Q = 0
952 A = pioset 20
953 A = shell
954 RETURN


0 REM slave for 60 seconds after boot
0 REM then stop FTP too
@IDLE 981
981 A = pioclr 9
982 A = pioset 9
983 REM IF Q = 1 THEN 992
984 REM IF Q = 2 THEN 996
985 A = slave 30
986 Q = 1
0 REM startup the automatic again
987 IF U = 2 THEN 991
988 U = 0
989 W = 0
990 ALARM 2
991 RETURN

0 REM after some time disable FTP
992 A = disable 3
993 WAIT 3
994 A = slave -1
995 Q = 2
996 RETURN


