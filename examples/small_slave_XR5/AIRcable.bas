0 REM Industrial XR3 Mini Slave

@ERASE

1 1234

@INIT 10
0 REM PIN code
10 $1 = "1234"
0 REM blue LED output and on
11 A = pioset 20
0 REM RS232 POWER ON out and on, PIO12
12 A = pioout 13
13 REM A = pioclr 13
14 A = pioset 13
0 REM RS232 POWER OFF out and on, PIO11
15 A = pioout 12
16 A = pioset 12
0 REM RS232 DTR pin out and on, PIO13
17 A = pioset 14
18 A = pioout 14
0 REM PIO17 goes high when pressed no need to change PIO

0 REM Sleep mode PIO10 (low no deep sleep) and Handshake PIO15 (high enabled)
19 A = pioout 11
20 A = pioclr 11
21 A = pioout 16
22 A = pioset 16

0 REM set uart to 115200
23 A = baud 1152

24 A = zerocnt
25 $0="IndXR3 "
26 A = getuniq $2
27 PRINTV $2
28 A = name $0
29 G = 1
30 K = 1
0 REM button state variable
31 W = 0

0 REM check for button, virtual PIO17
32 A=pioirq"P00000000000000001"
33 RETURN

@SLAVE 40
0 REM blue LED on
40 B = pioset 20
0 REM set DTR to +5V
41 B = pioclr 14
0 REM RS232_on high
42 B = pioset 13
0 REM connect RS232
43 C = link 1
44 RETURN

@IDLE 50
0 REM set DTR to -5V
50 A = pioset 14;
0 REM LED off
51 A = pioclr 20;
52 GOTO 200


@PIO_IRQ 100
100 IF $0[17]=49 THEN 110;
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
170 A = pioget 17;
171 IF A = 0 THEN 190;

0 REM long press power down
172 ALARM 0;
0 REM wait until button release
173 REM
174 A = pioclr 20;
175 A = pioget 17;
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
202 A = pioclr 20
203 A = delayms 100
204 A = pioset 20;
205 A = pioclr 20;
206 IF G = 1 THEN 210
207 ALARM 5
208 RETURN

210 A = readcnt
211 IF A < 60 THEN 207
212 WAIT 3
213 A = disable 3
214 G = 0
215 GOTO 207

@PIN_CODE 240
0 REM fixed PIN code
240 $0=$1;
241 RETURN


@CONTROL 250
0 REM remote request for DTR pin on the RS232
250 IF $0[0] = 49 THEN 253;
251 A=pioset 14;
252 RETURN;
253 A=pioclr 14;
254 RETURN
255
