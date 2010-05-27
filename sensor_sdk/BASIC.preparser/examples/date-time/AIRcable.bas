@ERASE

0 REM $1 is reserved
1 RESERVED

0 REM $2 is PIN Code
2 1234

0 REM PIO_IRQ holder
3 RESERVED

0 REM long press detector W

0 REM state machine
0 REM S = 0 idle show DATE
0 REM S = 1 date show YYYYMMDD
0 REM S = 2 idle show TIME
0 REM S = 3 time show HH:MM:SS t

@INIT 10
0 REM no debug
10 Z = 1

0 REM setup port so debugin can be possible on the USB chip
11 A = uart 1152
0 REM disable CTS, enable UART
12 A = pioout 5
13 A = pioclr 5
14 A = uarton

0 REM enable LCD now, and show something
15 A = auxdac 200;
16 A = lcd "AIRcable  "

0 REM enable green LED, make sure blue is off
17 A = pioout 9
18 A = pioset 9
19 A = pioclr 20

0 REM allow middle button presses
20 A = pioclr 12
21 A = pioin 12

0 REM set friendly name
22 A = getuniq $8
23 $0="AIRcable Demo "
24 PRINTV $8
25 A = name $0

0 REM set up state machine
26 W = 0
27 S = 0

0 REM enable PIO irqs and exit
28 A = pioirq"P0000000000010"
29 RETURN

0 REM make sure we keep on visible
@IDLE 50
50 GOTO 100

0 REM @ALARM will keep us visible
0 REM detect long button presses
0 REM and switch our screen
@ALARM 100
100 IF W <> 0 THEN 320;

0 REM ok no long button press
0 REM update the screen
101 IF S = 0 THEN 120;
102 IF S = 1 THEN 125;
103 IF S = 2 THEN 130;
104 IF S = 3 THEN 135;
0 REM in case we are in a wrong state
0 REM we reset
106 S = 0

0 REM make visible
110 A = slave 200;
111 A = pioset 20;
112 A = pioclr 20
113 ALARM 5
114 S = S+1
115 RETURN

0 REM display DATE, then keep with
0 REM normal operation
120 A = lcd "DATE      "
121 GOTO 110;

0 REM show YYYYMMDD
125 A = date $1;
0 REM trim it so we can display it
126 $1[8]=0;
127 A = lcd $1;
128 GOTO 110

0 REM show TIME
130 A = lcd"TIME       "
131 GOTO 110;

0 REM show HHMMSSt
135 A = date $1;
0 REM extract request string
136 $1=$1[9];
0 REM fill with a space, add a zero
137 $1[8] = 32
138 $1[9] = 0;
138 A = lcd $1;

0 REM force state machine reset
139 S = -1
140 GOTO 110;

@PIN_CODE 200
200 $0=$2;
201 RETURN

@PIO_IRQ 300
300 IF $0[12]=49 THEN 310;
0 REM ignore button release on rebooting
301 IF W = 3 THEN 304;
0 REM was it a release ignore it
302 IF W = 0 THEN 304;
303 W = 0
304 RETURN

0 REM button press, save state, start ALARM for long press
310 $3 = $0;
311 W = 1;
312 ALARM 3
313 RETURN

0 REM long button handler manager (gets called by @ALARM)
320 IF $3[12]=49 THEN 330;
321 W = 0;
0 REM nothing else to do
322 GOTO 101

0 REM middle button long press
330 ALARM 0
331 A = pioirq"P0000000000000000000"
332 A = lcd "GOOD BYE"
0 REM blink blue led until user
0 REM releases button
335 A = pioset 20;
336 A = pioclr 20
337 A = pioget 12;
338 IF A = 1 THEN 335;

0 REM long press power down
339 ALARM 0;
340 W = 3
341 A = reboot
342 FOR E = 0 TO 10
343   WAIT 1
344 NEXT E
345 RETURN

