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
11 0123456789.,

@INIT 50
50 A = uarton
51 A = baud 1152
52 Z = 0

0 REM turn on green led
54 A = pioout 9
55 A = pioset 9

0 REM test contrast
56 A = auxdac 200
57 A = lcd "LCD TEST    "

0 REM state variable X
0 REM X = 0 testing beep, leds, lcd
0 REM X = 1 testing K
0 REM X = 2 testing IR
0 REM X = 3 testing battery
0 REM X = 4 turn off
0 REM semaphore Y
0 REM Y = 0 running
0 REM Y = 1 stopped
58 Y = 0;
59 X = 0;

62 A = auxdac 200
63 A = getuniq $1
64 $0="LCD "
65 PRINTV $1
66 A = name $1

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
80 ALARM 1
81 RETURN

@IDLE 100
100 A = slave 1200
101 GOTO 150

@ALARM 150
150 IF Y = 1 THEN 200
151 IF X = 0 THEN 170
152 IF X = 1 THEN 190
153 IF X = 2 THEN 160
154 IF X = 3 THEN 210
155 IF X = 4 THEN 220
156 X = 0
157 ALARM 1
158 RETURN

160 $7="IR"
161 GOSUB 360
162 A = beep
163 X = 0
164 GOTO 151

0 REM test buzzer and leds
170 0 REM A = pioirq"P0000000000000"
171 A = lcd "TESTING    "
172 A = beep
173 A = pioset 9
174 A = pioset 20
175 A = pioclr 9
176 A = pioclr 20

0 REM test lcd segments
178 $0=$10
179 PRINTV $11
180 PRINTV"                        "
181 C = strlen $0
182 WAIT 1
183 FOR B = 0 TO C-8
184 A = lcd $0[B]
185 NEXT B
186 0 REM A = pioirq"P011000000001"
187 X = 1
188 GOTO 150

190 $7="K"
191 GOSUB 360
192 A = beep
193 X = 2
194 GOTO 151
 
200 Y = 0
201 ALARM 1
202 RETURN

210 A = nextsns 1
211 Y = 1
212 RETURN

220 A = pioget 12
221 IF A = 0 THEN 240
222 A = lcd "BYE             "
223 A = pioget 12
224 IF A = 0 THEN 230
225 WAIT 1
226 GOTO 223

230 A = reboot
231 Y = 1
232 RETURN

240 X = 0
241 Y = 0
242 ALARM 1
243 RETURN

@PIO_IRQ 250
250 IF $0[2] = 48 THEN 260
251 IF $0[3] = 48 THEN 265
252 IF $0[12] = 49 THEN 270
253 X = 0
254 ALARM 0
255 RETURN

260 A = lcd "RIGHT     ";
261 WAIT 1
262 RETURN

265 A = lcd"LEFT       ";
266 WAIT 1
267 RETURN

270 A = lcd"MIDDLE    "
271 X = 4
272 ALARM 3
273 WAIT 1
274 RETURN


360 GOSUB 410
361 IF $7[0] = 73 THEN 380
362 $0="K "
363 Y = Y + X
364 Y = Y / 20

0 REM display ºC
365 PRINTV Y
366 PRINTV"%C         "


0 REM save temp string. then display
367 $8 = $0
368 A = lcd $8
369 RETURN

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
410 IF $7[0] = 75 THEN 420
411 IF $7[0] = 73 THEN 440
412 Y = 0
413 RETURN

0 REM K sensor connected to MCP3421

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
433 IF $0[3] >= 128 THEN 437
434 Y = $0[1] * 256;
435 Y = Y + $0[2];
436 RETURN

437 A = lcd"NOT READY"
438 WAIT 1
439 GOTO 425

0 REM laser on
440 A = pioclr 4
0 REM read IR Temp module
441 A = pioout 1
0 REM 481 A = ring
0 REM 442 A = pioclr 1
0 REM temp is in Kelvin
0 REM substract 273.15 to get Celsius
0 REM temp / 0.02 is K
0 REM F = address: 6 is ambient, 7 object
443 F = 7
0 REM E is repeat limit
444 E = 0;
445 $0[0] = 0;
446 $0[1] = 0;
447 $0[2] = 0;
448 R = 3;
449 T = 1;
0 REM slave address 0x5A
450 $1[0] = 180;
0 REM command read RAM addr 0x06
451 $1[1] = F;
452 A = i2c $1;
453 E = E + 1;
0 REM read until good reading
454 IF E > 10 THEN 468;
455 IF A <> 6 THEN 445;
456 IF $0[2] = 255 THEN 445;
457 IF $0[2] = 0 THEN 445;

0 REM calculate temp, limit 380 C
458 B = $0[1];
459 IF B > 127 THEN 468;
460 B = B * 256;
461 B = B + $0[0];
462 B = B - 13658;
463 B = B / 5;

464 Y = B
0 REM 465 A = pioset 1
0 REM laser off
466 A = pioset 4
467 RETURN

0 REM failed reading
468 
0 REM 468 A = pioset 1
0 REM laser off
469 A = pioset 4
470 Y = -32000
471 RETURN


@SENSOR 500
500 A = sensor $0
501 A = atoi $0
502 $0="BATT "
503 A = PRINTV A
504 A = lcd $0
505 X = 0
506 Y = 0
507 ALARM 1
508 RETURN

