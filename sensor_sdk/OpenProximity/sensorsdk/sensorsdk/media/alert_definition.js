function getHelpText(sibling){
    var b;

    while ( true ) {
        if (sibling.tagName == 'P' && sibling.className.search('help')>-1){
            b = sibling;
            return b
        }
        sibling = sibling.nextSibling
    }

    return b
}

function updateHelpText(){
    var pk = $('id_mode');
    pk=pk.options[pk.selectedIndex].value;
    defer = loadJSONDoc('/sensorsdk/API/get-help/'+pk);
    
    var gotHelp=function(content){
        getHelpText($('id_mode')).innerHTML = content['mode']
        if ( content['pk'] == -1 ) {
	    $('id_field').parentNode.parentNode.style.display="none"
	    $('id_clr').parentNode.parentNode.style.display="none"
        }else{
	    getHelpText($('id_field')).innerHTML = content['field']
	    $('id_field').parentNode.parentNode.style.display=""

	    getHelpText($('id_clr')).innerHTML = content['clr']
	    $('id_clr').parentNode.parentNode.style.display=''
	}
        getHelpText($('id_set')).innerHTML = content['set']

    };
    
    var helpFailed=function(err){};
    
    defer.addCallbacks(gotHelp, helpFailed);
}

function onLoad(){
    updateHelpText()
    connect('id_mode', 'onchange', updateHelpText)
}

connect(window, 'onload', onLoad)
//addLoadEvent(updateHelpText)
//addToCallStack(
