@ERASE

0 REM DUN - SPP example
0 REM this example will show you how to work with both 
0 REM SPP to DUN profile

0 REM $1 state
0 REM $1[0] = 48 SPP
0 REM $1[0] = 49 DUN
1 0

0 REM this code fits the SMD, change the PIO if you want

@INIT 19
19 Z = 1
0 REM set uart
20 A = baud 1152
21 J = 20
0 REM LED
22 A = pioout J
23 A = pioclr J
0 REM set name to something different than factory.
24 A = name "AIRcable"
0 REM give time to INIT to end
25 WAIT 3
26 RETURN

@IDLE 50
0 REM switch profile
50 IF $1[0]=49 THEN 60

0 REM slave
51 A = slave 5
52 A = pioset J
53 A = pioclr J
54 RETURN


0 REM DUN profile
60 A = dialup 5
61 A = pioclr J
62 A = pioset J
63 RETURN

@SLAVE 100
0 REM turn on led
100 A = pioset J
0 REM do you want to start command line
101 TIMEOUTS 5
102 INPUTS $0
103 A = strlen $0
104 IF $0[A-3]=43 THEN 110

0 REM the user didn't wanted to start the command line
105 IF A = 0 THEN 107
106 PRINTU $0
107 A = link 1
108 RETURN

0 REM give the user a simple command line
110 PRINTS"Welcome\n\r"
111 PRINTS"Profile:\n\r"
112 PRINTS"1 - SPP\n\r"
113 PRINTS"2 - DUN\n\r"
114 PRINTS"Option: "

0 REM let's check the input
115 INPUTS $0
116 IF $0[0] = 49 THEN 130
117 IF $0[0] = 50 THEN 140
0 REM sorry wrong option
118 PRINTS"\n\rInvalid "
119 PRINTS"Option\n\r
120 GOTO 110

0 REM SPP choosen
130 $1="0"
132 PRINTS"Bye, bye"
133 A = disconnect 0
134 RETURN

0 REM DUN choosen
140 $1="1"
141 GOTO 132

