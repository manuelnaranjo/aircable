import sys

def clean(inpt, error=0.05):
    pre = {'m': None, 'h': None}
    out = list()
    rec = None
    
    for recs in inpt:
	flag = False
	m = recs['m']
	h = recs['h']

	if pre['m'] and pre['h']:
	    try:
		if pre['m'] == m or abs( (pre['m']-m)/m ) < error:
		    flag=True
	    except Exception, err:
		pass
	pre['m'] = m
	pre['h'] = h

	if flag:
	    if rec:
		rec['min_vo'] = min(rec['min_vo'], recs['min_vo'])
		rec['max_vo'] = max(rec['max_vo'], recs['max_vo'])
		rec['min_te'] = min(rec['min_te'], recs['min_te'])
		rec['max_te'] = max(rec['max_te'], recs['max_te'])
	    continue
	if rec:
	    out.append(rec)
	else:
	    out.append(recs)
	rec = recs
    return out

if __name__ == '__main__':
    if len(sys.argv) < 4:
	print "usage: ", sys.argv[0], ": input_file temperature_column voltage_column"
	sys.exit()
    lineal=list()
    inp = file(sys.argv[1])
    TE = int(sys.argv[2])
    VO = int(sys.argv[3])
    
    pre_te = None
    pre_vo = None
    
    for line in inp.readlines():
	if line.startswith('#'):
	    continue
	
	params=line.split()
	te = float(params[TE])
	vo = float(params[VO])
	if pre_te is not None and pre_vo is not None:
	    m = (pre_te - te) / (pre_vo-vo)
	    h = ((te - m * vo) + (pre_te - m * pre_vo)) / 2 # average
#	    h = te - m * vo
	    lineal.append(
		{
		    'min_te': pre_te,
		    'max_te': te,
		    'min_vo': pre_vo, 
		    'max_vo': vo,
		    'm': m,
		    'h': h,
		}
	    )
	pre_te = te
	pre_vo = vo
    
    print "load -ascii '%s';" % sys.argv[1]
    print "t=%s(:,%s:%s);" % ( sys.argv[1], TE+1, TE+1)
    print "v=%s(:,%s:%s);" % ( sys.argv[1], VO+1, VO+1)
    print "plot (v,t);"
    print "hold on"

    for rec in clean(lineal):
	print "function [y] = f(x)"
	print "y=%s*x+%s;" % (rec['m'], rec['h'])
	print "end"
	min_ = rec['min_vo']
	max_ = rec['max_vo']
	step = (max_-min_)
	print "x=%s:%s:%s;" % (min_, step, max_)
	print "[y]=f(x);"
	print "plot(x,y,'cr');"
	print "hold on"
