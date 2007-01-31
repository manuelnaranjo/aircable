@ERASE

0 REM Line $1 will store the address filter we are going to target
1 000A

0 REM Line $2 will store the peer address
2 0

@INIT 10
0 REM LED output and on
10 A = pioset 20
11 A = baud 96
0 REM debug
12 Z =  0
0 REM We need to intializate the state
0 REM if $2 lenght is not 12 then we don't have been paired before
0 REM E shows our state
0 REM E = 0 means upaired
0 REM E = 1 means paired
0 REM E = 2 means unpaired time out
13 A = strlen $2
14 IF A = 12 THEN 18
15 E = 0
16 A = zerocnt
17 RETURN
18 E = 1
19 RETURN


@IDLE 30
0 REM blink LED
30 A = pioset 20;
31 A = pioclr 20
32 IF E = 0 THEN 40
33 IF E = 1 THEN 50
34 IF E = 2 THEN 60
35 RETURN


0 REM unpaired
0 REM check time
40 B = readcnt
41 IF B > 120 THEN 45
0 REM no timeout
42 A = slave 5
43 RETURN

0 REM timeout, here we can do some stuff
0 REM we end with slave-1 to make the device undiscoverable
45 E = 2
46 A = slave-1
47 RETURN

0 REM we are paired, let's tell the user we are paired by blinking the leds
50 A = pioset 20;
51 A = pioclr 20
0 REM slave undiscoverable for 5 seconds
52 A = slave -5
53 RETURN

0 REM unpaired timeout we can end here.
60 RETURN


@SLAVE 100
0 REM firstly we need to choose where do we go
100 A = getconn 
101 IF E = 0 THEN 105
102 IF E = 1 THEN 150
103 IF E = 2 THEN 140
104 RETURN

0 REM we are not paired check filter

105 A = strcmp $1;
106 IF A <> 0 THEN 140

0 REM this device has passed the filter so we need to mark we are paired
107 $2 = $0
108 E = 1
0 REM 5 seconds timeout to start shell with '+' and enter
0 REM when you have a slave connection over air
109 TIMEOUTS 5
110 INPUTS $0
111 IF $0[0] = 43 THEN 120
0 REM LED on
112 B = pioset 20
0 REM connect RS232
113 C = link 1
114 RETURN

0 REM start BASIC shell
120 A = shell
0 REM LED on
121 B = pioset 20
122 RETURN

140 A = disconnect 0
141 RETURN

150 A = strcmp $2
151 IF A <> 0 THEN 140
152 GOTO 109

