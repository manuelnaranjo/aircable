@ERASE
#* 

Note:You need to use parser.py before uploading this 
to any AIRcable SMD. Don't forget to define $stream 
to a valid stream

this is the common code for both monitor
and interactive mode

DOCS NEEDS UPDATING

code structure:
*1/19	variables
*20/39	user code jump table
*40	automatic scrolling display
*60	@INIT
*105	@IDLE
*130	@SLAVE
*135 	@SENSOR
*150-9	inquiry results
*160	@INQUIRY
*170	@PIO_IRQ
*200	@ALARM

base code functions:
*205	settings menu handler
*400	nice reading shower
*410	turn off
*430	make visible
*440	enable deep sleep
*450	disable deep sleep
*460	battery reading show

user code is handled with pointers
we provide some base samples,
pointers starts at line 20.
pointers:
20 @INIT
21 @ALARM (user is responsible of calling 
 	ALARM for periodic readings)
22 @IDLE extra
30 sensor reading (for compatibility we
 	recommend this in the 500-599 range)
31 sensor displaying (for compatibility we
 	recommend this in the 500-599 range)
34 left long button press
35 middle long button press
36 right long button press
37 left short button press, call ALARM
38 middle short button press, call ALARM
39 right short button press, call ALARM

*#
##---------------------------------------------
##global variables
##persistance variables
##
##PIO LIST
##this is a simple way to choose pios,
##A = 1, B = 2, C = 3
##Order:
##left button
##middle button
##rigth button
##green led
##blue led
##deep sleep pio
1 DLCIT@


## lcd contrast
2 180
## display name
3 AIRcable
## discoverable name
4 AIRsensorSDK
## peer address
5 RES
## pio handler, filled by @INIT
6 X
## battery reading
7 0000
## lcd content
8 RES
## version number
9 SDK_0_1_1
## sensor code should store message info in $10
10 0000|0000
## sensor code should store display info in $11
11 READING
## pioirq
12 P000000000000000
## sensor reading
13 RES
## pio reading
14 RES
## address filter
15 0050C2
## message rate in seconds (not very precise)
16 1
## debug
17 0
## uniq
18 RES
## WAIT . . . (used lots of times)
19 "WAIT

## ----------------------------------------
#*
non persistance variables
Y = lcd contrast
X = sensor reading rate
W = button state
V = message interval
U = counter accumulator
T = pioirq flag T = 1 means no irq
S = inquiry shift
R = inquiry counter
Q = status
P = @SENSOR flag
O to N reserved for 'user' sensor code

-----------------------------------------
*#
## interrupt inputs
## user @INIT pointer
20 RETURN
## user @ALARM pointer
21 RETURN
## user @IDLE
22 RETURN
## sensor reading
30 RETURN
## sensor display
31 RETURN
## left long button press
34 RETURN
## middle long button press
35 RETURN
## right long button press
36 RETURN
## left short button press
37 RETURN
## middle short button press 
38 RETURN
## right short button press
39 RETURN

## display and scroll
## you can pass variable E
## to tell how many times you want
## to scroll. If you do then start at line 41
## otherwise call line 40
40 E = 2
41 B = strlen $8
42 $0 = $8;
43 PRINTV"                        ";
44 $8 = $0;
45 IF E = 0 THEN 55;
46 IF B <= 9 THEN 55
47 A = lcd $8
49 WAIT 1
50 FOR D = 0 TO E
51 FOR C = 0 TO B-8
52 A = lcd $8[C]
53 NEXT C
54 NEXT D

55 A = lcd $8
56 RETURN


## initializate the device
@INIT 60
60 A = baud 1152
61 Z = $17[0]-48
## enable lcd
62 Y = atoi $2
63 IF Y > 260 THEN 66
64 IF Y < 0 THEN 66
65 GOTO 70
66 Y = 200
67 $0[0] = 0
68 PRINTV Y 
69 $0 = $6
## LCD bias
70 A = auxdac Y
## show welcome message
71 $8 = $3
72 GOSUB 40
## setup friendly name
73 A = getuniq $8
74 $0 = $4
75 PRINTV " "
76 PRINTV $8
77 A = name $0
## led setting, green on, blue off
78 A = pioout ($1[3]-64)
79 A = pioset ($1[3]-64)
80 A = pioout ($1[4]-64)
81 A = pioclr ($1[4]-64)
## set up buttons:
## left
82 A = pioset ($1[0]-64)
83 A = pioin  ($1[0]-64) 
## right
84 A = pioset ($1[2]-64)
85 A = pioin  ($1[2]-64)
## middle
86 A = pioclr ($1[1]-64)
87 A = pioin  ($1[1]-64)

## show version number
88 $8 = $9
89 GOSUB 40
## start counters
90 A = zerocnt
91 U = 0
## read message rate
92 V = atoi $16
## mark we're botting
93 Q = 100
94 P = 1
95 T = 0
## 0 REM 96 A = pioout $1[5]
## 0 REM 97 A = pioclr $1[5]

