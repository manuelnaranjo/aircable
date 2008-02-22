@ERASE

@INIT 10
10 A = pioout 9
11 A = pioset 9
12 A = auxdac 200
13 A = lcd "TEST       "
14 A = nextsns 20
15 W = 1
16 $0 = "@0008 = 07d0 03E8"
17 A = psset 2
18 RETURN

@SENSOR 100
100 IF W = 0 THEN 110
101 W = 0
102 RETURN

110 A = sensor $0
111 A = lcd $0[4]
112 A = nextsns 20
113 W = 1
114 RETURN
