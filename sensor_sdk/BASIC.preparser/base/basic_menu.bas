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

