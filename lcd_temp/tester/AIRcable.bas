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
84 RETURN

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
153 IF A > 180 THEN 220
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
168 A = pioclr 10
169 A = pioclr 9
170 A = pioclr 20
171 A = pioin 10
172 A = pioclr 11

0 REM test lcd segments
180 $0=$10
181 PRINTV $11
182 PRINTV"                        "
183 C = strlen $0
184 WAIT 1
185 FOR B = 0 TO C-8
186 A = lcd $0[B]
187 NEXT B
188 A = lcd "                            "

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

@PIO_IRQ 249
249 A = lcd $0
250 IF $0[2] = 48 THEN 260
251 IF $0[3] = 48 THEN 265
252 IF $0[12] = 49 THEN 270
253 IF W = 1 THEN 285
254 RETURN

260 A = lcd "RIGHT     ";
261 GOTO 280

265 A = lcd"LEFT       ";
266 ALARM 3
267 GOTO 280

270 A = lcd"MIDDLE    "
271 WAIT 1
272 W = 1
273 GOTO 280

280 A = zerocnt
281 ALARM 3
282 RETURN

285 W = 0
286 X = 0
287 ALARM 1
288 RETURN

360 GOSUB 410
361 IF $7[0] = 73 THEN 380
362 IF Y <= -32000 THEN 370
363 $0="K "
364 Y = Y + 540
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

437 A = lcd"ADC ERR"
438 Y = -32000
439 RETURN

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
502 $0="BATT"
503 PRINTV A
504 A = lcd $0
505 X = 1
506 ALARM 5
507 A = pioirq"P011000000001"
508 A = zerocnt
509 RETURN

@SLAVE 600
600 A = shell
601 RETURN



