
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
30 GOTO 520;


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

## RS232_OFF set to power on MAX chip
520 A = pioset 11;
521 A = uarton;
522 I = 499;

## blink green
523 A = pioset ($1[3]-64);
524 A = pioclr ($1[3]-64);
525 $0[0] = 0;

526 PRINTU "D"
527 TIMEOUTU 3;
528 INPUTU $0;
0 REM if we have an 'E' (69) end routine
529 IF $0[0] <> 69 THEN 535;

## got EOD, power off and return
530 A = pioset 11;
531 A = uartoff;
## make message
533 GOSUB 550
534 RETURN

## timeout we give up
535 IF $0[0] = 0 THEN 530;

## see if we have a "2..." (50) start
## if not, get next line
536 IF $0[0] <> 50 THEN 527;

537 I = I + 1;
538 IF I > 509 THEN 527;
539 $(I) = $0[20];
540 $(I)[5] = 0;
## done, next line
541 GOTO 527;




## generate plugin content
## M = temp in Centigrades
550 IF I < 500 THEN 559
551 $0="OWI|";
552 FOR A=500 TO I
553  PRINTV $(A)
554  PRINTV "|"
555 NEXT A
## store into history
556 GOSUB 660
## double blink green when done
557 A = pioset ($1[3]-64);
558 A = pioclr ($1[3]-64);
559 A = pioset ($1[3]-64);
560 A = pioclr ($1[3]-64);
561 A = pioset ($1[3]-64);
562 A = pioclr ($1[3]-64);
563 RETURN


## additional initialization
990 ALARM 1
0 REM RS232 POWER ON out and on
991 A = pioout 3
992 A = pioset 3
0 REM RS232 POWER OFF out and OFF
993 A = pioout 11
994 A = pioset 11
0 REM RS232 DTR pin out and +5V
995 A = pioclr 5
996 A = pioout 5
997 A = baud 96
998 RETURN
999

