@ERASE

0 REM Line $1 stores the slave peer address.
1 0015E9F5BAFE

0 REM E is the state variable
0 REM E = 0 means slave disconnected
0 REM E = 1 slave connected - master connecting
0 REM E = 2 slave connected - master connected

@INIT 50
50 Z = 1
51 E = 0
52 J = 20
53 RETURN

@IDLE 100
100 GOTO 200

@SLAVE 150
150 E = 1
151 ALARM 1
152 RETURN

@MASTER 160
160 A = link 3
161 E = 2
162 ALARM 10
163 A = pioset J
164 RETURN

@ALARM 200
200 IF E = 0 THEN 210
201 IF E = 1 THEN 220
202 IF E = 2 THEN 230
203 RETURN

210 A = pioset J
211 A = pioclr J
212 A = slave 5
213 RETURN

220 A = pioset J;
221 A = pioclr J
222 A = master $1
223 ALARM 6
224 RETURN

230 A = status
231 IF A < 10000 THEN 233
232 A = A - 10000
233 IF A < 1000 THEN 235
234 A = A - 1000
235 IF A < 100 THEN 237
236 A = A - 100
237 IF A <> 11 THEN 280
238 ALARM 10
239 RETURN

280 A = disconnect 0
281 A = disconnect 1
282 E = 0
283 ALARM 1
284 RETURN

@PIN_CODE 300
300 $0="1234"
301 RETURN

