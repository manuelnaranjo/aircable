## same base functions --------------------------------
## nice sensor reading displayer, useful when 
## you want to update the reading and let the
## user know what you're doing (for example
## after an update button press).
400 A = lcd "WAIT . . . "
0 REM 401 GOSUB 30
402 GOSUB 31
403 $8=$11
404 GOSUB 40
405 ALARM 15
406 RETURN

## turn off
410 A = lcd "GOOD BYE";
411 ALARM 0;
412 A = pioset($1[4]-64)
413 A = pioclr($1[4]-64);
414 A = pioget($1[1]-64);
415 IF A = 1 THEN 412;
416 A = pioclr($1[3]-64);
417 A = lcd;
418 A = reboot;
419 FOR E = 0 TO 10;
420   WAIT 1
421 NEXT E;
422 RETURN

## make it visible, enable services
430 A = lcd "FTP OPEN"
431 A = slave 120
432 ALARM 140
433 A = enable 3
434 A = pioset ($1[4]-64)
436 RETURN

## enable deep sleep
440 A = auxdac 0
441 A = pioset ($1[5]-64)
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
475 GOTO 471;

##475 $TIMEOUT($stream) 10;
##476 $INPUT($stream) $0;
##477 A = strcmp "GO";
##478 IF A = 0 THEN 471;
##479 GOTO 475;


480 WAIT 5;
481 $PRINT($stream)"DONE\n";
482 RETURN

0 REM readcounter, zero it
0 REM and add to time counter
485 B = readcnt;
486 U = U + B;
487 A = zerocnt;
488 RETURN

