@ERASE

0 REM name filter
1 ACV26

0 REM $2 stores the pio settings
0 REM $2[0] BLUE LED
0 REM $2[1] GREEN LED
0 REM $2[2] BUTTON
0 REM $2[3] RS232 POWER OFF
0 REM $2[4] RS232 POWER ON
0 REM $2[5] DTR
0 REM $2[6] DSR
2 3450000

0 REM AIRcable.bas file
3 newbasic.txt

0 REM config.txt file
4 newbasic.txt

0 REM pin code
5 1234

0 REM temp addresses in $10-16, max 6
0 REM variable D index of these BTaddr 
0 REM devices that will be updated addresses in $20-$25
0 REM files in $30-$35
0 REM variable I used for temp index
0 REM valid range 10 - 16
0 REM variable S used for command
0 REM S = 66 device found
0 REM variable E and F used in FOR loop

@INIT 48
48 Z = 0
49 A = baud 1152
0 REM GREEN LED output and on
50 A=piout($2[1]-48)
51 A=pioset($2[1]-48)
0 REM Blue LED output and off
52 A=piout($2[0]-48)
53 A=pioclr($2[0]-48)
54 D = 0
55 $10[0] = 0
56 H = 16
57 L = 16
58 $16[0] = 0
59 ALARM 2
60 A = slave -1
61 C = 0
62 RETURN

@PIN_CODE 65
65 $0 = $5
66 RETURN


@INQUIRY 69
0 REM start with $10, must have ; 

69 IF D > 0 THEN 80;
70 IF I > 16 THEN 80;
72 S = 66;
73 ALARM 2
74 $I = $0;
75 I = I + 1;
76 PRINTU "\n\rFOUND: ";
77 PRINTU $0
78 RETURN

80 A = cancel
81 ALARM 2
82 RETURN

@ALARM 98
98 A = pioset ($2[0]-48)
99 A = pioclr ($2[0]-48)
100 IF S = 66 THEN 106
101 A = status
102 IF A < 10000 THEN 121
103 ALARM 2
104 RETURN

106 A = status
107 IF A < 10000 THEN 110
0 REM still inquiring, schedule next ALARM
108 ALARM 2
109 RETURN

0 REM switch the state, if D > 0 THEN we have a que
110 IF C = 2 THEN 180
111 IF D <> 0 THEN 144
0 REM no que, generate the que then
112 D = 0;
113 FOR B=10 TO I-1
114 $6 = $B[13];
115 $0 = $1;
116 A = strcmp $6;
117 IF A <> 0 THEN 120
118 $(20+D) = $B
119 D = D + 1;
120 NEXT B
121 IF D <> 0 THEN 138
122 I = 10;
123 A = inquiry 10;
124 ALARM 2
125 RETURN

0 REM print how many devices we are going to handle
138 A = cancel
139 ALARM 0
140 PRINTU"\n\rABOUT TO
141 PRINTU" UPDATE 
142 PRINTU D
143 PRINTU" DEVICES

144 IF C = 1 THEN 170
146 PRINTU"\n\rUPLOADING new
147 PRINTU" config.txt

148 PRINTU"\n\rUPDATING: 
149 PRINTU$(20 +D-1) 
150 C = 1
152 GOTO 200

170 PRINTU"\n\rUPLOADING new
171 PRINTU" AIRcable.bas
172 PRINTU"\n\rUPDATING: 
173 PRINTU$(20 +D-1)
174 D = D - 1;
175 C = 2
177 GOTO 210

180 C = 0
181 ALARM 2
182 IF D = 0 THEN 190
183 ALARM 4
184 RETURN

190 S = 0
191 I = 0
192 ALARM 2
193 RETURN

200 A = open "newconf.txt"
201 IF A = 0 THEN 204
202 $0 = $(20+D-1)
203 B = ftp "config.txt"
204 GOSUB 420
205 A = close
206 ALARM 3
207 RETURN

210 A = open "newbasic.txt"
211 IF A = 0 THEN 214
212 $0 = $(20+D-1)
213 B = ftp "AIRcable.bas"
214 GOSUB 420
215 A = close
216 ALARM 3
217 RETURN


@IDLE 301
0 REM 300 A = slave -5
301 RETURN

@SLAVE 310
310 A = shell
311 A = cancel
312 ALARM 0
313 RETURN

420 E = status
421 IF E < 1000 THEN 424
422 WAIT 5
423 GOTO 420
424 E = success
425 IF E = 1 THEN 429
426 PRINTU "\n\rFTP/OPP error"
427 IF E = -1 THEN 429
428 PRINTU "\n\rno connection"
429 RETURN

