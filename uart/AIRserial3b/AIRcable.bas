0 REM Reconfiguration Upload Program
0 REM target device: AIRserial4

0 REM defaults setting for mode
0 REM uncomment the one you want to use as default
0 REM service slave
2 1110

0 REM service master 3110
0 REM cable slave 1010
0 REM cable master 3010
0 REM idle 0010

0 REM $3 stores the mode configuration
3 Z

0 REM $4 IS RESERVED FOR PAIRED ADDR
4 0

0 REM $7 for paired master addresses
7 0

0 REM $8 stores the pio settings
0 REM $8[0] BLUE LED
0 REM $8[1] GREEN LED
0 REM $8[2] BUTTON
0 REM $8[3] RS232 POWER OFF
0 REM $8[4] RS232 POWER ON
0 REM $8[5] DTR
0 REM $8[6] DSR
0 REM $8[7] POWER BUTTON
0 REM LINE $12 STORES THE DEFAULT VALUE
0 REM z means unitializated
8 z

0 REM Debug settings
0 REM first char is for Z enabled/disabled
0 REM second char is for shell
0 REM third is for dumping states
0 REM fourth for obexftp
0 REM fifth for obex
9 00000

0 REM $10 stores our own friendly name
10 AIRserial4

0 REM $11 stores our PIN
11 1234

0 REM DEFAULT pio settings IN ORDER
0 REM BLUE LED
0 REM GREEN LED
0 REM BUTTON
0 REM RS232 POWER OFF
0 REM RS232 POWER ON
0 REM DTR
0 REM DSR
0 REM Power Button
12 K90B351C
0 REM debug 12 A90B3514


0 REM PIO_IRQ SETTINGS
0 REM 13 only buttons pio, used for starting interrupts when there is
0 REM no connection going on
0 REM debug 13 P000100000000
13 P000000000001

0 REM 14 button + DSR interrupt, interrupts that must be listened while
0 REM there is a connection going on
0 REM debug 14 P001100000000
14 P100000000001

0 REM 15 is the settings for the uart when a connection is made
0 REM 0 means read from dip swithces
0 REM any other number is converted to an int.
15 0

77 ;

99 GOTO 950

0 REM this piece of code completes the @INIT
950 N = 0
951 A = pioin($8[6]-48)
952 A = pioset($8[7]-48)
953 A = pioin($(8[7]-48);
954 A = pioirq$13
955 RETURN

@SENSOR 960
960 A = sensor $0
961 V = atoi $0[5]
962 A = nextsns 600
963 IF V < 3000 THEN 965
964 GOTO 968

0 REM low batteries
965 N = 1
966 ALARM 5
967 GOTO 112

0 REM batteries are OK
968 N = 0
969 ALARM 5
970 GOTO 112

@ALARM 975
975 IF N = 1 THEN 977
976 GOTO 220

977 A = pioclr ($8[1]-48)
978 A = pioset ($8[1]-48);
979 GOTO 220

@IDLE 980
980 IF N = 1 THEN 982
981 GOTO 192

982 A = pioclr ($8[1]-48)
983 A = pioset ($8[1]-48);
984 GOTO 192

@PIO_IRQ 990
0 REM turn off function
990 A = pioget ($8[7]-48);
991 IF A = 1 THEN 995;
992 GOTO 142

995 I = 0;
996 WAIT 1
997 A = pioget($8[7]-48);
998 IF A = 0 THEN 142;
999 IF I = 5 THEN 1002;
1000 I = I+1;
1001 GOTO 996

0 REM turn off leds to tell the user
0 REM he can release the button
1002 A = pioclr($8[0]-48);
1003 A = pioclr($8[1]-48);
1004 A = pioget($8[7]-48);
1005 IF A = 0 THEN 1008;
1006 WAIT 1
1007 GOTO 1004;

1008 A = reboot
1009 FOR E=0 TO 10
1010  WAIT 1
1011 NEXT E
1012 RETURN
