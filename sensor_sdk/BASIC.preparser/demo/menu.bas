#*
    state machine:
        240 <= Q <= 247 displaying menu
        500 waiting for analog to read
        501 waiting for battery to read
        600 <= Q <= 699 running LCD test
        700 <= Q <= 799 running PIO test
*#

## settings menu handler
## menu prepare
235 Q = 240
236 GOTO 250

##  options to show
240 ANALOG
241 BATTERY
242 VISIBLE
243 TEST_LCD
244 TEST_PIO
245 ADDRESS
246 DATE
247 EXIT

250 ALARM 0 
251 A = pioirq $6;
252 T = 0;
253 $8=\$Q;
254 E=0;
255 GOTO 42;

## menu button manager
260 ALARM 0;
261 IF Q = 500 THEN 310;
262 IF Q = 501 THEN 314;
263 IF Q > 700 THEN 350;
263 IF Q > 600 THEN 335;
## 264 can be hacked to add more entry levels
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
272 Q = 247;
273 GOTO 250;

## increase
## modify this line if you add more entries
274 IF Q > 246 THEN 277;
275 Q = Q + 1;
276 GOTO 250;

277 Q = 240;
278 GOTO 250;

## option selected
## read analog
280 IF Q = 240 THEN 300;
## read battery
281 IF Q = 241 THEN 306;
## make visible
282 IF Q = 242 THEN 320;
## test lcd
283 IF Q = 243 THEN 332;
## test pio
284 IF Q = 244 THEN 340;
## show address
285 IF Q = 245 THEN 290;
## show date
286 IF Q = 246 THEN 325;
## exit
287 IF Q = 247 THEN 295;
## you can add more options here.
288 A = lcd"MENU ERROR"
289 RETURN

## show own address
290 A = getaddr $8;
291 GOSUB 40;
292 WAIT 3
293 GOTO 250

## exit handler
295 Q = 0;
296 A=lcd"BYE       "
297 ALARM 1
298 RETURN

## read analog sensor
300 Q = 500

301 A = lcd "WAIT. . . "
302 P = 1
303 A = nextsns 1
304 ALARM 2
305 RETURN

## read battery sensor
306 Q = 501
307 GOTO 301;

## show analog
310 $8=$13[5]
311 $8[4]=0

312 Q = 240
313 GOTO 42;

## show battery
314 $8=$7
315 GOTO 312

## make visible
320 A = slave 20
321 A = lcd "VISIB 20"
322 RETURN

## show date
325 A = date $8
326 GOSUB 40
327 Q = 240
328 ALARM 1
329 RETURN

## test lcd
330 ABCDEFGHIJKLMNOPQRSTUVWXYZ
331 01234567899876543210%CABCD
332 A=pioirq"P000000000000";
333 WAIT 1
334 FOR D=330 TO 331
335 FOR B=0 TO 18
336 A=lcd\$D[B]
337 NEXT B 
338 NEXT D
339 GOTO 250;

## test PIO
340 A=pioirq"P000000000000";
341 Q = 700;
342 $0="PIO";
343 PRINTV Q-700;
344 PRINTV" ";
345 A = pioget (Q-700);
346 PRINTV A;
347 PRINTV"     "
348 A = lcd $0;

## pool interrupts on menu
350 A=pioget($1[0]-64);
351 IF A=0 THEN 360;
352 A=pioget($1[1]-64);
353 IF A=1 THEN 365;
354 A=pioget($1[2]-64);
355 IF A=0 THEN 380;
## let OS handle things
356 GOTO 350

## left pressed exit
360 A=pioget($1[0]-64);
## wait until the user releases the button
361 IF A=0 THEN 360
362 Q=240,
363 GOTO 250;

## middle pressed change state
365 A=pioget($1[1]-64);
## wait until the user releases the button
366 IF A=1 THEN 365;

## don't let user change button pios
367 IF Q=703 THEN 342;
368 IF Q=704 THEN 342;
369 IF Q=712 THEN 342;

## ok now switch PIO state
370 A = pioget(Q-700);
371 IF A=1 THEN 374;
372 A = pioset(Q-700);
373 GOTO 342;

374 A = pioclr(Q-700);
375 GOTO 342;

## right pressed increse pio number
380 A=pioget($1[2]-64);
## wait until the user releases the button
381 IF A=0 THEN 380;

382 IF Q > 719 THEN 385;
383 Q = Q + 1;
384 GOTO 342;
 
385 Q = 700
386 GOTO 341;
