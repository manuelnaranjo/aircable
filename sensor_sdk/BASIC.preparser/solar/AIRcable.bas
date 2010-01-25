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

## adjust sensor reading freq to 3 sec
908 GOTO 930;
910 ALARM 3;
## adjust long button press to 2 secs
182 ALARM 2;

## commit each 5 minutes
## or in clock overflow
941 IF U-V>=300 THEN 944;
942 IF V>=U THEN 944;
943 GOTO 910;
944 V=U;

## type
19 MONITOR-SOLAR

## set our sensor reading routines
30 GOTO 503;
## display value generator
31 GOTO 551;

##we handle history pushing
10 NEXT
##disable some code lines
939 REM
940 REM


## we'll store reading in $500
500 READING
501 I2CSEND
502 WATTSECONDS

## update sensor reading.
## AIO1 voltage is in $13[5]
503 $500 = $13[5]
504 $500[4] = 0
505 G = atoi $500

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
## read values of ADC
518 GOSUB 843;
## H variable has TANK temp, correction -5C (should be +2C)
519 H = M + 15;

520 R = 0;
521 T = 1;
522 $501[0] = 144;
## command read AIN1, 12bit, gain 1: 0xF0 = 240
523 $501[1] = 240
524 A = i2c $501
525 GOSUB 843;
## J variable has POOL temp, correct2d -3C (should be +2C)
526 J = M - 15;

527 R = 0;
528 T = 1;
529 $501[0] = 144;
## command read AIN2, 12bit, gain 1: 0xB0 = 176
530 $501[1] = 176;
531 A = i2c $501
532 GOSUB 843;
## M variable has SOLAR temp

## solar correction +2C (correct)
## we measure 15.1mV / C
533 M = M - 15;

## all variables are defined generate
## plugin content
534 GOSUB 700;

## first check FREEZING, over 1551mV is under 0C
535 IF M < 1560 THEN 540;
## FREEZE, switch on PUMP and sound alarm
536 A = pioset ($1[3]-64);
537 A = ring;
538 A = lcd " FREEZE "
## return here for end of sensor reading
539 RETURN

## make decisions what do to
## SOLAR (M) higher than POOL (J) temp switch on PUMP
## this is voltage, lower than higher temp

## we measure about 15.1mV/C between 6C and 66C
## offset 0C
540 B = J;
541 IF M < B THEN 544;
## OFF
542 A = pioclr ($1[3]-64);
543 RETURN
## ON
544 A = pioset ($1[3]-64);
545 RETURN

## END OF SENSOR READING



## DISPLAY VALUE GENERATOR
551 IF I > 0 THEN 558;
552 $0 = "TNK "
553 N = H;
## convert into C
554 GOSUB 810;
555 $11 = $0;
556 I = 1;
557 RETURN

## 2nd display is pool temp
558 IF I > 1 THEN 565;
559 $0 = "POL "
560 N = J;
561 GOSUB 810;
562 $11 = $0;
563 I = 2;
564 RETURN

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

576 $0="P "
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


## 5th display if heating pool, tank(H)-pool(J)>3C (15.1mV/C)
591 IF (J-H-45) > 0 THEN 552;
## display energy that goes into the pool
592 N = G;
593 GOSUB 830;
594 $0="HT "
595 PRINTV N;
596 PRINTV "W  "
597 $11 = $0;
598 I = 0;
599 RETURN



## 600 lines are for SLAVE

## 700 generate plugin content
## M = solar temp voltage
## J = pool temp voltage
## H = tank temp voltage
## G = flow sensor voltage
## F = watt minutes
700 PRINTV"NEXT"
701 GOSUB 660
702 $0="SOL|";
703 PRINTV M;
704 PRINTV"|"
705 PRINTV J;
706 PRINTV"|"
707 PRINTV H;
708 PRINTV"|"
709 PRINTV G;
710 PRINTV"|"
711 PRINTV F;
712 PRINTV"|"
713 A=pioget11;
714 PRINTV A;
715 GOSUB 660
716 RETURN

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
## voltage to temperature
## R=4.7k, V=1.8V
## NOC is 10k @ 25C
## linearization with 4 lines
## >1470mV < 9C m=-0.1008   
## >590mV  <66C m=-0.0660
## >380mV  <86C m=-0.0966
## <380mV  >86C m=-0.1402

810 IF N > 1470 THEN 822
811 IF N > 590 THEN 819
812 IF N > 380 THEN 816
813 N = (N * 7) / 50
814 N = 140 - N
815 GOTO 824

816 N = (N * 54) / 559
817 N = 123 - N
818 GOTO 824

819 N = (N * 7) / 106
820 N = 105 - N
821 GOTO 824

822 N = N / 10
823 N = 156 - N

824 PRINTV N;
825 PRINTV"%C"
826 RETURN






## FLOW SENSOR calculation
## analog AIO1 to GPM, linear
## calculate BTU
## GPM is about 950mV for 0.7GPM
## GPM * 900 * dC = BTU/h
830 N = (N * 11) / 15;
## now we have GPM*1000
831 N = (N * 9) / 10;

## temp diff
832 IF I = 2 THEN 835;

## TANK-POOL
833 B = J - H;
834 GOTO 836;

## SOLAR-POOL diff
## 835 B = J - M;
## SOLAR-TANK diff
835 B = H - M;

## we measure 15.1mV per C between 6C and 66C
## dC = V * 7 / 106
836 B = (B * 7) / 106;
## flow times temp difference
837 N = N * B;
## from BTU/h to W = BTUH * 5 / 17
838 N = (N * 5) / 17;
839 RETURN




## SUBROUTINE read ADC value, i2c address 0x90 = 144
843 $501[0] = 144;
844 T = 0;
845 R = 3;
846 A = i2c $501
847 M = $0[0] * 256;
848 M = M + $0[1];
849 RETURN


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

