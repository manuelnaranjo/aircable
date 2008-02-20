END{
    print "<updaterequest>"
    print "\t<nodeid>" $1 "</nodeid>"
    print "\t<peeraddr>" substr($3,0,2) ":" substr($3,3,2) ":" \
		substr($3,5,2) ":" substr($3,7,2) ":" substr($3,9,2) ":" \
	 	substr($3,11,2) "</peeraddr>"
    print "\t<type>monitor</type>"
    print "\t<sendrate>" $4 "</sendrate>"
    print "\t<kcalibration>" $5 "</kcalibration>"
    print "\t<lcdcontrast>" $6 "</lcdcontrast>"
    print "\t<probe>" $7 "</probe>"
    if ( match ($8, "1"))
	print "\t<temptype>C</temptype>"
    else
	print "\t<temptype>F</temptype>"
    print "\t<basicversion>" $9 "</basicversion>"
    print "\t<visiblename>" $10 "</visiblename>"
    print "\t<welcometext>" $11 "</welcometext>"
    
    print "</updaterequest>"
}
