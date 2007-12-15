@ERASE
0 REM this piece of code will test the lcds boards
0 REM functionallity. It's intendeed for in-lab 
0 REM usage, but might be used in production
0 REM enviroments

0 REM PIO LIST:
0 REM 1 IR OFF
0 REM 2 RIGHT BUTTON
0 REM 3 LEFT BUTTON
0 REM 4 LASER
0 REM 9 GREEN LED
0 REM 12 MIDDLE BUTTON
0 REM 20 BLUE LED

10 ABCDEFGHIJKLMNOPQRSTUVWXYZ
11 0123456789

@INIT 50
50 A = uarton
51 A = baud 1152
52 Z = 0

0 REM turn on green led
54 A = pioout 9
55 A = pioclr 9

0 REM test contrast
56 A = auxdac 200
57 A = lcd "LCD TEST    "

0 REM state variable X
0 REM X = 0 testing
0 REM X = 1 ready
0 REM W middle button state
0 REM W = 1 middle has been pressed
59 X = 0;
60 W = 0;

62 A = auxdac 200
63 A = getuniq $1
64 $0="LCD "
65 PRINTV $1
66 A = name $0

0 REM initialize buttons 
0 REM PIO2 right, PIO3 left, PIO12 middle
0 REM PIO12 goes high when pressed, add 
67 A = pioin 12
68 A = pioclr 12
0 REM right button
69 A = pioin 2
70 A = pioset 2
0 REM left button
71 A = pioin 3
72 A = pioset 3

0 REM IR sensor
73 A = pioout 1
74 A = pioclr 1

0 REM schedule interrupts.
75 A = pioirq "P011000000001"
76 A = lcd "READY    "

77 A = pioout 20
78 A = pioclr 20
79 A = slave 1200
80 A = pioin 10

0 REM prepare back light
81 A = pioout 11
82 A = pioclr 11

0 REM start counter
83 A = zerocnt

0 REM enable laser
84 A = pioout 4
85 A = pioset 4
86 RETURN

@IDLE 100
100 A = slave 1200
101 X = 0
102 W = 0
103 GOTO 150

@ALARM 149
149 IF W = 1 THEN 220
150 IF X = 0 THEN 160
151 A = lcd"READY       "
152 A = readcnt
153 IF A > 30 THEN 230
154 ALARM 10
155 RETURN

0 REM test buzzer and leds
160 WAIT 1
161 A = pioirq"P0000000000000"
162 A = lcd "TESTING    "
163 A = ring
164 A = pioset 9
165 A = pioset 20
166 A = pioout 10
167 A = pioset 11
168 A = pioclr 4
169 A = pioclr 10
170 A = pioclr 9
171 A = pioclr 20
172 A = pioin 10
173 A = pioclr 11
174 A = pioset 4

0 REM test lcd segments
180 $0=$10
181 PRINTV $11
182 PRINTV"                        "
183 C = strlen $0
184 WAIT 1
185 FOR B = 0 TO C-8
186 A = lcd $0[B];
187 NEXT B;
188 A = lcd "                            "

189 WAIT 1
190 $7="K"
191 GOSUB 360
192 A = ring

193 $7="IR"
194 GOSUB 360
195 A = ring
196 A = nextsns 1
197 RETURN
 
200 Y = 0
201 ALARM 1
202 RETURN

210 A = nextsns 1
211 W = 1
212 RETURN

220 A = pioget 12
221 IF A = 0 THEN 240
222 A = lcd "BYE             "
223 A = pioget 12
224 IF A = 1 THEN 230
225 WAIT 1
226 GOTO 223

230 A = reboot
231 W = 0
232 RETURN

240 X = 0
241 W = 0
242 ALARM 1
243 RETURN

@PIO_IRQ 250
250 IF $0[2] = 48 THEN 260
251 IF $0[3] = 48 THEN 265
252 IF $0[12] = 49 THEN 270
253 IF W = 1 THEN 285
254 RETURN