## init pioirq string
98 IF $6[0]=80 THEN 20;
99 $0="P0000000000000000000"
100 FOR B = 0 TO 2
101 C=$1[B]-64
102 IF C = 0 THEN 104
103 $0[C]=49
104 NEXT B
105 $6=$0
106 PRINTU $6
107 GOTO 20;

## idle handler
@IDLE 110
110 IF Q = 100 THEN 120
111 A = disable 3
112 IF Q > 0 THEN 22
113 ALARM 1
114 GOTO 22

## first boot, visible for 30 seconds
## trigger sensor
120 P = 1
121 A = nextsns 1
122 A = slave 30
123 P = 1
124 A = pioirq $6
125 RETURN

## @SLAVE enable shell
## THIS IS NOT SECURE!!! 
## don't use this in production
@SLAVE 130
130 A = pioset($1[4]-64);
131 A = shell;
132 RETURN

## AIO0 and AIO1 reading
@SENSOR 135
135 IF P > 0 THEN 141;
## we need to wait until @SENSOR
## is called for the second time
136 A = sensor $13;
137 $7 = $13;
138 $7[4] = 0;
139 IF Q = 100 THEN 143
140 RETURN;

## wait for both readings
141 P = P - 1;
142 RETURN;

## we're booting, let's display reading
143 Q = 0
144 GOTO 400 

## we need this so free line calculator can do it's job.
148 CANCEL
149 UNPAIR
150 RESULTS
151 RESULTS
152 RESULTS
153 RESULTS
154 RESULTS
155 RESULTS
156 RESULTS
157 RESULTS
158 RESULTS
159 RESULTS

## 150 RESULTS
## ...
## 159 RESULTS
## inquiry results
@INQUIRY 160
## we can store as much as 10 results
160 IF R >= 10 THEN 168;
## check filter
161 A= strcmp $15;
162 IF A <> 0 THEN 168;
## passed, might be a target
163 \$(150+R) = $0; 
## we need to tell Cheetah not to parse $
164 R=R+1;
165 $0=$359;
166 PRINTV R;
167 A = lcd $0
168 RETURN

## stores PIO
169 RESERVED


## PIO interrupts
@PIO_IRQ 170
170 $169=$0;
## check for long button press flag
171 IF T = 1 THEN 178;
## button press while in settings menu?
172 IF Q > 100 THEN 260;
## 173 is free, you code can hack here.
## button press starts long button recognition
174 IF$169[$1[0]-64]=48THEN180;
175 IF$169[$1[1]-64]=49THEN180;
176 IF$169[$1[2]-64]=48THEN180;
## was it a release for a short press?
177 IF W <> 0 THEN 184;
178 RETURN

## this was a new press
180 $14 = $169;
181 W = 1;
182 ALARM 3;
183 RETURN


## button released for a short press
184 W = 0;
185 ALARM 0
## hack point lines 186, 187
## left button
188 IF$14[$1[0]-64]=48THEN37;
## middle button
189 IF$14[$1[1]-64]=49THEN38;
## right button
190 IF$14[$1[2]-64]=48THEN39;
191 RETURN

## long button press, called by @ALARM
192 W = 0;
## hack point line 193,194
## long left
195 IF$14[$1[0]-64]=48THEN34;
## long middle
196 IF$14[$1[1]-64]=49THEN35;
## long right
197 IF$14[$1[2]-64]=48THEN36;
## shouldn't get here
198 ALARM 5
199 RETURN


## ALARM handler
@ALARM 230

## settings menu running?
230 IF Q > 100 THEN 250;

## check for long button press
231 IF W <> 0 THEN 192;

## no more to do on vanilla code we call user code
232 GOTO 21;


## settings menu handler
## menu prepare
235 Q = 240
236 GOTO 250

##  options to show
240 ADDRESS
241 PEER
242 CONTRAST
243 RATE
244 INQUIRY
245 EXIT

250 IF Q = 520 THEN 255;
251 A = pioirq $6;
252 $8=\$Q;
253 T = 0;
254 GOTO 40

255 A = pioirq $6;
256 T = 0;
257 GOTO 384;

## menu button manager
260 ALARM 0;
261 IF Q = 500 THEN 327;
262 IF Q = 510 THEN 335;
263 IF Q = 520 THEN 370;
264 can be hacked to add more entry levels
265 IF$169[$1[0]-64]=48THEN269;
266 IF$169[$1[1]-64]=49THEN280;
267 IF$169[$1[2]-64]=48THEN274;
268 RETURN

## decrease
269 IF Q < 241 THEN 272;
270 Q = Q - 1;
271 GOTO 250;

## you should modify this line to add more
## entries
272 Q = 245;
273 GOTO 250;

## increase
## modify this line if you add more entries
274 IF Q > 244 THEN 277;
275 Q = Q + 1;
276 GOTO 250;

277 Q = 240;
278 GOTO 250;

## option selected
## self address
280 IF Q = 240 THEN 294;
## peer address
281 IF Q = 241 THEN 298;
## contrast
282 IF Q = 242 THEN 325;
## message rate
283 IF Q = 243 THEN 330;
## inquiry
284 IF Q = 244 THEN 360;
## exit
285 IF Q = 245 THEN 355;
## you can add more options here.
286 A = lcd"MENU ERROR"
287 RETURN

