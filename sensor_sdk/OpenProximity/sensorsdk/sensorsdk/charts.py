from django.conf import settings
from django.db.models import Max, Min
from django.http import HttpResponse
from django.utils.translation import gettext as _
from datetime import datetime
import models
import pyofc2
import time

class RingBuffer:
    def __init__(self, size):
	self.data = [None for i in xrange(size)]

    def append(self, x):
	self.data.pop(0)
	self.data.append(x)

    def get(self):
	return self.data
	
def low_pass_filter(data, alpha=0.1):
    if len(data)==0:
	raise StopIteration("No data")

    last=data[0]['y']
    yield data[0]['x'], data[0]['y']
    for cur in data[1:]:
	cur['x'] = int(cur['x'])
	y = cur['y'] * alpha + (1-alpha)*last
	yield cur['x'], y
	last = y

def moving_average(data, smooth_len):
    if len(data) == 0:
	raise StopIteration("No data")
    x = 0
    LEN = int(len(data)*smooth_len) # dynamic buffer length
    buff = RingBuffer(LEN)
    div=(LEN*(LEN+1))/2.
    B=[(LEN-i)/div for i in range(LEN)]
    r=range(LEN)
    for rec in data:
	tim, val=rec['x'], rec['y']
        x+=1
	if x < LEN+1:
	    buff.append(val)
	    div=(x*(x+1))/2.
	    b=[(x-i)/div for i in range(x)]
	    val=sum([buff.data[-(i+1)]*b[i] for i in r[:x]])
	    yield {'x':tim, 'y':val}
	    continue

	buff.append(val)
	val=sum([buff.data[-(i+1)]*B[i] for i in r])
	yield {'x': tim, 'y': val}
	
def clear_duplicates(data, field):
    if len(data) == 0:
	raise StopIteration("No data")

    prev = data[0]
    yield data[0]['timestamp'], prev[field]
    last_timestamp = prev['timestamp']

    for rec in data[1:]:
	if prev[field] != rec[field]:
	    if last_timestamp != prev['timestamp']: # prevent duplicated points
		yield prev['timestamp'], prev[field]
	    yield rec['timestamp'], rec[field] # include new point
	    last_timestamp = rec['timestamp']
	prev = rec
#	yield rec['timestamp'], rec[field]

def __check_field_is_valid(device, fields):
    for field in fields:
	assert field in device.getChartVariables(), "Not a valid field %s" % field

if settings.DATABASE_ENGINE.lower()=="sqlite3":
    epoch="strftime(\"%%s\", time, 'utc')"

else:
    raise Exception("Database %s not supported yet by SensorSDK" % settings.DATABASE)

COLOURS=[
    "#0101DF",
    "#DF0101",
    "#01DF01",
    "#FF8000",
    "#DF0174",
    "#000000",
]

def add_dots(inp):
    if inp.find(':') > -1:
	return inp
    return inp[0:2]+':'+inp[2:4]+':'+inp[4:6]+':'+inp[6:8]+':'+inp[8:10]+':'+inp[10:12]

SPANS={
    'hour': 60,
    'day': 60*24,
    'week': 60*24*7,
    'month': 60*24*30,
    None: 60
}

def generate_data(dev=None, fields=None, start=None, end=None):
    qs=dev.getRecordClass().objects.filter(time__isnull=False).\
	filter(remote=dev, time__gte=start, time__lte=end)
    qs=qs.extra(select={'timestamp': epoch}) # replace time by a unix timestamp
    qs.order_by('timestamp')
    return qs


def generate_chart_data(request, 
	    address=None, 
	    fields=None, 
	    *args,
	    **kwargs):
    '''Generates charting data for fields'''
    span = request.GET.get('span', None)
    colours = request.GET.get('colours', None)
    start = request.GET.get('start', None)
    end = request.GET.get('end', None)
    raw = request.GET.get('raw', "true").lower() == "true"
    smooth = request.GET.get('smooth', "false").lower() == "true"
    smooth_len=float(request.GET.get('smooth_factor', "0.2"))
    
    fields=fields.split(',')
    address=address.replace('_',':')

    span=SPANS[span]*60
    
    dev = models.SensorSDKRemoteDevice.objects.get(address=address)
    dev = models.get_subclass(dev)
    __check_field_is_valid(dev, fields)
    
    if end is None:
	end = datetime.now()
    
    if start is None:
	start = datetime.fromtimestamp(
	    time.mktime(end.timetuple())-span)

    qs = generate_data(dev=dev, fields=fields, start=start, end=end)
    data = qs.values('timestamp', *fields)
    if colours is not None:
	col = colours
	colours = {}
	for f in colours.split(','):
	    field, colour = f.split('=', 1)
	    colours[field]=colour
    else:
	colours={}
	i=0
	for field in fields:
	    colours[field]=COLOURS[i]
	    i+=1;
	    if i>=len(COLOURS):
		i=0;
	for field in fields:
	    colours['%s_average' % field]=COLOURS[i]
	    i+=1;
	    if i>=len(COLOURS):
		i=0;

    sets = {}

    for field in fields:
	sets[field]=clear_duplicates(data, field)

    if smooth:
        for f in fields:
	    #sets[a] = [pyofc2.scatter_value(**vals) for vals in moving_average(sets(f), smooth_len)]
	    s = [({'x':a['timestamp'], 'y':a[f]}) for a in data]
	    sets["%s_average" % f] = low_pass_filter(s, smooth_len)

    x_axis = pyofc2.x_axis()

    x_axis.min=int(time.mktime(start.timetuple()))
    x_axis.max=int(time.mktime(end.timetuple()))
    x_axis.steps=(x_axis.max-x_axis.min)/10
    
    if x_axis.max - x_axis.min <= 60*60*24:
        format = 'H:i'
    else:
        format = 'm-d-Y H:i'
    
    labels = [
	{ 
	    'x': a, 
	    'text': '#date:%s#' % format,
	} for a in range(x_axis.min, x_axis.max+x_axis.steps, x_axis.steps)]
    x_axis.labels=pyofc2.x_axis_labels(labels=labels, rotate='45')
    
    y_axis = pyofc2.y_axis()
    y_axis.min = None
    y_axis.max = None
    for field in fields:
	b = qs.aggregate(min=Min(field), max=Max(field))
	if y_axis.min is None or y_axis.min > b['min']:
	    y_axis.min = b['min']
	if y_axis.max is None or y_axis.max < b['max']:
	    y_axis.max = b['max']
    if y_axis.min is None:
	y_axis.min = -1
    if y_axis.max is None:
	y_axis.max = 1
    y_axis.min = 0.9 * y_axis.min
    y_axis.max = 1.1 * y_axis.max

    y_axis.steps=(y_axis.max-y_axis.min)/10

    chart = pyofc2.open_flash_chart()
    chart.title=pyofc2.title(text="%s [%s]: %s" % (dev.friendly_name, address, fields))
    #chart.tooltip=pyofc2.tooltip(text="#date: Y-m-d H:i#<br>#y#\n")
    for c in sets:
	if not raw and not c.endswith('average'):
	    continue
	if not smooth and c.endswith('average'):
	    continue
	s = pyofc2.scatter_line()
	s.values = [pyofc2.scatter_value(x=x,y=y) for x,y in sets[c]]
	s.text = c
	s.dot_style = {'tip': "%s<br>#date:Y-m-d H:i#<br>%s: #val#" % (c, _("Value") )}
	if colours.get(c, None):
	    s.colour=colours[c]
	chart.add_element(s)

    chart.x_axis = x_axis
    chart.y_axis = y_axis

    return HttpResponse(chart.render(), content_type='application/json')
