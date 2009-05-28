@ERASE

0 REM this is the common code for both monitor
0 REM and interactive mode

0 REM DOCS NEEDS UPDATING

0 REM code structure:
0 REM 1/19   variables
0 REM 20/39 user code jump table
0 REM 40      automatic scrolling display
0 REM @INIT 60
0 REM @IDLE 105
0 REM @SLAVE 130
0 REM @SENSOR 135
0 REM inquiry results from 150 to 159
0 REM @INQUIRY 160
0 REM @PIO_IRQ 170
0 REM @ALARM 200

0 REM base code functions
0 REM settings menu handler 205
0 REM nice reading shower 400
0 REM turn off 410
0 REM make visible 430
0 REM enable deep sleep 440
0 REM disable deep sleep 450
0 REM battery reading show 460

0 REM user code is handled with pointers
0 REM we provide some base samples,
0 REM pointers starts at line 20.
0 REM 
0 REM pointers:
0 REM 20 @INIT
0 REM 21 @ALARM (user is responsible of calling 
0 REM 	ALARM for periodic readings)
0 REM 22 @IDLE extra
0 REM 30 sensor reading (for compatibility we
0 REM 	recommend this in the 500-599 range)
0 REM 31 sensor displaying (for compatibility we
0 REM 	recommend this in the 500-599 range)
0 REM 34 left long button press
0 REM 35 middle long button press
0 REM 36 right long button press
0 REM 37 left short button press, call ALARM
0 REM 38 middle short button press, call ALARM
0 REM 39 right short button press, call ALARM

0 REM global variables      -------------------------
0 REM persistance variables -------------------------
0 REM PIO LIST
0 REM this is a simple way to choose pios,
0 REM A = 1, B = 2, C = 3

0 REM left button
0 REM middle button
0 REM rigth button
0 REM green ledF
0 REM blue led
0 REM deep sleep pio
1 DLCIT@

0 REM lcd contrast
2 180

0 REM display name
3 AIRcable

0 REM discoverable name
4 AIRsensorSDK

0 REM peer address
5 RES

0 REM pio handler, filled by @INIT
6 X

0 REM battery reading
7 0000

0 REM 8 lcd content
8 RES

0 REM version number
9 SDK_0_1_1

0 REM sensor code should store message info in
0 REM $10
10 0000|0000

0 REM sensor code should store display info in
0 REM $11
11 READING

0 REM no pioirq
12 P000000000000000

0 REM sensor reading
13 RES

0 REM pio reading
14 RES

0 REM address filter
15 0050C2

0 REM message rate in seconds (not very precise)
16 1

0 REM debug
17 0

0 REM uniq
18 RES

0 REM WAIT . . . (used lots of times)
19 "WAIT


0 REM non persistance variables -----------------------
0 REM Y = lcd contrast
0 REM X = sensor reading rate
0 REM W = button state
0 REM V = message interval
0 REM U = counter accumulator
0 REM T = pioirq flag T = 1 means no irq
0 REM S = inquiry shift
0 REM R = inquiry counter
0 REM Q = status
0 REM P = @SENSOR flag
0 REM O to N reserved for 'user' sensor code

0 REM END global variables -----------------------------

0 REM interrupt inputs

0 REM user @INIT pointer
20 RETURN

0 REM user @ALARM pointer
21 GOTO 760;

0 REM user @IDLE
22 RETURN

0 REM sensor reading
30 RETURN

0 REM sensor display
31 RETURN

0 REM left long button press
34 GOTO 700;

0 REM middle long button press
35 GOTO 710;

0 REM right long button press
36 GOTO 720;

0 REM left short button press
37 GOTO 730;

0 REM middle short button press 
38 GOTO 740;

0 REM right short button press
39 GOTO 750;

0 REM display and scroll
0 REM you can pass variable E
0 REM to tell how many times you want
0 REM to scroll. If you do then start at line 41
0 REM otherwise call line 40
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

0 REM initializate the device
@INIT 60
60 A = baud 1152
61 Z = $17[0]-48

