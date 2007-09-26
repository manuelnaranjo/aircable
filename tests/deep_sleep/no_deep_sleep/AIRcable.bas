@ERASE
@INIT 10
10 A = auxdac 200
11 A = lcd"TEST                    "
12 A = disable 3
13 A = pioout 9
14 A = pioset 9
15 A = pioin 12
16 A = pioclr 12
17 A = pioin 2
18 A = pioset 2
19 A = pioin 3
20 A = pioset 3
21 A = pioirq"P010010000001"
22 A = uartoff
23 RETURN

@PIO_IRQ 60
60 A = reboot
61 RETURN

