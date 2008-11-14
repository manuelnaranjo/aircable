0 REM smart lcd sensor

0 REM pio list
1 CLBIT

0 REM pio irq
6 P011000000001

0 REM  update reading
800 F = atoi $13[5];
801 IF F < 400 THEN 805;
0 REM we have ambient sensor
802 G = (F - 500) * 2;
803 H = 1;
804 GOTO 807

0 REM no ambient
805 G = 420;
806 H = 0;

807 K = R
808 L = T
0 REM K sensor connected to MCP3421
809 R = 0;
810 T = 1;
0 REM slave address is 0xD0
811 $899[0] = 208;
812 $899[1] = 143;
813 A = i2c $899;
814 $0[0] = 0;
815 $0[1] = 0;
816 $0[2] = 0;
817 $0[3] = 0;
818 $899[0] = 208;
819 T = 0;
820 R = 4;
821 A = i2c $899;

0 REM restore registers
822 R = K
823 T = L
824 I = $0[1] * 256;
825 I = I + $0[2];

0 REM generate text
830 $0="SMART-K|"
831 PRINTV G
832 PRINTV"|"
833 PRINTV H
834 PRINTV"|"
835 PRINTV I
836 $10 = $0
837 RETURN

900 $0="K "
901 A = ( I + G ) / 20
902 PRINTV A
903 PRINTV "%C   "
904 $11=$0
905 RETURN

