#*
sample: solar panel sensor handler
this sample shows how to do basic
sensor handling.
 
solar panel sensor is attached to one of
the analog inputs, so we need to use
information provided by the sdk regarding
sensor reading. That information is on $13.
SDK will expect us to store messaging
information on $10, and display stuff in
$11.
reading update handler starts at line 980
reading display handler needs to start at
line 990.

Variables used:
M = solar temp voltage
J = pool temp voltage
H = tank temp voltage
G = flow sensor voltage
F = watt minutes
X = seconds between readings
R, T for I2C command
I = display status
V stores the last commit time
*#

## interrupt insertion points
0 REM extra @INIT
20 GOTO 990;

## lcd contrast
2 200
4 AIRsolar
## remove the WAIT and READING on the display
400 REM
930 A = lcd ".

0 REM flush once each 20 readings
662 IFK>=20 THEN 665;

## adjust sensor reading freq to 2 sec
908 GOTO 930;
910 ALARM 2;

## commit each 5 minutes
941 IF U-V>300 THEN 943;
942 GOTO 910;

943 V=U;

## type
19 MONITOR-SOLAR

## set our sensor reading routines
30 GOTO 503;
## display value generator
31 GOTO 550;

#we handle history pusing
10 


## we'll store reading in $500
500 READING
501 I2CSEND
502 WATTSECONDS

## update sensor reading.
## AIO1 voltage is in $13[5]
503 $500 = $13[5]
504 $500[4] = 0
505 G = atoi $500
## calculate temp from voltage
506 REM M = (M - 520) * 2

510 A = pioout 5
511 A = pioset 5
## read I2C sensor, takes a while to reset
512 R = 0
513 T = 1
## address of first ADS1112 is 0x90 = 144
514 $501[0] = 144
## command read AIN0, 12bit, gain 1: 0xD0 = 208
515 $501[1] = 208;
## the ADS takes some time to startup
516 WAIT 1
517 A = i2c $501
518 GOSUB 544;
## H variable has TANK temp
519 H = M;

520 R = 0;
521 T = 1;
522 $501[0] = 144;
## command read AIN1, 12bit, gain 1: 0xF0 = 240
523 $501[1] = 240
524 A = i2c $501;
525 GOSUB 544;
## J variable has POOL temp
526 J = M;

527 R = 0;
528 T = 1;
529 $501[0] = 144;
## command read AIN2, 12bit, gain 1: 0xB0 = 176
530 $501[1] = 176;
531 A = i2c $501;
532 GOSUB 544;
## M variable has SOLAR temp

## solar correction +2C
533 REM M = M - 15;

## first check FREEZING, it's about 900mV
534 IF M < 900 THEN 538;
## FREEZE, switch on PUMP and sound alarm
535 A = pioset ($1[3]-64);
536 A = ring;
537 A = lcd " FREEZE "

## all variables are defined generate
## plugin content
538 GOSUB 700;

## make decisions what do to
## SOLAR (M) higher than POOL (J) temp switch on PUMP
## this is voltage, lower than higher temp

## we measure about 9mV/C
## offset 2C
539 B = J - 18;
540 IF M < B THEN 543;
## OFF
541 A = pioclr ($1[3]-64);
542 RETURN
## ON
543 A = pioset ($1[3]-64);
544 RETURN

## END OF SENSOR READING


## SUBROUTINE read ADC value, i2c address 0x90 = 144
544 $501[0] = 144;
544 T = 0;
545 R = 3;
546 A = i2c $501
547 M = $0[0] * 256;
548 M = M + $0[1];
549 RETURN



## DISPLAY VALUE GENERATOR
550 IF I > 0 THEN 557;
551 $0 = "TNK "
552 N = H;
553 GOSUB 810;
554 $11 = $0;
555 I = 1;
556 RETURN

## 2nd display is pool temp
557 IF I > 1 THEN 565;
558 $0 = "POL "
559 N = J;
560 GOSUB 810;
561 $11 = $0;
562 I = 2;
563 RETURN

## 3rd display is solar temp
565 IF I > 2 THEN 572;
566 $0 = "SOL "
567 N = M;
568 GOSUB 810;
569 $11 = $0;
570 I = 3;
571 RETURN

## 3rd display show generated solar energy
572 IF I > 3 THEN 583;
573 N = G;
## calculate watts (or BTU)
574 GOSUB 830;
## add energy up in watt minutes
575 GOSUB 859;

