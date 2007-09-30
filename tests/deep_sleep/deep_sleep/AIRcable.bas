@ERASE
@INIT 10
10 A = auxdac 200
11 A = lcd"TEST                    "
12 A = uartoff
13 A = disable 3
14 O = 0
15 K = 0
0 REM PIO12 middle button goes high when pressed
17 A = pioin 12
18 A = pioclr 12
19 A = pioirq "P000000000001"
0 REM LED output and on
20 A = pioout 9
21 A = pioset 9

22 ALARM 10
23 RETURN

@ALARM 30
30 IF O = 1 THEN 35
31 O = 1
32 A = uartoff
33 A = pioclr 9
34 GOTO 45
35 O = 0
36 A = uarton
37 A = pioset 9
38 GOTO 45


45 K = K + 1
46 $0[0] = 0
47 PRINTV "A "
48 PRINTV K
49 PRINTV " "
50 PRINTV O
51 PRINTV "     "

52 A = lcd $0
53 ALARM 10
54 RETURN

@PIO_IRQ 60
60 A = reboot
61 RETURN

