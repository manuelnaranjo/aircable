#ntc_real has the content copied from the pdf file.
A=file('ntc_real')
i = 0
lines=list()

for b in range(0,24):
    lines.append("",)

for line in A.readlines():
    lines[i]+="%s\t" % line.strip()
    i+=1
    if i==24:
	i=0

table=dict()
#lines has now the table, we need to separate per temperature
for line in lines:
    
    while len(line.split())>3:
	t,r,a,line=line.split('\t', 3)
	table[float(t)]=(float(r),float(a))
	
#    #['-55.0', '63.225', '6.7', '65.0', '0.24049', '3.2', '185.0', '0.013448', '1.8']
#    t1,r1,a1,t2,r2,a2,t3,r3,a3=line.strip().split()

t=table.keys()
t.sort()

Vref=1800
R=4700
R25=10000

for k in t:
    r = R25 * table[k][0]
    Vo = Vref*r/(R+r)
    print "%.2f\t%.2f\t%.0f" % (k, r, Vo)


