@ERASE

@INIT 9
9 Z = 1
10 J = 10
0 REM LED output and on
11 A = pioout J
12 A = pioset J

0 REM set baud rate to 115200
13 A = baud 1152

14 A = zerocnt

0 REM set name
15 $0="AIRcableSlave "
16 A = getuniq $2
17 PRINTV $2
18 A = name $0
19 G = 1
20 U = 1
21 WAIT 3
22 RETURN

@SLAVE 40
0 REM blue LED on
40 B = pioset J
0 REM connect RS232
41 C = link 1
42 WAIT 5
43 A = disconnect 0
44 RETURN

0 REM IDLE only calls to slave
0 REM leds are handled by the alarm
@IDLE 50
50 IF U = 1 THEN 52
51 A = slave 15
52 ALARM 1
53 U = 0
54 RETURN

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

