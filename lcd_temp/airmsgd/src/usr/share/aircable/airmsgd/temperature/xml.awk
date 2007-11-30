END{
       	print "\t\t<datetime>"$1" "$2"</datetime>"	
	print "\t\t<nodeid>"$3"</nodeid>"
	print "\t\t<type>"$4"</type>"
	print "\t\t<temperature>"
	print "\t\t\t<fahrenheit>"$5"</fahrenheit>"
	print "\t\t</temperature>"
}
