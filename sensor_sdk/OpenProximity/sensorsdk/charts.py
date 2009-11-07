from django.conf import settings
from django.db.models import Max, Min
from django.http import HttpResponse
from datetime import datetime
import models
import pyofc2
import time

def __check_field_is_valid(device, fields):
    for field in fields:
	assert field in device.getChartVariables(), "Not a valid field %s" % field

if settings.DATABASE_ENGINE.lower()=="sqlite3":
    epoch="strftime(\"%%s\", time, 'localtime')"
#elif settings.DATABASE_ENGINE.startswith()=="postgre":
    
else:
    raise Exception("Database %s not supported yet by SensorSDK" % settings.DATABASE)

def add_dots(inp):
    if inp.find(':') > -1:
	return inp
    return inp[0:2]+':'+inp[2:4]+':'+inp[4:6]+':'+inp[6:8]+':'+inp[8:10]+':'+inp[10:12]

def generate_chart_data(request, address=None, fields=None, start=None, end=None, colours=None, *args,**kwargs):
    '''Generates charting data for fields'''
    print address, fields,start, end, colours, args, kwargs
    fields=fields.split(',')
    address=add_dots(address)
    print address
    dev = models.SensorSDKRemoteDevice.objects.get(address=address)
    dev = models.get_subclass(dev)
    __check_field_is_valid(dev, fields)
    
    if colours is not None:
	col = colours
	colours = {}
	for f in colours.split(','):
	    field, colour = f.split('=', 1)
	    colours[field]=colour
    else:
	colours={}

    if end is None:
	end = datetime.now()
    
    if start is None:
	start = datetime.fromtimestamp(
	    time.mktime(end.timetuple())-60*60*24) # last 24 hours
    qs=dev.getRecordClass().objects.filter(time__isnull=False).\
	filter(remote=dev, time__gte=start, time__lte=end)
    qs=qs.extra(select={'timestamp': epoch}) # replace time by a unix timestamp
    qs.order_by('timestamp')
    print qs.count()
    data = qs.values('timestamp', *fields)

    sets = {}
    for a in fields:
	sets[a] = list()

    for rec in data:
	for a in fields:
	    sets[a].append( pyofc2.scatter_value( x=rec['timestamp'], y=rec[a] ) )
	    
    x_axis = pyofc2.x_axis()

    x_axis.min=int(time.mktime(start.timetuple()))
    x_axis.max=int(time.mktime(end.timetuple()))
    x_axis.steps=(x_axis.max-x_axis.min)/10
    
    labels = list()
    if x_axis.max - x_axis.min <= 60*60*24:
	format = 'H:i'
    else:
	format = 'm-d-Y H:i'
    for i in range(x_axis.min, x_axis.max, x_axis.steps):
	labels.append(datetime.fromtimestamp(i).strftime(format),)
    labels = [
	{ 
	    'x': a, 
	    'text': '#date:%s#' % format,#datetime.fromtimestamp(a).strftime(format)
	} for a in range(x_axis.min, x_axis.max, x_axis.steps)]
    print labels
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
    chart.title=pyofc2.title(text="%s: %s" % (address, fields))
    chart.tooltip=pyofc2.tooltip(text="#date: Y-m-d H:i#<br>#y#\n")
    for c in fields:
	s = pyofc2.scatter_line()
	s.title = pyofc2.title(text=c)
	s.values = sets[c]
	if colours.get(c, None):
	    s.colour=colours[c]
	chart.add_element(s)

    chart.x_axis = x_axis
    chart.y_axis = y_axis

    return HttpResponse(chart.render())#, content_type='application/json')