260 A = lcd "RIGHT     ";
261 GOTO 280

265 A = lcd"LEFT       ";
266 GOTO 280

270 A = lcd"MIDDLE    "
271 WAIT 1
272 W = 1
273 GOTO 280

280 A = zerocnt
281 ALARM 2
282 RETURN

285 W = 0
286 X = 0
287 ALARM 1
288 RETURN

360 GOSUB 410
361 IF $7[0] = 73 THEN 380
362 IF Y <= -32000 THEN 370
363 $0="K "
364 Y = Y + 420
365 Y = Y / 20

0 REM display ºC
366 PRINTV Y
367 PRINTV"%C         "


0 REM save temp string. then display
368 $8 = $0
369 A = lcd $8
370 RETURN

0 REM IR sensor
380 $0 ="IR. "
381 IF Y  <= -32000 THEN 405
382 C = Y / 10
383 PRINTV C
384 PRINTV"."
385 D = C * 10
386 D = Y-D
387 PRINTV D
0 REM 401 A = pioset 1
384 GOTO 367

405 $0="IR ERR     "
406 A = lcd $0
407 RETURN

0 REM I2C sensor reading handler
410 IF $7[0] = 75 THEN 419
411 IF $7[0] = 73 THEN 450
412 Y = 0
413 RETURN

0 REM K sensor connected to MCP3421

419 K = 0
0 REM tell the MCP4321 to take a reading
420 R = 0;
421 T = 1;
0 REM slave address is 0xD0
422 $1[0] = 208;
423 $1[1] = 143;
424 A = i2c $1;

0 REM read
425 $0[0] = 0;
426 $0[1] = 0;
427 $0[2] = 0;
428 $0[3] = 0;
429 $1[0] = 208;
430 T = 0;
431 R = 4;
432 A = i2c $1;
433 IF $0[3] >= 128 THEN 440
434 Y = $0[1] * 256;
435 Y = Y + $0[2];
436 RETURN

440 K = K + 1
441 IF K < 3 THEN 430


445 A = lcd"ADC ERR"
446 Y = -32000
447 RETURN

0 REM laser on
450 A = pioclr 4
0 REM read IR Temp module
451 A = pioout 1
0 REM 481 A = ring
0 REM 442 A = pioclr 1
0 REM temp is in Kelvin
0 REM substract 273.15 to get Celsius
0 REM temp / 0.02 is K
0 REM F = address: 6 is ambient, 7 object
452 F = 6
0 REM E is repeat limit
453 E = 0;
454 $0[0] = 0;
455 $0[1] = 0;
456 $0[2] = 0;
457 R = 3;
458 T = 1;
0 REM slave address 0x5A
459 $1[0] = 180;
0 REM command read RAM addr 0x06
460 $1[1] = F;
461 A = i2c $1;
462 E = E + 1;
0 REM read until good reading
463 IF E > 10 THEN 477;
464 IF A <> 6 THEN 454;
465 IF $0[2] = 255 THEN 454;
466 IF $0[2] = 0 THEN 454;

0 REM calculate temp, limit 380 C
467 B = $0[1];
468 IF B > 127 THEN 477;
469 B = B * 256;
470 B = B + $0[0];
471 B = B - 13658;
472 B = B / 5;

473 Y = B
0 REM 465 A = pioset 1
0 REM laser off
474 A = pioset 4
475 RETURN

0 REM failed reading
476 
0 REM 468 A = pioset 1
0 REM laser off
477 A = pioset 4
478 Y = -32000
479 RETURN


@SENSOR 500
500 A = sensor $0
501 A = atoi $0
502 A = A / 100
503 $0="BATT "
504 PRINTV A
505 PRINTV"                   "
506 A = lcd $0
507 X = 1
508 ALARM 5
509 A = pioirq"P011000000001"
510 A = zerocnt
511 RETURN

@SLAVE 600
600 A = shell
601 RETURN



