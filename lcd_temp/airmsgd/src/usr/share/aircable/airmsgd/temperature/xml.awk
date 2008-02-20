END{    
    print "\t\t<datetime>"$1"</datetime>"	
    print "\t\t<nodeid>"$2"</nodeid>"
    print "\t\t<type>"$3"</type>"
    print "\t\t<temperature>"
    print "\t\t\t<fahrenheit>"$4"</fahrenheit>"
    print "\t\t</temperature>"
    if ($6 == "1")
	print "\t\t<ambient>"$9"</ambient>"
    print "\t\t<sensor_voltage>"$7"</sensor_voltage>"
    print "\t\t<sensor_calibration>"$8"</sensor_calibration>"
}
