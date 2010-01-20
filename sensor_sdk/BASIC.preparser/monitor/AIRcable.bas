## MONITOR CODE --------------------------------
##
## this code uses message for interfacing the server.
##
## type of unit
19 MONITOR
## interrupt insertion point
## @INIT
20 GOTO 990;
## @ALARM pointer
21 GOTO 900;

#if $stream=="slave"
22 GOTO 955;
#end if

#*

LONG BUTTON PRESS HANDLER

long button press handler
long middle off
long left device menu
long right visible
we just calls functions from BASE code
*#
## left long button press edit menu
34 GOTO 235;
## middle long button press turn off
35 GOTO 410;
## right long button press make visible
36 GOTO 430;

#*
SHORT BUTTON PRESS HANDLER
middle button send message
left button press update reading
right button press battery reading
*#
## left short button press display batt level
37 GOTO 460;
## middle short button press send message if paired
38 GOTO 700;
## right short button press update reading
39 GOTO 400;


## message
700 A = strlen $5;
701 L = 1;
702 IF A > 11 THEN 930;
703 A = lcd"NOT PAIRED  "
704 ALARM 5
705 RETURN

#*
ALARM HANDLER
we might be sending a message
in such case we need to check for status
this avoids some blocks that might
happen because we don't let the processor
do it's work.
*#
#if $stream=="master"
900 IF O <> 0 THEN 955;
## check for status
901 A = status;
902 IF A < 10 THEN 905;
#else if $stream=="slave"
900 A = status
901 IF A = 1 THEN $SHELL
902 IF A = 0 THEN 905;
#end if

903 ALARM 5;
904 RETURN

## handle history storing
905 A = pioirq $12;
##906 GOSUB 761

## if we are in master mode check
## if we have stuff to sync
907 IF L > 0 THEN 930;

# time to do reading?
908 GOTO 930

## @alarm ended
## trigger again
910 ALARM 15;
911 A = pioirq $6;
## update reading
912 Q = 100
913 P = 1
914 A = nextsns 1;
915 RETURN

## prepare reading
930 A = lcd"READING     ";
931 $0[0] = 0;
932 PRINTV"BATT|";
933 PRINTV$7;
934 PRINTV"|SECS|"
935 GOSUB 485
936 PRINTV B
937 PRINTV"|";
938 GOSUB 30;
939 PRINTV $10;
## push to history
940 GOSUB 660

## is buffer complete?
941 IF L > 0 THEN 943;
942 IF B = 0 THEN 910;

#if $stream=="master"
## only send message when paired
943 A = strlen $5;
944 IF A < 12 THEN 910;
#end if

945 O = 1;
946 ALARM 5;
947 A = pioset ($1[4]-64);

#if $stream=="master"
## try to connect
948 A = master $5;
949 ALARM 5
950 RETURN

## timeout detection
955 A = pioclr ($1[4]-64);
956 A = lcd "TIMEOUT     ";
957 A = zerocnt;
958 WAIT 2
959 A = lcd $11;
960 O = 0;
961 GOTO 910;

#else if $stream=="slave"
## became visible
948 A = slave 60
949 ALARM 90
950 A = lcd "SPP OPEN"
951 RETURN

# slave timeout
955 A = pioclr ($1[4]-64);
956 WAIT 2
957 A = lcd $11;
958 O = 0;
959 GOTO 910;

#end if

## @INIT
990 ALARM 1;
991 RETURN

