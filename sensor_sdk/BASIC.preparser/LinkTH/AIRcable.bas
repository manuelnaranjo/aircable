
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

## implement history manually
10 REM
## clear up a few not needed lines
939 REM
940 REM


## interrupt insertion points
## extra @INIT
20 GOTO 990;


## BUTTON PRESS HANDLERS
## middle short button press 
38 GOTO 430;
## middle long button press turn off
35 GOTO 410;
## type
19 MONITOR-LINKTH
## set our sensor reading routines
30 GOTO 517;

137 $7=$13[5];


0 REM flush once each 20 readings
662 IF K>=20 THEN 665;

## adjust sensor reading freq to 3 sec
908 GOTO 930;
910 ALARM 3;

## commit each 5 minutes
941 IF U-V>300 THEN 943;
942 GOTO 910;

943 V=U;


## we'll store reading in $500
500 FIRST READING
## until
509 LAST READING

## send 'D'
## receive "28B9FE51000000DC 00,20.12,68.15"
## maybe some more sensors....
## then "EOD"

## store previous content
517 PRINTV"NEXT";
518 GOSUB 660
## RS232_OFF set to power on MAX chip
519 A = pioset 11;
520 A = uarton;
521 WAIT 1
522 REM;

523 $0[0] = 0;
524 PRINTU "D"
525 TIMEOUTU 3;
526 INPUTU $0;

## blink green
527 A = pioset ($1[3]-64);
528 A = pioclr ($1[3]-64);
0 REM if we have an 'E' (69) end routine
529 IF $0[0] <> 69 THEN 535;

## got EOD, power off and return
530 A = pioclr 11;
531 A = uartoff;
532 RETURN

## timeout we give up
535 IF $0[0] = 0 THEN 530;

## see if we have a "2..." (50) start
## if not, get next line
536 IF $0[0] <> 50 THEN 525;

## store each sensor reading in 2 variables
537 REM;
538 REM;
539 $0[16] = 0;
540 $500=$0;
541 $501=$0[17];

542 $0="OWI|"
543 PRINTV $500
## store fist line in history
544 GOSUB 660

545 $0="OWS|"
546 PRINTV $501
## store second line in history
547 GOSUB 660

## double blink green when done, next line
548 A = pioset ($1[3]-64);
549 A = pioclr ($1[3]-64);
550 A = pioset ($1[3]-64);
551 A = pioclr ($1[3]-64);
552 GOTO 525;


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

