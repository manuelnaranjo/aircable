@ERASE

0 REM name filter
1 ACV26

0 REM $8 stores the pio settings
0 REM $8[0] BLUE LED
0 REM $8[1] GREEN LED
0 REM $8[2] BUTTON
0 REM $8[3] RS232 POWER OFF
0 REM $8[4] RS232 POWER ON
0 REM $8[5] DTR
0 REM $8[6] DSR
0 REM LINE $12 STORES THE DEFAULT VALUE
0 REM z means unitializated
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

@INIT 49
49 Z = 1
0 REM GREEN LED output and on
50 A = piout ($8[1]-48)
51 A = pioset ($8[1]-48) 
0 REM Blue LED output and off
52 A=piout($8[0] - 48)
53 A=pioclr ($8[0] - 48)
54 D = 10
55 $10[0] = 0
56 H = 16
57 L = 16
58 $16[0] = 0
59 ALARM 1
61 A = baud 1152
62 A = slave -1
63 RETURN

@PIN_CODE 65
65 $0 = $5
66 RETURN


@INQUIRY 70
0 REM start with $10, must have ; 

70 IF I > 16 THEN 80;
72 S = 66;
73 ALARM 1;
74 $I = $0;
75 I = I + 1;
76 PRINTU "\n\rFOUND: ";
77 PRINTU $0
78 RETURN

80 A = cancel
81 ALARM 1
82 RETURN

@ALARM 98
98 A = pioset ($8[0] - 48)
99 A = pioclr ($8[0] - 48)
100 IF S = 66 THEN 102
101 RETURN

102 A = status
103 IF A < 10000 THEN 110
0 REM still inquiring, schedule next ALARM
104 ALARM 2
105 RETURN

0 REM go through all discovered
110 D = 0;
111 FOR J = 10 TO I-1;
112 $0 = $J;
113 A = strcmp $1;
114 IF A <> 0 THEN 117
115 D = D + 1;
116 $(20+D) = $0
117 NEXT J
118 IF D <> 0 THEN 138
126 I = 10;
127 A = inquiry 10;
128 RETURN

0 REM print how many devices we are going to handle
138 A = cancel
139 ALARM 0
140 PRINTU"\n\rABOUT TO
141 PRINTU" UPDATE 
142 PRINTU D
143 PRINTU" DEVICES
145 PRINTU"\n\rUPLOADING new
146 PRINTU" config.txt
147 FOR E = 0 TO D;
148 PRINTU"\n\rUPDATING: 
149 PRINTU$(20 +E)
150 A = open "newconf.txt"
151 $0 = $(20+E)
152 B = ftp "config.txt"
153 A = close
154 NEXT E
155 PRINTU"\n\rUPLOADING new
156 PRINTU" AIRcable.bas
157 FOR E = 0 TO D;
158 PRINTU"\n\rUPDATING: 
159 PRINTU$(20 +E)
160 A = open "newconf.txt"
161 $0 = $(20+E)
162 B = ftp "config.txt"
163 A = close
164 NEXT E
165 ALARM 1
166 S = 66
167 RETURN

@IDLE 300
300 ALARM 1
301 RETURN

@SLAVE 310
310 A = disconenct 0
311 RETURN

