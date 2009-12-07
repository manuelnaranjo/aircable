
## This sensor code is for a Serial3X which connects
## to a LinkTH from iButtonLink.com


##PIO LIST of the Serial3X
##this is a simple way to choose pios,
##A = 1, B = 2, C = 3
##Order:
##left button - none
##middle button - 12
##rigth button - none
##green led - 9
##blue led - 20
##deep sleep pio - none
1 @L@IT@

## discoverable name
4 AIRlinkTH

## interrupt insertion points
0 REM extra @INIT
20 GOTO 990;


## BUTTON PRESS HANDLERS
## middle short button press 
38 GOTO 430;
## middle long button press turn off
35 GOTO 410;


0 REM flush once each 20 readings
662 IFK>=20 THEN 665;

## adjust sensor reading freq to 3 sec
908 GOTO 930;
910 ALARM 3;

## commit each 5 minutes
941 IF U-V>300 THEN 943;
942 GOTO 910;

943 V=U;

## type
19 MONITOR-SOLAR

## set our sensor reading routines
30 GOTO 520;

## we'll store reading in $500
500 FIRST READING
## until
509 LAST READING

## send 'D'
## receive "28B9FE51000000DC 00,20.12,68.15"
## maybe some more sensors....
## then "EOD"

## RS232_OFF set to power on MAX chip
520 A = pioset 11;
521 A = uarton;
522 I = 499;
523 PRINTU "D"

526 $0[0] = 0;
527 TIMEOUTU 2;
528 INPUTU $0;
0 REM if we have an 'E' (69) end routine
529 IF $0[0] <> 69 THEN 534;

## got EOD, power off and return
530 A = pioclr 11;
531 A = uartoff;
## make message
532 GOSUB 550
533 RETURN

## timeout we give up
534 IF $0[0] = 0 THEN 530;


## see if we have a "2..." (50) start
## log data
535 IF $0[0] <> 50 THEN 526;

536 I = I + 1;
537 IF I > 509 THEN 526;
538 $I = $0[20];
539 $I[25] = 0;
## done, next line
540 GOTO 526;




## generate plugin content
## M = temp in Centigrades
550 $0="OWI|";
551 FOR A=0 TO I
552  PRINTV $I
553  PRINTV "|"
554 NEXT A
## store into history
555 GOSUB 660
556 RETURN


## additional initialization
990 ALARM 1
0 REM RS232 POWER ON out and on
991 A = pioout 3
992 A = pioset 3
0 REM RS232 POWER OFF out and OFF
993 A = pioout 11
994 A = pioclr 11
0 REM RS232 DTR pin out and +5V
995 A = pioclr 5
996 A = pioout 5
997 A = baud 96
998 RETURN
999

