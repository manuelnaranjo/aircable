@ERASE

@INIT 10
10 A = lcd "AIRbot  "
11 A = auxdac 200

0 REM debug disabled
12 Z = 0

0 REM LED output and on
13 A = pioset 20
14 A = baud 384

0 REM init motor controller pio
15 A = pioout 1
16 A = pioset 1

0 REM enable middle button
17 A = pioclr 12
18 A = pioin 12

0 REM enable rigth button
19 A = pioset 3
20 A = pioin 3

21 A = pioset 4
22 A = pioin 4

23 A = pioirq"P001100000001"

25 A = name "AIRbot   "

0 REM enable serial port
27 A = pioout 5
28 A = pioclr 5

29 PRINTU"\x88\x7F\x8E\x7F"
30 WAIT 1
31 PRINTU"\x88\x00\x8C\x00"
32 WAIT 1
33 PRINTU"\x8A\x7F\x8C\x7F"
34 WAIT 1
35 PRINTU"\x88\x00\x8C\x00"

0 REM long button press detector
36 W = 0
37 RETURN

@IDLE 50
0 REM blink LED
50 IF W = 2 THEN 55;
51 A = pioset 20;
52 A = pioclr 20
0 REM slave for 5 seconds
53 A = slave 5
0 REM coast motors
54 PRINTU"\x86\x87"
55 RETURN

@SLAVE 100
0 REM LED on
101 B = pioset 20
0 REM connect RS232
102 C = link 1
103 RETURN

@PIO_IRQ 200
200 $199=$0;

0 REM check for button release
201 IF W = 1 THEN 210;
202 IF W = 2 THEN 240;
203 W = 1
204 ALARM 3
205 $198=$0
206 RETURN

0 REM short button press
210 ALARM 0;
211 W = 0;
212 IF $198[3] = 48 THEN 220;
213 IF $198[4] = 48 THEN 225;
214 IF $198[12] = 49 THEN 230;
215 WAIT 3
216 PRINTU"\x86\x87"
217 RETURN

0 REM short right, turn right
220 PRINTU"\x88\x7F\x8E\x7F"
221 GOTO 215

0 REM short left, turn left
225 PRINTU"\x8A\x7F\x8C\x7F"
226 GOTO 215

0 REM short middle, go front
230 PRINTU"\x88\x7F\x8C\x7F"
231 GOTO 215

0 REM wake from deep sleep
240 W = 0
241 GOSUB 10
242 A = enable 3
243 A = pioclr 20
244 A = slave 5
245 RETURN

@ALARM 250
250 IF W = 1 THEN 255;
251 IF W = 2 THEN 260;
252 RETURN

255 W = 0
256 IF $199[12]=49 THEN 270;
257 RETURN

0 REM blink blue just for fun
260 A = pioset 20;
261 A = pioclr 20
262 ALARM 10
263 RETURN

0 REM long middle turn off
270 A = lcd "GOOD BYE";
271 ALARM 0;
272 A = pioirq"P000000000000"
273 A = pioclr 1;
274 A = pioset20
275 A = pioclr20;
276 A = pioget12;
277 IF A = 1 THEN 274;
278 A = pioclr20;
0 REM 268 A = lcd;
279 A = pioset 5;
280 A = pioirq"P000000000001"
0 REM deep sleep mode
281 W = 2
282 A = disable 3
283 ALARM 10
284 RETURN
