@ERASE

0 REM Line $1 paired device
1 0

@INIT 50
0 REM debug
50 Z = 1
51 A = slave -1
0 REM J stores the pio where the led is attached
52 J = 20
0 REM LED output an don
53 A = pioset J
54 A = baud 96
0 REM E will be used for state
0 REM E = 0 unpaired
0 REM E = 1 paired - disconnected
0 REM E = 2 paired - connected
0 REM E = 3 upaired - timeout
55 A = strlen $1
56 IF A > 11 THEN 60
57 E = 0
58 A = zerocnt
59 RETURN

60 E = 1
61 RETURN

@IDLE 70
70 ALARM 1
71 RETURN

@ALARM 100
0 REM we need to start an inquiry
0 REM blink leds
100 IF E = 3 THEN 110
101 IF E = 1 THEN 130
102 IF E = 2 THEN 150
103 A = pioset J;
104 A = pioclr J
105 ALARM 6
106 A = readcnt
107 IF A > 120 THEN 110
108 A = inquiry 5
109 RETURN

110 ALARM 0
111 E = 3
112 RETURN

0 REM a device has been discoverd, let's try to connect
130 A = pioset J
131 A = pioclr J
132 A = master $1
133 ALARM 6
134 RETURN

0 REM we are connected, lets check we are still connected
150 A = status
151 IF A = 0 THEN 155
152 ALARM 10
153 RETURN

0 REM we were disconencted
155 A = pioclr J
156 ALARM 1
157 E = 0
158 A = unlink 3
159 RETURN

@INQUIRY 200
0 REM when this interrupt gets called we have on $0 an string like this:
0 REM 00112233445566 NAME where the number is the bt address.
200 $1 = $0
201 ALARM 1
202 E = 1
203 A = cancel
204 RETURN

@MASTER 300
300 E = 2
301 A = pioset J
302 C = link 2
303 RETURN

