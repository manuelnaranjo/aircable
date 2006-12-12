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
2 z

0 REM AIRcable.bas file
3 newbasic.txt

0 REM config.txt file
4 newbasic.txt

0 REM pin code
5 1234


0 REM DEFAULT pio settings IN ORDER
0 REM BLUE LED
0 REM GREEN LED
0 REM BUTTON
0 REM RS232 POWER OFF
0 REM RS232 POWER ON
0 REM DTR
0 REM DSR

0 REM for OEM
7 3450000
0 REM for SMD
0 REM 7 K000000

0 REM temp addresses in $10-16, max 6
0 REM variable D index of these BTaddr 
0 REM devices that will be updated addresses in $20-$25
0 REM files in $30-$35
0 REM variable I used for temp index
0 REM valid range 10 - 16
0 REM variable S used for command
0 REM S = 66 device found
0 REM variable E and F used in FOR loop

@INIT 47
47 Z = 0
48 A = baud 1152
49 IF $2[0] = 122 THEN 510
0 REM GREEN LED output and on
50 A=pioout($2[1]-48)
51 A=pioset($2[1]-48)
0 REM Blue LED output and off
52 A=pioout($2[0]-48)
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
124 PRINTU "\n\rINQUIRY
125 ALARM 2
126 RETURN

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
149 $0 = $(20 + D - 1)
150 PRINTU$0
152 GOTO 200

170 PRINTU"\n\rUPLOADING new
171 PRINTU" AIRcable.bas
172 PRINTU"\n\rUPDATING: 
173 PRINTU$(20+D-1)
174 D = D - 1;
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
201 B = ftp "config.txt"
202 GOSUB 420
203 A = close
204 ALARM 5
205 RETURN

210 A = open "newbasic.txt"
211 IF A = 0 THEN 215
212 B = ftp "AIRcable.bas"
213 GOSUB 420
214 A = close
215 ALARM 2
216 RETURN

@IDLE 301
0 REM 300 A = slave -5
301 RETURN

@SLAVE 310
310 A = shell
311 A = cancel
312 ALARM 0
313 RETURN

420 E = status
421 A = pioset ($8[0]-48)
422 IF E < 1000 THEN 427
423 WAIT 5
424 PRINTU".
426 GOTO 420
427 A = pioclr($8[0]-48)
428 E = success
429 C = C + 1
430 IF E = 1 THEN 436
431 IF E = 0 THEN 434
432 PRINTU "\n\rFTP/OPP error"
433 RETURN
434 PRINTU "\n\rno connection"
435 RETURN
436 PRINTU"\n\rDone
437 RETURN


0 REM THIS TURNS A CHAR AT $0[E] into
0 REM and integer in F
500 IF $0[E] > 57 THEN 503
501 F = $0[E] - 48;
502 RETURN
0 REM WE NEED TO ADD 10 BECAUSE "A" IS NOT 0
0 REM IS 10
503 F = $0[E] - 55;
504 RETURN

510 $0[0] = 0
511 PRINTV $7
512 FOR E = 0 TO 6
513 GOSUB 500
514 $2[E] = F + 48
515 NEXT E
517 $2[8] = 0
518 GOTO 50
