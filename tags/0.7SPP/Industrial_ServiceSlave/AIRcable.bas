0 REM Reconfiguration Upload Program

0 REM defaults setting for mode
0 REM uncomment the one you want to use as default
0 REM service slave
2 1110
0 REM service master
0 REM 2 3110
0 REM cable slave
0 REM 2 1010
0 REM cable master
0 REM 2 3010
0 REM idle
0 REM 2 0010

0 REM $5 stores the name of the devices we only want during inquiry
5 AIRclass

0 REM $6 stores the filter address we filter on during inquiry
6 00A8FFFFFF

0 REM $7 for paired master addresses


0 REM Debug settings
0 REM first char is for Z enabled/disabled
0 REM second is for dumping states
0 REM third for Obex/ObexFTP
0 REM 0 48 Enabled only on command line
0 REM 1 49 Always enabled
0 REM 2 50 Always Disabled
9 000

0 REM $10 stores our own friendly name
10 AIRclass1

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
0 REM POWER SWITCH
0 REM COMMAND LINE PIN
0 REM BATERY MEASURMENT ENABLED
12 A0053640050

0 REM 23 unique settings
0 REM [0] = "0" don't add nothing
0 REM [0] = "1" add unique name
0 REM [0] = "2" add unique name, generate pin
23 1

0 REM don't change this lines
3 Z
4 0
7 0
8 z
13 0
14 0
21 0
955 A = getuniq $39;

