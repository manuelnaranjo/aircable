{% load i18n %}
<script type="text/javascript">
    function record_as_li(record){
	hold = DIV({'class': 'setting', 'display': 'table-row'})
	
	hold.appendChild(DIV({ 
	    'class': 'label',
	    'innerHTML': "["+record.address+"]",
	    'style': 'display: table-cell; width: 13em;'
	}))
	hold.appendChild(DIV({ 
	    'class': 'label',
	    'innerHTML': record.friendly_name,
	    'style': 'display: table-cell; width: 15em;'
	}))
	
	hold.appendChild(DIV({ 
	    'class': 'label', 
	    'innerHTML': record.latest_served,
	    'style': 'width: 20em; display: table-cell'
	}))
	var text=""
	for (var f in record.last_record){
	    text+=f+": "+record.last_record[f]+", "
	}
	if (text.length==0){
	    text="{% trans 'No Data'%}" 
	}
	hold.appendChild(SPAN({ 
	    'class': 'value', 
	    'innerHTML': text ,
	    'style': 'display: table-cell;'
	}))
	return hold
    }

    function update_last_records(){
	var defer = loadJSONDoc('rpc/last_records/');
	var field=$('sdk_last_records_holder');
	
	var gotStats = function(stats){
	    var out = DIV({'id': 'sdk_last_records_holder', 'display': 'table'});
	    
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
