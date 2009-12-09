import sys

def generate_data(inp, out, rng=range(1000, 6000, 500)):
    for l in inp.readlines():
	l=l.strip()
        if l.startswith("#"):
    	    out.write(l)
    	    out.write('\n')
	    continue
	vals = l.split()
	rnom = float(vals[1])
	rmax = float(vals[2])
	rmin = float(vals[3])
	out.write(l)
	out.write(' ')
	for i in rng:
	    von = 1800 * rnom / (i+rnom)
	    vomin = 1800 * rmin / (i+rmin)
	    vomax = 1800 * rmax / (i+rmax)
#	    vo1 = 1800 * i / (i+rnom)
	    out.write('%s %s %s' % (von, vomin, vomax))# %s ' % (vo, vo1))
	    von = 1780 * rnom / (i+rnom)
	    vomin = 1780 * rmin / (i+rmin)
	    vomax = 1780 * rmax / (i+rmax)
	    out.write('%s %s %s' % (von, vomin, vomax))# %s ' % (vo, vo1))
	out.write('\n')
    return rng

def generate_octave(out, rng):
    
    j = 0
    start = 8
    for i in rng:
	if j==0:
	    out.write('plot [0:1800] [-20:120] ')
	else:
	    out.write('replot ')
	out.write('"%s" using %s:1:(1.0) smooth acsplines title "%s"\n' % ( sys.argv[2], j*2+8, i))
#	out.write('replot "%s" using %s:2:(1.0) smooth acsplines title "%s"\n' % ( sys.argv[2], j*2+8, i))
#	out.write('replot "%s" using %s:3:(1.0) smooth acsplines title "%s"\n' % ( sys.argv[2], j*2+8, i))
	out.write('f%s(x)=a%s*x+b%s\n' % (j, j, j))
	out.write('fit [400:1400] f%s(x) "%s" using %s:1 via a%s,b%s\n' % ( j, sys.argv[2], j*2+8, j, j) )
	out.write('replot f%s(x) title "fit for %s"\n' % (j, i) )
#	out.write('fa%s(x)=aa%s*x+ba%s\n' % (j, j, j))
#	out.write('fit [-5:20] fa%s(x) "%s" using 1:%s via aa%s,ba%s\n' % ( j, sys.argv[2], j*2+8, j, j) )
#	out.write('replot fa%s(x) title "fit for %s"\n' % (j, i) )
	out.write('f%s(x)=a+b*x+c*x**2+d*x**3\n' % j)
	out.write('fit f%s(x) "%s" using %s:1 via a,b,c,d\n' % ( j, sys.argv[2], j*2+8) )
	out.write('replot f%s(x) title "fit for %s"\n' % (j, i) )
	j+=1
	
    out.write('pause -1\n')

inp=file(sys.argv[1])
out=file(sys.argv[2], 'w')

steps = range(0, 1800, 1800/255)

#rng=generate_data(inp, out, [1000, 2000, 3000, 4700, 5000, 6000, 7000])
rng=generate_data(inp, out, [4700, ])#4700*.98, 4700*1.02])
#[3100, 4700, 6000, 12000, 24000])#
#range(100, 4000, 500))
#[1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000])
out.close()

generate_octave(file('plotme', 'w'), rng)
