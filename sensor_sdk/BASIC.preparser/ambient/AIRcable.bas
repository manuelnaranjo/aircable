#* 
sample: ambient sensor handler
this sample shows how to do basic
sensor handling.
 
ambient sensor is attached to one of
the analog inputs, so we need to use
information provided by the sdk regarding
sensor reading. That information is on $13.
SDK will expect us to store messaging
information on $10, and display stuff in
$11.
reading update handler starts at line 980
reading display handler needs to start at
line 990.
*#

## type
19 MONITOR-AMBIENT

## set our interrupt points
30 GOTO 500;
31 GOTO 520;


## we'll store reading in $508
508 READING

## update reading.
500 $508 = $13[5]
501 $508[4] = 0
502 M = atoi $508
503 M = (M - 520) * 2
504 $0 = "TAMB|
505 PRINTV$508
506 $10 = $0
507 RETURN

## display value generator
520 $0="AMB "
521 N = M / 20
522 PRINTV N
523 PRINTV "%C"
524 $11 = $0
525 RETURN
