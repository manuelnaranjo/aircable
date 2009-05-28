0 REM this piece of code implements a common
0 REM shell over MASTER

0 REM non persistance variables --------------
0 REM K history pointer
0 REM -----------------

0 REM history file
999 history.txt 

@MASTER 600
600 A = lcd"SUCCESS  
601 PRINTM $19

0 REM now control is on @MASTER
602 ALARM 0

0 REM flush history
603 GOSUB 665

604 PRINTM"\r\n>"
605 INPUTM $0
606 A = status;
607 IF A = 0 THEN 650;
0 REM s<file>: send file over spp
609 IF $0[0] = 115 THEN 620;
0 REM u: slave and enable for 20 seconds
610 IF $0[0] = 117 THEN 630;
0 REM S[number][content]: sets line number to 
0 REM content, number is 4 digit long always
611 IF $0[0] = 83 THEN 643;
0 REM p[number]: print content from line 
612 IF $0[0] = 112 THEN 646;
0 REM c<clock>: sets current date and time
613 IF $0[0] = 99 THEN 637;
0 REM d<file>: deletes <file>
614 IF $0[0] = 100 THEN 640;
0 REM e exit
615 IF $0[0] = 101 THEN 650;

618 PRINTM"\r\nerror";
619 GOTO 604;

620 A = close
621 A = lcd "SYNC     "
622 A = open $0[1]
623 GOSUB 470
624 A = close
625 GOTO 604

630 PRINTM"\r\nupdating, bye
631 A = lcd "VISIBLE"
632 A = disconnect 1
633 A = slave 20
634 A = enable 3
635 ALARM 30
636 RETURN

0 REM push line into history
637 $0=$0[1]
638 GOSUB 660
639 GOTO 604

0 REM delete a file
640 A = close
641 A = delete $0[1]
642 GOTO 604

0 REM set line
643 A=atoi$0[1]
644 $A=$0[5]
645 GOTO 604

0 REM print line
646 A=atoi$0[1]
647 PRINTM$A
648 PRINTM"\r\n"
649 GOTO 604

0 REM exit from the shell
650 A = lcd "DONE     "
651 PRINTM"\r\nbye
652 A = disconnect 1
653 ALARM 1
654 A = zerocnt
655 O = 0
656 A = pioclr ($1[4]-64)
657 RETURN

0 REM store into history, if history buffer
0 REM reaches 4 lines then we flush it
0 REM B is return value, if B=1 then it flushed
660 $(K+1000)=$0;
661 K=K+1;
0 REM line 662 is hardcoded in python code
0 REM UPDATE! python code if you change
0 REM something here
662 IF K>=4 THEN 665;
663 B=0
664 RETURN

0 REM flush, first disable irqs
665 A=pioirq$12;
666 A=lcd"FLUSHING";

667 A = close;

668 A=append $999;
669 FOR B=0 TO K;
670 $0=$(B+1000);
671 A=write 32;
672 NEXT B;

0 REM this will take a while
673 A = close;
674 L = 0;
675 K = 0;
0 REM enable interrupts back
676 A = pioirq $6
677 A = lcd "DONE        "
678 B = 1
679 RETURN
