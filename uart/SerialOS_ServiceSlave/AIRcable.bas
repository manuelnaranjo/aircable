0 REM update code for AIRcable OS

0 REM defaults setting for mode
0 REM uncomment the one you want to use as default
0 REM service slave
2 1110
0 REM service master 3110
0 REM cable slave 1010
0 REM cable master 3010
0 REM idle 0010

0 REM $3 stores the mode configuration
0 REM $3[0] = 0 48 means idle
0 REM $3[0] = 1 49 means pairing as slave
0 REM $3[0] = 2 50 means paired as slave
0 REM $3[0] = 3 51 means pairing as master
0 REM $3[0] = 4 52 means paired as master
0 REM $3[0] = 5 53 means relay pairing
0 REM $3[0] = 6 54 means relay paired
0 REM $3[0] = 7 55 means relay slave connected, master connecting
0 REM $3[0] = 8 56 means relay connected

0 REM $3[1] = 0 48 cable mode
0 REM $3[1] = 1 49 service mode
0 REM $3[1] = 2 50 relay mode

0 REM $3[2] = 0 48 device found / module paired
0 REM $3[2] = 1 49 inquiry needed

0 REM $3[3] = 0 48 means automatic
0 REM $3[3] = 1 49 means manual idle.
0 REM $3[3] = 2 50 manual slave, connecting
0 REM $3[3] = 3 51 manual inq
0 REM $3[3] = 4 52 manual master, connecting
0 REM $3[3] = 5 53 manual slave, connected
0 REM $3[3] = 6 54 manual master, connected

0 REM $3[4] = 0 48 means UART command line
0 REM $3[4] = 1 49 means SPP command line


0 REM if var K = 1 then we must do a slave-1

0 REM $3[4] is the amount of time we trigger alarms while on manual
0 REM need service-master mode, does not store pairing information starts 
0 REM with pairing
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
0 REM LINE $12 STORES THE DEFAULT VALUE
0 REM z means unitializated
8 z

0 REM Debug settings
0 REM first char is for Z enabled/disabled
0 REM second char is for shell
0 REM third is for dumping states
0 REM fourth for obexftp
9 0000

0 REM $10 stores our friendly name
10 AIRcable

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
0 REM SWITCH POWER
12 A94B356C

0 REM PIO_IRQ SETTINGS
0 REM 13 only buttons pio, used for starting interrupts when there is
0 REM no connection going on
13 P000100000001
0 REM 13 P000101000001
0 REM 14 button + DSR interrupt, interrupts that must be listened while
0 REM there is a connection going on
14 P000101000001

0 REM 15 is the settings for the uart when a connection is made
0 REM 0 means read from dip swithces
0 REM any other number is converted to an int.
15 0

0 REM $21 PIO_IRQ for off mode
21 P000000000001

76 ;
77 ;

99 GOTO 971

@PIO_IRQ 950
950 IF L = 1 THEN 1007
951 A = pioget ($8[7]-48)
952 IF A = 1 THEN 968

0 REM we were turned off
0 REM firstly reboot
953 GOTO 1004

0 REM then when it comes up again
0 REM switch off:
0 REM 	alarms
0 REM 	sensors
0 REM 	uart interrupt
0 REM 	and go invisible

954 M = 1;
955 ALARM 0;
956 A = nextsns 0;
957 A = pioclr ($8[0]-48);
958 A = pioclr ($8[1]-48);
959 A = pioclr ($8[2]-48);
960 A = pioclr ($8[3]-48);
961 A = pioclr ($8[4]-48);
962 A = pioclr ($8[5]-48);
963 A = pioclr ($8[6]-48);
964 A = slave -1;
965 A = disable 3
966 A = pioirq $21;
967 RETURN

968 IF M = 0 THEN 142
969 ALARM 5
970 GOTO 65

971 A = pioirq $13
972 A = pioget ($8[7]-48);
973 H = 0;
974 N = 0;
975 L = 1
976 IF A = 0 THEN 954;
977 RETURN

@SENSOR 978
978 A = sensor $0
979 V = atoi $0[5]
980 A = nextsns 600
981 IF V < 3000 THEN 983
982 GOTO 986

983 N = 1
984 ALARM 5
985 GOTO 112

986 N = 0
987 ALARM 5
988 GOTO 112

@ALARM 989
989 IF N = 1 THEN 991
990 GOTO 220

991 A = pioclr ($8[1]-48)
992 A = pioset ($8[1]-48);
993 ALARM 5
994 IF $3[3] = 49 THEN 454
995 IF $3[0] = 48 THEN 1000
996 GOTO 220

997 IF $3[3] <> 48 THEN 977;
998 IF $3[0] = 48 THEN 1000;
999 GOTO 977

1000 IF K = 0 THEN 1003
1001 A = slave -1
1002 K = 0
1003 RETURN

1004 A = reboot
1005 WAIT 3
1006 RETURN

1007 L = 0
1008 RETURN

@IDLE 1009
1009 L = 0
1010 IF N = 1 THEN 997
1011 IF M = 0 THEN 192
1012 RETURN

