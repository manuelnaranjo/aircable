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

J = pool temp voltage
H = tank temp voltage

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
4 AIRpool
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
941 IF U-V>300 THEN 943;
942 GOTO 910;

943 V=U;

## type
19 MONITOR-POOL

## set our sensor reading routines
30 GOTO 503;
## display value generator
31 GOTO 551;

##we handle history pushing
10 NEXT


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
## H variable has PANEL temp
519 H = M;

520 R = 0;
521 T = 1;
522 $501[0] = 144;
## command read AIN1, 12bit, gain 1: 0xF0 = 240
523 $501[1] = 240
524 A = i2c $501
525 GOSUB 843;
## J variable has POOL temp
526 J = M;



## all variables are defined generate
## plugin content
527 GOSUB 700;
528 GOTO 540;


## make decisions what do to
## PANEL (H) higher than POOL (J) temp switch on PUMP
## this is voltage, lower than higher temp

## we measure about 15.1mV/C between 6C and 66C
## offset 0C
540 B = J;
541 IF H < B THEN 544;
## OFF
542 A = pioclr ($1[3]-64);
543 RETURN
## ON
544 A = pioset ($1[3]-64);
545 RETURN

## END OF SENSOR READING



## DISPLAY VALUE GENERATOR
551 IF I > 0 THEN 558;
552 $0 = "PNL "
553 N = H;
## convert into C
554 GOSUB 810;
555 $11 = $0;
556 I = 1;
557 RETURN

## 2nd display is pool temp
558 IF I > 1 THEN 573;
559 $0 = "WTR "
560 N = J;
561 GOSUB 810;
562 $11 = $0;
563 I = 2;
564 RETURN


## 3rd display show generated solar energy
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
581 I = 0;
582 RETURN



## 600 lines are for SLAVE

## 700 generate plugin content
## M = solar temp voltage
## J = pool temp voltage
## H = tank temp voltage
## G = flow sensor voltage
## F = watt minutes
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
## GPM is fixed at 1.0 GPM
## GPM * 900 * dC = BTU/h
830 N = 850
## now we have GPM*1000
831 N = (N * 9) / 10;

## temp diff
## PANEL-POOL
832 B = J - H;
833 IF B < 0 THEN 835
834 GOTO 836;
835 B = 0

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

