@ERASE

@INIT 9
9 Z = 0
0 REM green LED output and on
10 A = pioout 9
11 A = pioset 9
0 REM blue LED output and off
13 A = pioclr 20
0 REM RS232 POWER ON out and on
14 A = pioout 3
15 A = pioset 3
0 REM RS232 POWER OFF out and on
16 A = pioout 11
17 A = pioset 11
0 REM RS232 DTR pin out and on
18 A = pioset 5
19 A = pioout 5
0 REM PIO12 goes high when pressed, add 
20 A = pioclr 12
21 A = pioin 12

0 REM set uart to 9600
22 A = baud 96

23 A = zerocnt
24 $0="IDsmart "
25 A = getuniq $2
26 PRINTV $2
27 A = name $0
28 G = 1
29 K = 1
0 REM button state variable
30 W = 0

0 REM check for button
31 A = pioirq "P000000000001"
32 RETURN

@SLAVE 40
0 REM blue LED on
40 B = pioset 20
0 REM set DTR to high
41 B = pioclr 5
0 REM connect RS232
42 C = link 1
43 RETURN

@IDLE 50
50 A = pioset 5;
51 A = pioclr 20;
52 IF K = 0 THEN 200;
0 REM after boot a call to slave
0 REM doesn't register the SPP, so we drop it.
53 A = slave 1
54 K = 0
55 RETURN

@PIO_IRQ 100
100 IF $0[12]=49 THEN 110;
0 REM ignore button release on rebooting
101 IF W = 3 THEN 103;
0 REM was it a release, handle it
102 IF W <> 0 THEN 120;
103 RETURN

0 REM button press, save state, start ALARM
110 $2 = $0;
111 W = 1;
112 ALARM 3
113 RETURN

0 REM button press disconnects slave
120 A = disconnect 0
121 A = pioclr 20
122 RETURN


@ALARM 170
0 REM check for button pressed
170 A = pioget 12;
171 IF A = 0 THEN 190;

0 REM long press power down
172 ALARM 0;
0 REM wait until button release
173 A = pioclr 9;
174 A = pioclr 20;
175 A = pioget 12;
176 IF A = 1 THEN 175;
177 W = 3;
178 A = reboot;
179 FOR E = 0 TO 10
180   WAIT 1
181 NEXT E
182 RETURN


190 A = status;
191 IF A = 0 THEN 200;
0 REM we have a connection
192 A = pioset 20
193 RETURN


0 REM blink blue LED
200 A = slave 15
201 A = pioset 20;
202 A = pioclr 20;
203 A = pioset 20;
204 A = pioclr 20;
205 IF G = 1 THEN 210
206 ALARM 5
207 RETURN

210 A = readcnt
211 IF A < 60 THEN 206
212 WAIT 3
213 A = disable 3
214 G = 0
215 GOTO 206


@CONTROL 250
0 REM remote request for DTR pin on the RS232
250 IF $0[0] = 49 THEN 253;
251 A=pioset 5;
252 RETURN;
253 A=pioclr 5;
254 RETURN



