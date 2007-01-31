@ERASE

0 REM Line $1 discovered device buffer
1 0

0 REM Line $2 stores the name filter
2 AIRcable

0 REM Line $3 stores the address filter
3 000A

@INIT 50
0 REM debug
50 Z = 0
0 REM empty discovered device buffer.
51 $1 = "0"
52 A = slave -1
0 REM J stores the pio where the led is attached
53 J = 20
0 REM LED output an don
54 A = pioset J
55 A = baud 96
0 REM E will be used for state
0 REM E = 0 disconnected
0 REM E = 1 connected
56 E = 0
57 RETURN

@IDLE 60
60 ALARM 1
61 RETURN

@ALARM 100
0 REM we need to start an inquiry
0 REM blink leds
100 IF E = 1 THEN 150
101 A = pioset J;
102 A = pioclr J
103 ALARM 6
104 A = strlen $1
105 IF A > 11 THEN 130
106 A = inquiry 5
107 RETURN

0 REM a device has been discoverd, let's try to connect
130 A = pioset J
131 A = master $1
132 ALARM 6
133 $1 = "0
134 RETURN

0 REM we are connected, lets check we are still connected
150 A = status
151 IF A = 0 THEN 155
152 ALARM 10
153 RETURN

0 REM we were disconencted
155 $1 = "0
156 A = pioclr J
157 ALARM 1
158 E = 0
159 A = unlink 3
160 RETURN

@INQUIRY 200
0 REM when this interrupt gets called we have on $0 an string like this:
0 REM 00112233445566 NAME where the number is the bt address.
0 REM we need to check first if the addess is on our block of address
0 REM then if the name matches the filter
200 A = strcmp $3
201 IF A <> 0 THEN 208
202 $5 = $0
203 $6 = $0[13];
204 $0 = $6
205 A = strcmp $2
206 IF A <> 0 THEN 208
207 $1 = $5
208 ALARM 1
209 RETURN

@MASTER 300
300 E = 1
301 A = pioset J
302 C = link 2
303 RETURN

