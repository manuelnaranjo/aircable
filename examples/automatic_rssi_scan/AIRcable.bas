@ERASE

0 REM simple rssi scanner code, when ever you open up a slave
0 REM connection to this code it will start inquiring with rssi
0 REM resolving, until you disconnect again.

1 P00000000000000001
2 AIRscanner

@INIT 50
0 REM debugging information will be dumped to serial port
50 Z = 1
51 A = baud 1152
52 A = auxdac 210
53 J = 20
54 A = pioset J
55 X = 0
56 A = defpower 0
57 $0="AIRscanner2 "
58 A = getuniq $2
59 PRINTV $2
60 A = name $0
61 A = pioclr 17
62 A = pioin 17
62 A = pioirq $1
63 W = 0
0 REM enable serial port for IndXR5
0 REM RS232 POWER ON out and on, PIO12
64 A = pioout 13
65 A = pioset 13
0 REM RS232 POWER OFF out and on, PIO11
66 A = pioout 12
67 A = pioset 12
0 REM RS232 DTR pin out and on, PIO13
68 A = pioset 14
69 A = pioout 14
0 REM Sleep mode PIO10 (low no deep sleep) and Handshake PIO15 (high enabled)
70 A = pioout 11
71 A = pioclr 11
72 A = pioout 16
73 A = pioset 16
74 RETURN

@IDLE 100
0 REM do nothing just blink the led
0 REM and register alarm so we never get a slave timeout
100 X = 0
101 A = slave 500
102 A = pioset J
103 A = pioclr J
104 ALARM 1
0 REM 105 Z = 4
106 RETURN

@SLAVE 150
0 REM when we get connected we make the Blue LED go solid
0 REM and we go right into the @ALARM call to do our work
150 ALARM 0;
151 A = pioset J;
152 GOTO 160;


@ALARM 160
0 REM @ALARM is rather simple 
0 REM if long button release
0 REM    if connected -> disconnect
0 REM    else -> turn off
0 REM else if connected 
0 REM 	if not scanning -> scan
0 REM   else -> blink led twice
0 REM else -> register slave, blink led

0 REM long button press
160 IF W = 1 THEN 420;
161 W = 0;
162 B = status;
0 REM scanning?
163 IF B > 9999 THEN 175;
0 REM connected?
164 IF B > 0 THEN 180;

0 REM register slave blink led
165 A = slave 500
166 A = pioset J
167 A = pioclr J
168 ALARM 4
169 RETURN

175 A = pioset J
176 A = pioclr J
179 GOTO 166;

0 REM start new inquiry
180 A = inquiry -24;
181 PRINTS"Scanning\r\n"
182 ALARM 5
183 GOTO 175;


@INQUIRY 300
0 REM we got an inquiry result
0 REM just print it out
300 PRINTS $0;
301 PRINTS"\r\n";
303 B = status;
304 IF B < 10000 THEN 310;
305 ALARM 2
306 RETURN;

310 ALARM 1
311 RETURN

@PIO_IRQ 400
400 IF $0[17] = 49 THEN 410;
401 RETURN

410 W = 1
411 ALARM 3
412 RETURN

0 REM long button press 
0 REM if connected disconnect
0 REM otherwise turn off
420 A = status;
421 IF A == 0 THEN 440;
422 PRINTS"Bye\r\n"
423 GOSUB 430
423 A = disconnect 0 
424 ALARM 1
425 W = 0
426 RETURN

0 REM turn off
430 A = pioget 17
431 IF A = 0 THEN 161;
432 ALARM 0;
433 A = lcd "Bye Bye   "
434 A = pioset 20
435 A = pioclr 20;
435 A = pioget 17;
437 IF A = 1 THEN 434;
438 RETURN

440 GOSUB 430;
441 A = reboot
442 FOR A = 0 TO 10
443 WAIT 1
444 NEXT E
445 RETURN
