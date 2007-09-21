@ERASE

0 REM Line $1 device address
0 REM when we loose a connection, we try to connect to the
0 REM same device 5 times and then we start inquirying again
1 0050C2585000

0 REM Line $2 stores the name filter
0 REM 2 AIRcable
2


0 REM Line $3 stores the address filter
0 REM example: 3 0050C2
0 REM all addresses start with 0
3 0

4 

@INIT 50
0 REM LED output and on
50 A = pioout 20
51 A = pioset 20

52 A = name "AIRsmart5"
0 REM reduce range
53 A = maxpower -16

0 REM baud rate is 9600, always
55 A = baud 96
0 REM E will be used for state
0 REM E = 0 startup
0 REM E = 1 connected
56 E = 0
57 K = zerocnt
0 REM F = 1 need to disable ftp
58 F = 1
0 REM H connection counter
59 H = 0

0 REM swich on the smart card chip TDA8024
0 REM PIO(0) is OFF - is low when no card 
0 REM PIO(1) is RSTIN - card reset input
0 REM PIO(2) is CMDVCC - start activation seq when low
0 REM PIO(3) is CLKDIV1 - 00 = div by 8
0 REM PIO(4) is CLKDIV2
0 REM PIO(10) is 5V/3V - high = 5V

0 REM IDLE state
0 REM OFF input with pullup
60 A = pioin 1;
61 A = pioset 1;

0 REM card reset to high
62 A = pioset 2;
63 A = pioout 2;

0 REM CMDVCC high
64 A = pioset 3;
65 A = pioout 3;

0 REM clock div by 4
66 A = pioout 4;
67 A = pioout 5;
68 A = pioset 5;
69 A = pioclr 4;

0 REM 5V card
70 A = pioout 11;
71 A = pioset 11;

0 REM green LED
72 A = pioout 9;
0 REM red LED
73 A = pioset 10;
74 A = pioout 10;

0 REM start master connection
75 A = pioget 1
76 IF A = 0 THEN 78
77 A = master $1

78 RETURN


@IDLE 700
0 REM on start slave when no card present
700 IF E = 1 THEN 710
701 A = pioget 1
702 IF A = 0 THEN 710

0 REM otherwise wait for master to succeed or not
703 ALARM 5
704 RETURN

0 REM startup, no card
0 REM CMDVCC high, just to make sure
710 A = pioset 3;
711 A = slave 60;
0 REM blue off, red LED on
712 A = pioclr 20;
713 A = pioclr 10;
0 REM slave enabled
714 E = 1;
715 RETURN



0 REM alarm used for master connection check only

@ALARM 100
0 REM lets check if we are connected
100 A = status
101 IF A = 0 THEN 120
0 REM connected, check every 5 sec
102 ALARM 5
103 RETURN

0 REM not connected, or master disconnected
0 REM the first master was not successful, switch off
120 A = pioset 3
121 A = reboot
0 REM green LED on, blue off
122 A = pioset 9
123 A = pioclr 20
124 RETURN




@MASTER 300
300 E = 0
0 REM blue led on
301 A = pioset 20
302 A = link 2
0 REM check for master
303 ALARM 5
0 REM activation sequence
0 REM RSTIN low
304 A = pioclr 2
0 REM set CMDVCC low
305 A = pioclr 3
306 WAIT 1
0 REM now the clock starts up
0 REM activate card, unreset RSTIN
307 A = pioset 2
308 RETURN


@SLAVE 400
0 REM SPP connection
0 REM we show the SPP only to make the device visible

0 REM start shell when no card present
400 A = pioget 1
401 IF A = 0 THEN 410

402 A = link 1
0 REM activation sequence
0 REM RSTIN low
403 A = pioclr 2
0 REM set CMDVCC low
404 A = pioclr 3

0 REM now the clock starts up
0 REM activate card, unreset RSTIN
405 A = pioset 2
406 RETURN

410 A = pioset 20;
411 A = shell
412 RETURN


