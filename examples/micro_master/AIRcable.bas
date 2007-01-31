@ERASE

0 REM Line $1 discovered device buffer
1 0

@INIT 50
0 REM debug
50 Z = 0
0 REM empty discovered device buffer.
51 $1 = "0"
0 REM E = 0 need to inquiry
0 REM E = 1 inquiring
0 REM E = 2 device found
0 REM E = 3 connecting
0 REM E = 4 coonected
52 E = 0
53 A = slave -1
0 REM J stores the pio where the led is attached
54 J = 20
0 REM LED output an don
55 A = pioset J
56 A = baud 96

57 RETURN

@IDLE 60
60 ALARM 1
61 RETURN

@ALARM 100
100 IF E = 0 THEN 110;
101 IF E = 1 THEN 120;
102 IF E = 2 THEN 130;
103 IF E = 3 THEN 140;
104 IF E = 4 THEN 150;
105 RETURN

0 REM we need to start an inquiry
0 REM blink leds
110 A = pioset J;
111 A = pioclr J
112 ALARM 6
113 A = status
114 IF A <> 0 THEN 116
115 A = inquiry 5
116 E = 1
117 RETURN

0 REM we are inquirying
120 A = status
121 ALARM 5
122 IF A <> 0 THEN 117
123 ALARM 1
124 RETURN

0 REM a device has been discoverd, let's try to connect
130 A = pioset J
132 A = master $1
132 ALARM 6
133 E = 3
134 RETURN

0 REM if we reach this point is because the @MASTER was never called, that means
0 REM that the connection failured.
140 A = pioclr J;
141 A = pioset J
142 A = pioclr J;
143 A = pioset J
144 A = pioclr J;
145 E = 0
146 ALARM 1
147 RETURN

0 REM we are connected, lets check we are still connected
150 A = status
151 IF A = 0 THEN 155
152 ALARM 10
153 RETURN

0 REM we were disconencted
155 $1 = "0
156 E = 0
157 A = pioclr J
158 ALARM 1
160 RETURN

@INQUIRY 200
200 $1 = $0
201 E = 2
202 A = pioset 20;
203 A = pioclr 20
204 A = pioset 20;
205 A = pioclr 20
206 A = pioset 20;
207 A = pioclr 20
208 ALARM 1
209 RETURN

@MASTER 300
300 E = 4
301 A = pioset J
302 C = link 2
303 RETURN