0 REM enable lcd
62 Y = atoi $2
63 IF Y > 260 THEN 66
64 IF Y < 0 THEN 66
65 GOTO 70
66 Y = 200
67 $0[0] = 0
68 PRINTV Y 
69 $0 = $6
0 REM LCD bias
70 A = auxdac Y

0 REM show welcome message
71 $8 = $3
72 GOSUB 40

0 REM setup friendly name
73 A = getuniq $8
74 $0 = $4
75 PRINTV " "
76 PRINTV $8
77 A = name $0

0 REM led setting, green on, blue off
78 A = pioout ($1[3]-64)
79 A = pioset ($1[3]-64)
80 A = pioout ($1[4]-64)
81 A = pioclr ($1[4]-64)

0 REM set up buttons
0 REM left
82 A = pioset ($1[0]-64)
83 A = pioin  ($1[0]-64) 
0 REM right
84 A = pioset ($1[2]-64)
85 A = pioin  ($1[2]-64)
0 REM middle
86 A = pioclr ($1[1]-64)
87 A = pioin  ($1[1]-64)

0 REM show version number
88 $8 = $9
89 GOSUB 40

0 REM start counters
90 A = zerocnt
91 U = 0

0 REM read message rate
92 V = atoi $16

0 REM mark for botting
93 Q = 100

94 P = 1

95 T = 0
0 REM 96 A = pioout $1[5]
0 REM 97 A = pioclr $1[5]

0 REM init pioirq string
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

0 REM idle handler
@IDLE 110
110 IF Q = 100 THEN 120
111 A = disable 3
112 IF Q > 0 THEN 22
113 ALARM 1
114 GOTO 22

0 REM first boot,
0 REM visible for 30 seconds
0 REM trigger sensor
120 P = 1
121 A = nextsns 1
122 A = slave 30
123 P = 1
124 A = pioirq $6
125 RETURN

0 REM @SLAVE enable shell
0 REM THIS IS NOT SECURE!!! 
0 REM don't use this in production
@SLAVE 130
130 A = pioset($1[4]-64);
131 A = shell;
132 RETURN

0 REM AIO0 and AIO1 reading
@SENSOR 135
135 IF P > 0 THEN 141;

136 A = sensor $13;
137 $7 = $13;
138 $7[4] = 0;
139 IF Q = 100 THEN 143
140 RETURN;

0 REM wait for both readings
141 P = P - 1;
142 RETURN;

0 REM we're booting, let's display
0 REM reading
143 Q = 0
144 GOTO 400 

0 REM we need this so free line calculator
0 REM can do it's job.
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

0 REM 150 RESULTS
0 REM  ...
0 REM 159 RESULTS
0 REM inquiry results
@INQUIRY 160
0 REM we can store as much as 20 results
160 IF R >= 10 THEN 168;
0 REM check filter
161 A= strcmp $15;
162 IF A <> 0 THEN 168;
0 REM passed, might be a target
163 $(150+R) = $0;
164 R=R+1;
165 $0=$339;
166 PRINTV R;
167 A = lcd $0
168 RETURN

0 REM stores PIO
169 RESERVED
0 REM PIO interrupts
@PIO_IRQ 170
170 $169=$0;
0 REM check for flag
171 IF T = 1 THEN 176;
0 REM button press while in settings menu?
172 IF Q > 100 THEN 230;
0 REM 173 is free, you code can hack here.
0 REM button press starts long button recognition
174 IF$169[$1[0]-64]=48THEN180;
175 IF$169[$1[1]-64]=49THEN180;
176 IF$169[$1[2]-64]=48THEN180;
0 REM was it a release for a short press?
177 IF W <> 0 THEN 184;
178 RETURN

0 REM this was a new press
180 $14 = $169;
181 W = 1;
182 ALARM 3;
183 RETURN


0 REM button released for a short press
184 W = 0;
185 ALARM 0
0 REM left button
186 IF$14[$1[0]-64]=48THEN37;
0 REM middle button
187 IF$14[$1[1]-64]=49THEN38;
0 REM right button
188 IF$14[$1[2]-64]=48THEN39;
189 RETURN

