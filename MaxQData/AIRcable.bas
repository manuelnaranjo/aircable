@ERASE

@INIT 9
9 Z = 0
0 REM green LED output and on
10 A = pioout 9
11 A = pioset 9
0 REM blue LED output and off
12 A = pioout 10
13 A = pioclr 10

0 REM RS232 POWER ON out and on
14 A = pioout 3
15 A = pioset 3

0 REM RS232 POWER OFF out and on
16 A = pioout 11
17 A = pioset 11

0 REM set uart to 115200
19 A = baud 1152

20 A = zerocnt
21 $0="MaxQData "
22 A = getuniq $2
23 PRINTV $2
24 A = name $0
25 G = 1
26 WAIT 3
27 A = slave 1
28 RETURN

@SLAVE 40
0 REM blue LED on
40 B = pioset 10
0 REM connect RS232
41 C = link 1
42 RETURN

0 REM IDLE only calls to slave
0 REM leds are handled by the alarm
@IDLE 50
50 ALARM 1
51 RETURN

@ALARM 190
190 A = status;
191 IF A = 0 THEN 200
192 GOTO 203

0 REM blink blue LED
200 A = pioset 10
201 A = pioclr 10
202 A = slave 15
203 IF G = 1 THEN 210
204 ALARM 8
205 RETURN

210 A = readcnt
211 IF A < 120 THEN 204
212 A = disable 3
213 G = 0
214 GOTO 204

229 0000
@PIN_CODE 230
230 $0=$229;
231 RETURN
