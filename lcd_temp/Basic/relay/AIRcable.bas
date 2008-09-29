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

0 REM $2 is used for PIO

0 REM $3 is the destiny address.
3 SOMETHING

0 REM $4 is PIO for button
4 P000000000001

@INIT 48
48 Z = 0
49 A = uarton
50 A = baud 1152

0 REM BLUE LED PIO
51 X = 10

0 REM middle button PIO
52 Y = 12

53 A = getuniq
54 $1 = $0
55 $0 = "Smart Relay "
56 PRINTV $1
57 A = name $0

0 REM booting U = 1000
58 U = 1000
59 A = pioout X
60 A = pioclr X

0 REM RS232 POWER ON out and on
62 A = pioout 3
63 A = pioset 3
0 REM RS232 POWER OFF out and on
64 A = pioout 10
65 A = pioset 10
0 REM RS232 DTR pin out and on
66 A = pioset 5
67 A = pioout 5
0 REM PIO12 goes high when pressed, add 
68 A = pioclr Y
69 A = pioin Y

0 REM check for button
70 A = pioirq $4
71 W = 0
72 RETURN

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
200 IF W = 1 THEN 220
201 IF U <> 0 THEN 450
0 REM blink a led to tell we're running
202 A = pioset X
203 A = pioclr X
204 A = slave -1000
205 ALARM 30
206 RETURN

220 A = pioget Y
221 IF A = 0 THEN 201

0 REM long button press, time to shutdown
222 ALARM 0
223 A = pioset X;
224 A = pioclr X
225 A = pioget Y;
226 IF A = 1 THEN 223
227 A = reboot
228 FOR B = 0 TO 10
229 WAIT 1
230 NEXT E
231 RETURN

0 REM not very secure
@PIN_CODE 290
290 $0="1234"
291 RETURN

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

@PIO_IRQ 500
500 IF $0[Y]=49 THEN 510;
501 RETURN

0 REM button press, save state, start ALARM
510 $2 = $0;
511 W = 1;
512 ALARM 3
513 RETURN



