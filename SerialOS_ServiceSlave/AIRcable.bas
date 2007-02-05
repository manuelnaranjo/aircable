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


0 REM if var K = 1 then we must do a slave-1

0 REM $3[4] is the amount of time we trigger alarms while on manual
0 REM need service-master mode, does not store pairing information starts 
0 REM with pairing
3 Z

0 REM $4 IS RESERVED FOR PAIRED ADDR
4 0

0 REM $5 stores the name of the devices we only want during inquiry
5 AIRcable

0 REM $6 stores the filter address we filter on during inquiry
6 00A8FFFFFF

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

98 GOTO 875

@PIO_IRQ 850
850 A = pioget ($8[7]-48)
851 IF A = 1 THEN 870

0 REM we were turned off
0 REM switch off:
0 REM 	alarms
0 REM 	sensors
0 REM 	uart interrupt
0 REM 	and go invisible
852 M = 1;
853 ALARM 0;
854 A = nextsns 0;
855 A = pioclr ($8[0]-48);
856 A = pioclr ($8[1]-48);
857 A = pioclr ($8[2]-48);
858 A = pioclr ($8[3]-48);
859 A = pioclr ($8[4]-48);
860 A = pioclr ($8[5]-48);
861 A = pioclr ($8[6]-48);
862 A = disconnect 0;
863 A = disconnect 1;
864 A = slave -1;
865 A = pioirq $21;
866 RETURN

870 IF M = 0 THEN 142
871 ALARM 5
872 GOTO 64

875 A = pioget ($8[7]-48);
876 H = 0;
877 N = 0;
878 IF A = 0 THEN 852;
879 RETURN

@IDLE 880
880 IF N = 1 THEN 910
881 IF M = 0 THEN 192
882 RETURN

@SENSOR 885
885 A = sensor $0
886 V = atoi $0[5]
887 A = nextsns 600
888 IF V > 3000 THEN 890
889 GOTO 985

890 N = 1
891 ALARM 5
892 GOTO 112

895 N = 0
896 ALARM 5
897 GOTO 112

@ALARM 900
900 IF N = 1 THEN 905 
901 GOTO 227

905 A = pioclr ($8[1]-48)
906 A = pioset ($8[1]-48);
907 ALARM 5
908 IF $3[0] = 48 THEN 915
909 GOTO 227

910 IF $3[3] <> 48 THEN 881;
911 IF $3[0] = 48 THEN 915;
912 GOTO 881

915 IF K = 0 THEN 918
916 A = slave -1
917 K = 0
918 RETURN