0 REM long button press, called by @ALARM
190 W = 0;
0 REM long left
191 IF$14[$1[0]-64]=48THEN34;
0 REM long middle
192 IF$14[$1[1]-64]=49THEN35;
0 REM long right
193 IF$14[$1[2]-64]=48THEN36;
0 REM should never get here
194 A = lcd "ALRM ERROR      "
195 ALARM 5
196 RETURN


0 REM ALARM handler
@ALARM 200

0 REM settings menu running?
200 IF Q > 100 THEN 220;

0 REM check for long button press
201 IF W <> 0 THEN 190;

0 REM no more to do on vanilla code we call your
0 REM your code
202 GOTO 21;


0 REM settings menu handler
0 REM menu prepare
205 Q = 210
206 GOTO 220

0 REM options to show
210 ADDRESS
211 PEER
212 CONTRAST
213 RATE
214 INQUIRY
215 EXIT

220 IF Q = 520 THEN 385;
221 A = pioirq $6;
222 $8=$Q;
223 T = 0;
224 GOTO 40

0 REM menu button manager
230 ALARM 0;
231 IF Q = 500 THEN 290;
232 IF Q = 510 THEN 315;
233 IF Q = 520 THEN 350;
0 REM 234 can be hacked to add more entry levels
235 IF$169[$1[0]-64]=48THEN240;
236 IF$169[$1[1]-64]=49THEN250;
237 IF$169[$1[2]-64]=48THEN245;
238 RETURN

0 REM decrease
240 IF Q < 211 THEN 243;
241 Q = Q - 1;
242 GOTO 220;

0 REM you should modify this line to add more
0 REM entries
243 Q = 215;
244 GOTO 220;

0 REM increase
0 REM modify this line if you add more entries
245 IF Q > 214 THEN 248;
246 Q = Q + 1;
247 GOTO 220;

248 Q = 210;
249 GOTO 220;

0 REM option selected
0 REM self address
250 IF Q = 210 THEN 260;
0 REM peer address
251 IF Q = 211 THEN 270;
0 REM contrast
252 IF Q = 212 THEN 280;
0 REM message rate
253 IF Q = 213 THEN 310;
0 REM inquiry
254 IF Q = 214 THEN 340;
0 REM exit
255 IF Q = 215 THEN 335;
0 REM you can add more options here
0 REM just in case.
256 A = lcd"MENU ERROR"
257 RETURN

0 REM show own address
260 A = getaddr $8;
261 GOSUB 40;
262 WAIT 3
263 GOTO 220

0 REM show peer address
270 A = strlen $5;
271 IF A < 12 THEN 275; 
272 $8=$5;
273 GOSUB 40;
274 GOTO 262

275 $8="NO PAIR";
276 GOTO 273

0 REM contrast handler
280 $0="TEST "
281 PRINTV Y;
282 PRINTV"    "
283 A = auxdac Y;
284 A = lcd $0;
285 Q = 500 ;
286 RETURN

290 IF$169[$1[0]-64]=48THEN300;
291 IF$169[$1[1]-64]=49THEN304;
292 IF$169[$1[2]-64]=48THEN295;
293 RETURN

295 IF Y > 260 THEN 280;
296 Y = Y + 10;
297 GOTO 280;

300 IF Y < 160 THEN 280;
301 Y = Y - 10;
302 GOTO 280;

304 Q = 290;
305 $0[0]=0;
306 PRINTV Y;
307 $2 = $0;
308 ALARM 1;
309 RETURN

0 REM rate setting
310 $0="SEGS ";
311 PRINTV V;
312 $8=$0
313 Q = 510;
314 GOTO 40

315 IF$169[$1[0]-64]=48THEN322;
316 IF$169[$1[1]-64]=49THEN327;
317 IF$169[$1[2]-64]=48THEN320;
318 RETURN

320 V = V + 10;
321 GOTO 310;

322 IF V < 0 THEN 325;
323 V = V - 10;
324 GOTO 310;

325 V = 0;
326 GOTO 310;

327 Q = 210;
328 $0[0]=0;
329 PRINTV V;
330 $16 = $0;
331 ALARM 1;
332 RETURN

0 REM exit handler
335 Q = 0;
336 A=lcd"BYE       "
337 ALARM 1
338 RETURN