576 $0="PWR "
577 PRINTV N;
578 PRINTV "W "
579 REM PRINTV "BTUh"
580 $11 = $0;
581 I = 4;
582 RETURN

## 4th display watt minutes collected
583 IF I > 4 THEN 591;
584 $0="E "
585 B = F / 6;
586 PRINTV B;
587 PRINTV "Wh"
588 $11 = $0;
589 I = 5;
590 RETURN


## 5th display if heating pool, tank(H)-pool(J)>2C
591 IF (J-H-18) > 0 THEN 551;
## display energy that goes into the pool
592 N = G;
593 GOSUB 830;
594 $0="HT "
595 PRINTV N;
596 PRINTV "W  "
597 $11 = $0;
598 I = 0;
599 RETURN



## 600 lines for SLAVE

## 700 generate plugin content
## M = solar temp voltage
## J = pool temp voltage
## H = tank temp voltage
## G = flow sensor voltage
## F = watt minutes

## 700 lines for some other code...
700 $0="SOL|";
701 PRINTV M;
702 PRINTV"|"
703 PRINTV J;
704 PRINTV"|"
705 PRINTV H;
706 PRINTV"|"
707 PRINTV G;
708 PRINTV"|"
709 PRINTV F;
710 PRINTV"|"
711 A=pioget11;
712 PRINTV A;
713 GOSUB 660
714 RETURN

## FLOW SENSOR calculation
## analog AIO1 to GPM, linear
## flow sensor voltage put into variable N
800 $0="0."
801 N = N * 11;
802 N = N / 15;
803 IF N < 1000 THEN 806;
804 $0="1."
805 N = N-1000;

806 PRINTV N;
807 PRINTV " GPM"
808 RETURN



## NTC value calculation
810 N = 1800 - N
0 REM we have 3 areas of
0 REM approximation
811 IF N < 1500 THEN 825;
812 IF N < 1700 THEN 820;

0 REM 1700-1800 mV
0 REM m=0.548442, h=-871.946
813 N = (N-1700)*54
814 N = N/100
815 N = N + 71

816 PRINTV N
817 PRINTV "%C"
818 RETURN

0 REM 1500-1700
0 REM m = 0.131759 h = -160.323
820 N = (N-1500)*13
821 N = N/100
822 N = N+42
823 GOTO 816

0 REM 0-1500
0 REM m = 0.0572798 h = -48.6986
825 N = N * 6
826 N = N / 100
827 N = N - 49
828 GOTO 816


## FLOW SENSOR calculation
## analog AIO1 to GPM, linear
## calculate BTU
## GPM is about 950mV for 0.7GPM
## GPM * 900 * dC = BTU/h
830 N = N * 11;
831 N = N / 15;
## now we have GPM*100
832 N = N * 9;
833 N = N / 10;
## temp diff
## may be either SOLAR-POOL
834 IF I = 2 THEN 837;
## TANK-POOL
835 B = J-H;
836 GOTO 838;
## SOLAR-POOL diff
837 B=J-M;

## we measure about 9mV per C
838 B = B / 9;
## correction for loss, 2C
839 B = B - 2;
840 N = N * B;
## from BTU/h to W = BTUH * 5 / 17
841 N = N * 5;
842 N = N / 17;
843 RETURN


## data logging, calculate watt hours and add up
## set to zero every night
858  NIGHT COUNTER
## U holds the amount of elapsed seconds
## X has the last reading time, determine seconds
859 B = U;
860 C = B - X;
861 X = U;

862 IF C < 0 THEN 867;
863 IF C > 100 THEN 867;
864 IF N < 0 THEN 867;
865 B = ( C * N ) / 600;
866 F = F + B;

## find out if it is night
867 A = pioget 11;
868 IF A = 1 THEN 877;

## it is night, add up counter
869 $0 = "NIGHT"
870 PRINTV $858[0]
871 A = lcd $0
872 $858[0] = $858[0] + 1;
873 IF $858[0] < 100 THEN 876;
## long enough no power 2h, so it must be night, reset
874 F = 0;
875 $858[0] = 100;
876 RETURN

## it is day
877 $0 = "DAY "
878 PRINTV $858[0]
879 A = lcd $0
880 $858[0] = $858[0] - 1;
881 IF $858[0] > 0 THEN 883;

## reset counter
882 $858[0] = 0;
883 RETURN
## can only use lines up to 899

## additional initialization
990 ALARM 1
991 F = 0;
992 X = 0;
993 $858[0] = 0;
994 V = 0
995 RETURN

