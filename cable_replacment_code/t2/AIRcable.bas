@ERASE

@INIT 10
10 Z = 0
0 REM 11 PRINTU "open text2\n\r"
0 REM 12 A = open "text2
0 REM 14 GOSUB 109
0 REM 15 A = close

16 A = open "test.txt"
17 GOSUB 109
18 A = close

19 RETURN

109 E = size
110 A = read 32
111 $0[A] = 0
112 PRINTU $0
113 IF A > 0 THEN 110
114 RETURN