339 RESERVED
0 REM inquiry handler
340 $339="FOUND "
341 R = 0;
342 Q = 520;
343 S = 0;
344 A = lcd "SCAN . . . ";
345 T = 1;
346 A = pioirq $12;
347 A = inquiry 9;
348 ALARM 30;
349 RETURN

0 REM inquiry button handler
350 IF$169[$1[0]-64]=48THEN355;
351 IF$169[$1[1]-64]=49THEN370;
352 IF$169[$1[2]-64]=48THEN360;
353 RETURN

0 REM left handler shows previous result
355 IF S = 0 THEN 358;
356 S = S - 1;
357 GOTO 365;

358 S = R+1;
359 GOTO 365;

0 REM right handler shows next result
360 IF S >= R+1 THEN 363;
361 S = S + 1;
362 GOTO 365;

363 S = 0;
364 GOTO 365;

0 REM show on screen
365 $8=$(148+S);
366 GOTO 40 

0 REM middle is option chooser
370 IF S < 2 THEN 380;
371 $5 = $(148+S);
372 Q = 210;
373 A = lcd"DONE         "
374 ALARM 3;
375 RETURN

0 REM cancel or unpair?
380 IF S = 0 THEN 372;
0 REM unpair
381 $5 = "";
382 GOTO 372;

385 A = pioirq $6;
386 T = 0;
387 GOTO 365;


0 REM same base functions -----------------------------------
0 REM nice sensor reading displayer, useful when 
0 REM you want to update the reading and let the
0 REM user know what you're doing (for example
0 REM after an update button press).
400 A = lcd "WAIT . . . "
401 GOSUB 30
402 GOSUB 31
403 $8=$11
404 GOSUB 40
405 ALARM 15
406 RETURN

0 REM turn off
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

0 REM make it visible, enable services
430 A = lcd "VISIBLE  "
431 A = slave 120
432 ALARM 140
433 A = enable 3
434 RETURN

0 REM enable deep sleep
440 A = auxdac 0
441 A = pioset $1[5]
0 REM make sure that nothing happens between enabling deep
0 REM sleep and RETURN
442 A = uartoff;
443 RETURN;

0 REM disable deep sleep
450 A = auxdac N
451 A = pioclr $1[5]
452 RETURN

0 REM display battery reading
460 ALARM 20
461 $0 = "BATT "
462 PRINTV $7
463 $8=$0
464 GOTO 41

469 RESERVED
0 REM send contents from opened file over
0 REM MASTER channel
470 A = seek 0;
471 A = read 32;
472 IF A = 0 THEN 480;
473 PRINTM $0;
474 PRINTM"\n";
475 TIMEOUTM 10;
476 INPUTM $0;
477 A = strcmp "GO";
478 IF A = 0 THEN 471;
479 GOTO 475;

480 WAIT 5;
481 PRINTM"DONE\n";
482 RETURN


0 REM --------------------------------------------------------------------
0 REM sample handling code

0 REM long button press handlers -------------------------
0 REM don't forget to call ALARM before calling 
0 REM RETURN when needed

700 A = lcd"Long Left "
0 REM we suggess this handler to display settings
0 REM menu
701 ALARM 5
702 RETURN


710 A = lcd"Long Mid  "
0 REM we suggest this handler turn off
711 GOTO 701

720 A = lcd "Long Right"
0 REM we suggest this handler to make visible
721 GOTO 701

0 REM -------------------------------------------------------------------


0 REM short button press handlers -------------------------
0 REM don't forget to call ALARM before calling 
0 REM RETURN

730 A = lcd"Short Left "
731 ALARM 5
732 RETURN


0 REM 700 short middle button handler starts here
740 A = lcd"Short Mid  "
741 GOTO 731

0 REM 730 short left button handler starts here

0 REM 760 short right button handler starts here
750 A = lcd"Short Right"
751 GOTO 731
0 REM -------------------------------------------------------------------


0 REM User ALARM code, user is responsable
0 REM of calling ALARM again, and nextsns
760 ALARM 15
761 A = nextsns 1
762 RETURN

