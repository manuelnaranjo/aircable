@ERASE

0 REM Industrial XR pios
0 REM BLUE LED  A
0 REM GREEN LED 0
0 REM BUTTON 0
0 REM RS232 POWER OFF 5
0 REM RS232 POWER ON 4
0 REM DTR 6
0 REM DSR 4


1 RESERVED

0 REM $3 is the destiny address.
3 SOMETHING

@INIT 49
49 Z = 0
50 A = uarton
51 A = baud 1152

0 REM BLUE LED PIO
52 X = 10

53 A = getuniq
54 $1 = $0
55 $0 = "Smart Relay "
56 PRINTV $1
57 A = name $0

0 REM booting U = 1000
58 U = 1000
59 A = pioout X
60 A = pioclr X
61 RETURN

@IDLE 150
0 REM during boot we need 20 secs of visibility
150 IF U = 1000 THEN 155

0 REM make sure we're connectable, but not visible
151 A = slave -1000
152 ALARM 1
153 RETURN

0 REM visible for 20 secs
155 U = 0
156 A = slave 20
157 RETURN

@ALARM 200
200 IF U <> 0 THEN 450
0 REM blink a led to tell we're running
201 A = pioset X
202 A = pioclr X
203 A = slave -1000
204 ALARM 30
205 RETURN

0 REM not very secure
@PIN_CODE 250
250 $0="1234"
251 RETURN

@SLAVE 300
0 REM some security meassures, we don't want anyone
0 REM to reach us
300 A = getconn
301 A = strcmp $3
302 IF A = 0 THEN  310
303 A = disconnect 1
304 RETURN

310 A = pioset X
311 ALARM 0
312 A = shell
313 RETURN

0 REM here's where the magic takes place
@MESSAGE 400
400 A = status;
401 IF A = 0 THEN 404;
402 WAIT 10
403 GOTO 400;

404 $0 = $0[13]
405 A = message $3;
406 U = 1
407 ALARM 10
408 RETURN

450 A = pioset X;
451 WAIT 10
452 A = status
453 IF A <> 0 THEN 451
454 A = pioclr X;
455 U = 0
456 GOTO 201