## show own address
294 A = getaddr $8;
295 GOSUB 40;
296 WAIT 3
297 GOTO 250

## show peer address
298 A = strlen $5;
299 IF A < 12 THEN 303; 
300 $8=$5;
301 GOSUB 40;
302 GOTO 296

303 $8="NO PAIR";
304 GOTO 301

## contrast handler
305 $0="TEST "
306 PRINTV Y;
307 PRINTV"    "
308 A = auxdac Y;
309 A = lcd $0;
310 Q = 500 ;
311 RETURN
##
312 IF$169[$1[0]-64]=48THEN324;
313 IF$169[$1[1]-64]=49THEN327;
314 IF$169[$1[2]-64]=48THEN326;
315 RETURN

316 IF Y > 260 THEN 325;
317 Y = Y + 10;
318 GOTO 325;

319 IF Y < 160 THEN 325;
320 Y = Y - 10;
321 GOTO 325;

322 Q = 290;
323 $0[0]=0;
324 PRINTV Y;
325 $2 = $0;
326 ALARM 1;
327 RETURN

## rate setting
330 $0="SEGS ";
331 PRINTV V;
332 $8=$0
333 Q = 510;
334 GOTO 40

335 IF$169[$1[0]-64]=48THEN342;
336 IF$169[$1[1]-64]=49THEN347;
337 IF$169[$1[2]-64]=48THEN340;
338 RETURN

340 V = V + 10;
341 GOTO 330;

342 IF V < 0 THEN 345;
343 V = V - 10;
344 GOTO 330;

345 V = 0;
346 GOTO 330;

347 Q = 210;
348 $0[0]=0;
349 PRINTV V;
350 $16 = $0;
351 ALARM 1;
352 RETURN

## exit handler
355 Q = 0;
356 A=lcd"BYE       "
357 ALARM 1
358 RETURN

359 RESERVED
## inquiry handler
360 $359="FOUND "
361 R = 0;
362 Q = 520;
363 S = 0;
364 A = lcd "SCAN . . . ";
365 T = 1;
366 A = pioirq $12;
367 A = inquiry 9;
368 ALARM 30;
369 RETURN

## inquiry button handler
370 IF$169[$1[0]-64]=48THEN374;
371 IF$169[$1[1]-64]=49THEN386;
372 IF$169[$1[2]-64]=48THEN379;
373 RETURN

## left handler shows previous result
374 IF S = 0 THEN 377;
375 S = S - 1;
376 GOTO 384;

377 S = R+1;
378 GOTO 384;

## right handler shows next result
379 IF S >= R+1 THEN 382;
380 S = S + 1;
381 GOTO 384;

382 S = 0;
383 GOTO 384;

## show on screen
384 $8=\$(148+S);
385 GOTO 40 

## middle is option chooser
386 IF S < 2 THEN 392;
387 $5 = \$(148+S);
388 Q = 210;
389 A = lcd"DONE         "
390 ALARM 3;
391 RETURN

## cancel or unpair?
392 IF S = 0 THEN 388;
## unpair
393 $5 = "";
394 GOTO 388;


## same base functions --------------------------------
## nice sensor reading displayer, useful when 
## you want to update the reading and let the
## user know what you're doing (for example
## after an update button press).
400 A = lcd "WAIT . . . "
401 GOSUB 30
402 GOSUB 31
403 $8=$11
404 GOSUB 40
405 ALARM 15
406 RETURN

## turn off
410 A = lcd "GOOD BYE";
411 ALARM 0;
412 A = pioset($1[3]-64)
413 A = pioclr($1[3]-64);
414 A = pioget($1[1]-64);
415 IF A = 1 THEN 412;
416 A = pioclr($1[4]-64);
417 A = lcd;
418 A = reboot;
419 FOR E = 0 TO 10;
420   WAIT 1
421 NEXT E;
422 RETURN

## make it visible, enable services
430 A = lcd "VISIBLE  "
431 A = slave 120
432 ALARM 140
433 A = enable 3
434 RETURN

## enable deep sleep
440 A = auxdac 0
441 A = pioset $1[5]
## make sure that nothing happens between enabling deep
## sleep and RETURN
442 A = uartoff;
443 RETURN;

## disable deep sleep
450 A = auxdac N
451 A = pioclr $1[5]
452 RETURN

## display battery reading
460 ALARM 20
461 $0 = "BATT "
462 PRINTV $7
463 $8=$0
464 GOTO 41

469 RESERVED
## send contents from opened file over
## $stream channel
470 A = seek 0;
471 A = read 32;
472 IF A = 0 THEN 480;
473 $PRINT($stream) $0;
474 $PRINT($stream)"\n";
475 $TIMEOUT($stream) 10;
476 $INPUT($stream) $0;
477 A = strcmp "GO";
478 IF A = 0 THEN 471;
479 GOTO 475;

480 WAIT 5;
481 PRINTM"DONE\n";
482 RETURN

