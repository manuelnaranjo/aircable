#*
This code will get a message and put the
conent on the screen
*#

## TODO: Check if this code still works
## 	could be broken

## serial3 pio list 
1 @L@IT

## name
4 AIRSensorSDK-Receiver

## pio handler
6 P000000000001

## message rate: never send messages
9 -1

## we need our own @IDLE
@IDLE 1000
1000 IF Q = 100 THEN 1010
1001 A = slave -120
1002 ALARM 1
1003 RETURN

## first boot, update display
## visible for 30 seconds
## don't message
1010 A = lcd "WAIT . . . "
1011 GOSUB 30
1012 GOSUB 31
1013 $8=$11
1014 GOSUB 40
1015 P = 1
1016 A = nextsns 1
1017 A = slave 30
1018 Q = 0
1019 P = 1
1020 A = pioirq $6
1021 RETURN

@MESSAGE 950
950 WAIT 1
951 A = lcd $0
952 RETURN 
