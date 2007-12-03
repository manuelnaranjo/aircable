END{    
   	print "\t\t<nodeid>"$1"</nodeid>"	
   	print "\t\t<batterylevel>"$2"</batterylevel>"
	if ( match ($3, "LB" ) )
		print "\t\t<lowbattery/>"

}
