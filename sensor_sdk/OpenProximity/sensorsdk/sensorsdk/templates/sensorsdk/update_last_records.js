{% load i18n %}
<script type="text/javascript">
    function record_as_li(record){
	out = "<li>"
	out+=record.friendly_name +" [" +record.address +"] at " + record.latest_served +": "
	for (var f in record.last_record){
	    out+=f+": "+record.last_record[f]+", "
	}
	out+="</li>"
	return out
    }

    function update_last_records(){
	var defer = loadJSONDoc('rpc/last_records/');
	var field=$('sdk_last_records_holder');
	field.innerHTML = "{% trans "Updating" %} ..."
	
	var gotStats = function(stats){
	    var out = "";
	    for (var rec in stats){
		out +=record_as_li(stats[rec])
	    }
	    field.innerHTML = "<ul>"+out+"</ul>";
	}
	
	var failedFetchStats = function(){
	    field.innerHTML = "{% trans "No Data" %}"
	}
	
	defer.addCallbacks(gotStats, failedFetchStats);
    }
    
    addLoadEvent(update_last_records);
    setInterval("update_last_records()", 60000);

</script>
