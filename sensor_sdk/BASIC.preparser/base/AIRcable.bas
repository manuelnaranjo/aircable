@ERASE
#* 

Note:You need to use parser.py before uploading this 
to any AIRcable SMD. Don't forget to define $stream 
to a valid stream

this is the common code for both monitor
and interactive mode

DOCS NEEDS UPDATING

code structure:
*1/19	variables
*20/39	user code jump table
*40	automatic scrolling display
*60	@INIT
*105	@IDLE
*130	@SLAVE
*135 	@SENSOR
*150-9	inquiry results
*160	@INQUIRY
*170	@PIO_IRQ
*200	@ALARM

base code functions:
*205	settings menu handler
*400	nice reading shower
*410	turn off
*430	make visible
*440	enable deep sleep
*450	disable deep sleep
*460	battery reading show

user code is handled with pointers
we provide some base samples,
pointers starts at line 20.
pointers:
20 @INIT
21 @ALARM (user is responsible of calling 
 	ALARM for periodic readings)
22 @IDLE extra
30 sensor reading (for compatibility we
 	recommend this in the 500-599 range)
31 sensor displaying (for compatibility we
 	recommend this in the 500-599 range)
34 left long button press
35 middle long button press
36 right long button press
37 left short button press, call ALARM
38 middle short button press, call ALARM
39 right short button press, call ALARM

*#
##---------------------------------------------
##global variables
##persistance variables
##
##PIO LIST
##this is a simple way to choose pios,
##A = 1, B = 2, C = 3
##Order:
##left button
##middle button
##rigth button
##green led
##blue led
##deep sleep pio
1 DLCIT@


## lcd contrast
2 180
## display name
3 AIRcable
## discoverable name
4 AIRsensorSDK
## peer address
5 RES
## pio handler, filled by @INIT
6 X
## battery reading
7 0000
## lcd content
8 RES
## version number
9 SDK_0_1_1
## sensor code should store message info in $10
10 0000|0000
## sensor code should store display info in $11
11 READING
## pioirq
12 P000000000000000
## sensor reading
13 RES
## pio reading
14 RES
## address filter
15 0050C2
## message rate in seconds (not very precise)
16 1
## debug
17 0
## uniq
18 RES
## WAIT . . . (used lots of times)
19 "WAIT

## ----------------------------------------
#*
non persistance variables
Y = lcd contrast
X = sensor reading rate
W = button state
V = message interval
U = time counter accumulator
T = pioirq flag T = 1 means no irq
S = inquiry shift
R = inquiry counter
Q = status
P = @SENSOR flag
O to N reserved for 'user' sensor code

-----------------------------------------
*#
## interrupt inputs
## user @INIT pointer
20 RETURN
## user @ALARM pointer
21 RETURN
## user @IDLE
22 RETURN
## sensor reading
30 RETURN
## sensor display
31 RETURN
## left long button press
34 RETURN
## middle long button press
35 RETURN
## right long button press
36 RETURN
## left short button press
37 RETURN
## middle short button press 
38 RETURN
## right short button press
39 RETURN

## display and scroll
## you can pass variable E
## to tell how many times you want
## to scroll. If you do then start at line 41
## otherwise call line 40
40 E = 2
41 B = strlen $8
42 $0 = $8;
43 PRINTV"                        ";
44 $8 = $0;
45 IF E = 0 THEN 55;
46 IF B <= 9 THEN 55
47 A = lcd $8
49 WAIT 1
50 FOR D = 0 TO E
51 FOR C = 0 TO B-8
52 A = lcd $8[C]
53 NEXT C
54 NEXT D

55 A = lcd $8
56 RETURN


## initializate the device
@INIT 57
## enable uart disable SMD CTS
57 A = pioout 5
58 A = pioclr 5
59 A = uarton

## do init sequence
60 A = baud 1152
61 Z = $17[0]-48
## enable lcd
62 Y = atoi $2
63 IF Y > 260 THEN 66
64 IF Y < 0 THEN 66
65 GOTO 70
66 Y = 200
67 $0[0] = 0
68 PRINTV Y 
69 $0 = $6
## LCD bias
70 A = auxdac Y
## show welcome message
71 $8 = $3
72 GOSUB 40
## setup friendly name
73 A = getuniq $8
74 $0 = $4
75 PRINTV " "
76 PRINTV $8
77 A = name $0
## led setting, green on, blue off
78 A = pioout ($1[3]-64)
79 A = pioset ($1[3]-64)
80 A = pioout ($1[4]-64)
81 A = pioclr ($1[4]-64)
## set up buttons:
## left
82 A = pioset ($1[0]-64)
83 A = pioin  ($1[0]-64) 
## right
84 A = pioset ($1[2]-64)
85 A = pioin  ($1[2]-64)
## middle
86 A = pioclr ($1[1]-64)
87 A = pioin  ($1[1]-64)

