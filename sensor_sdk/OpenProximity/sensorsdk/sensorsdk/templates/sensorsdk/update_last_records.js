{% load i18n %}
<script type="text/javascript">
    function record_as_li(record){
	hold = DIV({'class': 'setting'})
	
	hold.appendChild(DIV({ 
	    'class': 'label',
	    'innerHTML': "["+record.address+"]",
	    'style': 'width: 11.5em;'
	}))
	hold.appendChild(DIV({ 
	    'class': 'label',
	    'innerHTML': record.friendly_name,
	    'style': 'width: 15em; height: 1em;'
	}))
	
	hold.appendChild(DIV({ 
	    'class': 'label', 
	    'innerHTML': record.latest_served,
	    'style': 'width: 20em;'
	}))
	var text=""
	for (var f in record.last_record){
	    text+=f+": "+record.last_record[f]+", "
	}
	hold.appendChild(SPAN({ 
	    'class': 'value', 
	    'innerHTML': text 
	}))
	return hold
    }

    function update_last_records(){
	var defer = loadJSONDoc('rpc/last_records/');
	var field=$('sdk_last_records_holder');
	
	var gotStats = function(stats){
	    var out = DIV({'id': 'sdk_last_records_holder'});
	    
	    for (var rec in stats){
		out.appendChild(record_as_li(stats[rec]))
	    }
	    swapDOM(field, out)
	}
	
	var failedFetchStats = function(){
	    field.innerHTML = "{% trans "No Data" %}"
	}
	
	defer.addCallbacks(gotStats, failedFetchStats);
    }
    
    addLoadEvent(update_last_records);
    setInterval("update_last_records()", 60000);

</script>
