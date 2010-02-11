{% load i18n %}
<script type="text/javascript">
    function update_last_alerts(){
	var defer = loadJSONDoc('rpc/last_alerts/');
	var field=$('pending_alarms_holder');
	
	var gotAlarms = function(Alarms){
	    if (Alarms.length == 0){
		field.innerHTML="{% trans "No Pending alarms" %}"
		return
	    }
	    
	    new_holder = DIV({'id': 'pending_alarms_holder'})
	    
	    for (al in Alarms){
		var line = DIV({"class":"setting"})
		var alarm=Alarms[al];

		var k = "label"
		if (alarm.active) {
		    k+=" active";
		}
		line.appendChild(STRONG({'class': k, 'innerHTML': alarm.state}))
		
		v=DIV({"class": "value"})
		
		v.appendChild(A({
		    'href': 'admin/sensorsdk/alert/' + alarm.pk +'/',
		    'innerHTML': alarm.target.name+ ' ['+alarm.target.address+']: '+ alarm.alert.mode.text + ' {% trans "at" %} ' + alarm.settime
		}))
		line.appendChild(v)
		new_holder.appendChild(line)
	    }
	    
	    swapDOM(field, new_holder)
	}
	
	var failedFetchAlarms = function(){
	    field.innerHTML = "{% trans "Couldn't fetch alarms" %}"
	}
	
	defer.addCallbacks(gotAlarms, failedFetchAlarms);
    }
    
    addLoadEvent(update_last_alerts);
    setInterval("update_last_alerts()", 60000);

</script>
