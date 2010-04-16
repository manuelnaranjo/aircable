#*
TC1047 demo code. This sensor is included as part of every
new SensorSDK kit. This code will store it's readings and
will display both mV reading and °C estimate.


SensorSDK will store reading at $13, we store
our reading information at $10 and we display 
on line $11

reading update handler starts at line 510
reading display handler needs to start at
line 595
*#

## type
19 MONITOR-GENERIC-LINEAR

## set our interrupt points
30 GOTO 510;
31 GOTO 530;

## over ride a few lines
941 IF U-V>=300 THEN 944;
942 IF V>=U THEN 944;
943 GOTO 910;
944 V=U;

## for the TC1047
## we have: Vo=10mV/C * T + 500mV
## or: T = Vo / 10 - 50
## where Vo is in mV

## we'll store reading in $509
509 READING


## update reading.
510 $509 = $13[5];
511 $509[4] = 0;
512 M = atoi $509;
513 M = (M/10)-50;
514 PRINTV"NEXT
515 GOSUB 660
516 $0="LIN|"
517 PRINTV$509
518 PRINTV"|A|10|-50"
519 $10=$0
520 $0=""
521 RETURN

## display value generator
530 $0[0]=0
531 PRINTV M
532 PRINTV"C "
533 PRINTV $509;
534 $0[8]=0
535 $11=$0
536 RETURN

