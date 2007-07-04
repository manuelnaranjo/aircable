0 REM Reconfiguration Upload Program
0 REM target device: AIRserial3

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
10 AIRserial3

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
0 REM Power Switch
12 A94B35100

0 REM PIO_IRQ SETTINGS
0 REM 13 only buttons pio, used for starting interrupts when there is
0 REM no connection going on
13 P00010000000

0 REM 14 button + DSR interrupt, interrupts that must be listened while
0 REM there is a connection going on
14 P01010000000

0 REM 15 is the settings for the uart when a connection is made
0 REM 0 means read from dip swithces
0 REM any other number is converted to an int.
15 0

21 P000000000000