## show version number
88 $8 = $9
89 GOSUB 40
## start counters
90 A = zerocnt
91 U = 0
## read message rate
92 V = atoi $16
## mark we're botting
93 Q = 100
94 P = 1
95 T = 0
## 0 REM 96 A = pioout $1[5]
## 0 REM 97 A = pioclr $1[5]

## init pioirq string
98 IF $6[0]=80 THEN 20;
99 $0="P0000000000000000000"
100 FOR B = 0 TO 2
101 C=$1[B]-64
102 IF C = 0 THEN 104
103 $0[C]=49
104 NEXT B
105 $6=$0
106 PRINTU $6
107 GOTO 20;

## idle handler
@IDLE 110
110 A = pioclr($1[4]-64)
111 IF Q = 100 THEN 120
112 A = disable 3
113 IF Q > 0 THEN 22
114 ALARM 1
115 GOTO 22

## first boot, visible for 30 seconds
## trigger sensor
120 P = 1
121 A = nextsns 1
122 A = slave 30
123 P = 1
124 A = pioirq $6
125 RETURN

## @SLAVE enable shell
## THIS IS NOT SECURE!!! 
## don't use this in production
@SLAVE 130
130 A = pioset($1[4]-64);
131 A = shell;
132 RETURN

## AIO0 and AIO1 reading
@SENSOR 135
135 IF P > 0 THEN 141;
## we need to wait until @SENSOR
## is called for the second time
136 A = sensor $13;
137 $7 = $13;
138 $7[4] = 0;
139 IF Q = 100 THEN 143
140 RETURN;

## wait for both readings
141 P = P - 1;
142 RETURN;

## we're booting, let's display reading
143 Q = 0
144 GOTO 400 

## we need this so free line calculator can do it's job.
148 CANCEL
149 UNPAIR
150 RESULTS
151 RESULTS
152 RESULTS
153 RESULTS
154 RESULTS
155 RESULTS
156 RESULTS
157 RESULTS
158 RESULTS
159 RESULTS

## 150 RESULTS
## ...
## 159 RESULTS
## inquiry results
@INQUIRY 160
## we can store as much as 10 results
160 IF R >= 10 THEN 168;
## check filter
161 A= strcmp $15;
162 IF A <> 0 THEN 168;
## passed, might be a target
163 \$(150+R) = $0; 
## we need to tell Cheetah not to parse $
164 R=R+1;
165 $0=$359;
166 PRINTV R;
167 A = lcd $0
168 RETURN

## stores PIO
169 RESERVED


## PIO interrupts
@PIO_IRQ 170
170 $169=$0;
## check for long button press flag
171 IF T = 1 THEN 178;
## button press while in settings menu?
172 IF Q > 100 THEN 260;
## 173 and 175 are free, you code can hack here.
## button press starts long button recognition
175 IF$169[$1[0]-64]=48THEN180;
176 IF$169[$1[1]-64]=49THEN180;
177 IF$169[$1[2]-64]=48THEN180;
## was it a release for a short press?
178 IF W <> 0 THEN 185;
179 RETURN

## this was a new press
180 $14 = $169;
181 W = 1;
182 ALARM 3;
183 RETURN


## button released for a short press
185 W = 0;
186 ALARM 0
## hack point lines 187, 188
## left button
189 IF$14[$1[0]-64]=48THEN37;
## middle button
190 IF$14[$1[1]-64]=49THEN38;
## right button
191 IF$14[$1[2]-64]=48THEN39;
192 RETURN

## long button press, called by @ALARM
200 W = 0;
## hack point line 201,202
## long left
203 IF$14[$1[0]-64]=48THEN34;
## long middle
204 IF$14[$1[1]-64]=49THEN35;
## long right
205 IF$14[$1[2]-64]=48THEN36;
## shouldn't get here
206 ALARM 5
207 RETURN


## ALARM handler
@ALARM 230

## settings menu running?
230 IF Q > 100 THEN 250;

## check for long button press
231 IF W <> 0 THEN 200;

## no more to do on vanilla code we call user code
232 GOTO 21;

