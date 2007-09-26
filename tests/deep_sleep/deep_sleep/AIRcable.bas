@ERASE
@INIT 10
10 A = auxdac 200
11 A = lcd"TEST                    "
12 A = uartoff
13 A = disable 3
14 ALARM 10
15 RETURN

@ALARM 20
20 A = uarton
21 A = lcd"TEST
22 ALARM 10
23 A = uartoff
24 RETURN

@PIO_IRQ 60
60 A = reboot
61 RETURN

