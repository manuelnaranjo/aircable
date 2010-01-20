#* 
this piece of code implements a common
shell over $stream
*#

## non persistance variables
## K history pointer
##

## history file
999 history.txt 

#set global SHELL="604"

#if $stream=="master"
@MASTER 600
#else if $stream=="slave"
@SLAVE 600
## this isn't safe yet 
## need to filter address
#end if
600 A = lcd"SUCCESS  
601 $PRINT($stream) $19

0 REM now control is on @$stream.upper()
602 ALARM 0

0 REM flush history
603 GOSUB 665

604 $PRINT($stream)"\r\n>"
605 $INPUT($stream)$0
606 A = status;
607 IF A = 0 THEN 650;
## s<file>: send file over spp
608 IF $0[0] = 115 THEN 620;
## u: slave and enable for 20 seconds
609 IF $0[0] = 117 THEN 630;
## S[number][content]: sets line number to 
## content, number is 4 digit long always
610 IF $0[0] = 83 THEN 643;
## L[number]: print content from line 
611 IF $0[0] = 76 THEN 646;
## c<clock>: sets current date and time
612 IF $0[0] = 99 THEN 637;
## d<file>: deletes <file>
613 IF $0[0] = 100 THEN 640;
## l<content> put <content> on the screen
614 IF $0[0] = 108 THEN 680;
## P<timeout>: wait until user does a button press
615 IF $0[0] = 80 THEN 685;
## p<STATE><PIO>: sets <PIO> to either 1 or 0 (pioset/pioclr)
616 IF $0[0] = 112 THEN 688;
## e exit
617 IF $0[0] = 101 THEN 650;

618 $PRINT($stream)"\r\nerror";
619 GOTO $SHELL;

620 A = close
621 A = lcd "SYNC     "
622 A = open $0[1]
623 GOSUB 470
624 A = close
625 GOTO $SHELL

630 $PRINT($stream)"\r\nupdating, bye
631 A = lcd "VISIBLE"
632 $DISCONNECT($stream)
633 A = slave 20
634 A = enable 3
635 ALARM 30
636 RETURN

## push line into history
637 $0=$0[1]
638 GOSUB 660
639 GOTO $SHELL

## delete a file
640 A = close
641 A = delete $0[1]
642 GOTO $SHELL

## set line
643 A=atoi$0[1]
644 \$A=$0[5]
645 GOTO $SHELL

## print line
646 A=atoi$0[1]
647 $PRINT($stream)\$A
648 $PRINT($stream)"\r\n"
649 GOTO $SHELL

## exit from the shell
650 A = lcd "DONE     "
651 $PRINT($stream)"\r\nbye
652 $DISCONNECT($stream)
653 ALARM 1
654 GOSUB 485
655 O = 0
656 A = pioclr ($1[4]-64)
657 RETURN

## store into history, if history buffer
## reaches 4 lines then we flush it
## B is return value, if B=1 then it flushed
660 \$(K+1000)=$0;
661 K=K+1;
## line 662 is hardcoded in python code
## UPDATE! python code if you change
## something here
662 IF K>=10 THEN 665;
663 B=0
664 RETURN

## flush, first disable irqs
665 A=pioirq$12;
666 A=lcd"FLUSHING";

667 A = close;

668 A=append $999;
669 FOR B=0 TO (K-1);
670 $0=\$(B+1000);
671 A=write 32;
672 NEXT B;

## this will take a while
673 A = close;
674 L = 0;
675 K = 0;
## enable interrupts back
676 A = pioirq $6
677 A = lcd "DONE        "
678 B = 1
679 RETURN

## put on screen
680 $0=$0[1];
681 A = lcd $0
## wait until the user
## presses a button
682 GOTO $SHELL

## wait until <TIMEOUT> for any button press
685 A = atoi $0[1];
686 ALARM A
687 RETURN

## p<STATE><PIO>set <PIO> to <STATE>
688 B = atoi $0[2]
689 IF $0[1] = 49 THEN 692
690 A = pioclr B
691 GOTO $SHELL
692 A = pioset B
693 GOTO $SHELL

## hack points for @PIO_IRQ on short button press
187 A = status;
#if $stream=="master"
188 IF A = 10 THEN 694;
#else if $stream=="slave"
188 IF A = 1 THEN 694;
#end if

694 $PRINT($stream)"\r\nBUTTON SHORT 
695 $PRINT($stream) $14
696 GOTO $SHELL

## hack points for @PIO_IRQ on long button press
201 A = status;
#if $stream=="master"
202 IF A = 10 THEN 697;
#else if $stream=="slave"
202 IF A = 1 THEN 697;
#end if

697 $PRINT($stream)"\r\nBUTTON LONG 
699 GOTO 695

