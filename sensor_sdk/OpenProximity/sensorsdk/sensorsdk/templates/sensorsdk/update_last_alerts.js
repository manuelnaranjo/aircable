{% load i18n %}
<script type="text/javascript">
    function update_last_alerts(){
	var defer = loadJSONDoc('rpc/last_alerts/');
	var field=$('pending_alarms_holder');
	field.innerHTML = "{% trans "Updating" %} ..."
	
	var gotAlarms = function(Alarms){
	    if (Alarms.length == 0){
		field.innerHTML="{% trans "No Pending alarms" %}"
		return
	    }
	    
	    holder = UL()
	    
	    for (al in Alarms){
		line = LI()
		alarm=Alarms[al]
		line.innerHTML=
		    "<a href='admin/sensorsdk/alert/" + alarm.pk +"/'>"+
		    alarm.target.name+
		    ' ['+alarm.target.address+']: '+
		    alarm.alert.mode.text + ' {% trans "at" %} ' + alarm.settime +
		    "</a>"
		holder.appendChild(line)
	    }
	    field.innerHTML=""
	    field.appendChild(holder)
	}
	
	var failedFetchAlarms = function(){
	    field.innerHTML = "{% trans "Couldn't fetch alarms" %}"
	}
	
	defer.addCallbacks(gotAlarms, failedFetchAlarms);
    }
    
    addLoadEvent(update_last_alerts);
    setInterval("update_last_alerts()", 60000);

</script>
