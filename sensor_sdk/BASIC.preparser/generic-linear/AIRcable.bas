#*
sample: generic linear sensor handler
 
any generic linear sensor can be attached
to one of the analog inputs. SensorSDK will
store reading at $13, we need to store
message information on $10 and display stuff
on line $11.

This code can handle generic sensors whose
output is like VAL = mV / SLOPE + OFFSET

We call this mode Linear-A

Linear-B mode is VAL = mv * SLOPE + OFFSET

reading update handler starts at line 510
reading display handler needs to start at
line 595
*#

## type
19 MONITOR-GENERIC-LINEAR

## set our interrupt points
30 GOTO 510;
31 GOTO 595;

## over ride a few lines
941 IF U-V>=300 THEN 944;
942 IF V>=U THEN 944;
943 GOTO 910;
944 V=U;

## $500 stores our mode
## $501 stores our slope
## $502 stores our offset

## for the TC1047
## we have: Vo=10mV/C * T + 500mV
## or: T = Vo / 10 - 50
## where Vo is in mV
## conversion formula
500 A
501 10
502 -50

## we'll store reading in $509
509 READING


## update reading.
510 $509 = $13[5];
511 $509[4] = 0;
512 M = atoi $509;
513 A = atoi $501;
514 B = atoi $502;
515 IF $500[0]=66THEN 518;
516 M=M/A+B
517 GOTO 519;
518 M=M*A+B
519 PRINTV"NEXT
520 GOSUB 660
521 $0="LIN|"
522 PRINTV$509
523 FOR A=500 TO 502
524 PRINTV"|"
525 PRINTV \$A
526 NEXT A
527 $10=$0
528 $0=""
529 RETURN

## display value generator
595 $0="LIN "
596 PRINTV M
597 PRINTV "%C"
598 $11 = $0
599 RETURN
