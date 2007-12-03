END {
    	sub("BODY:", "", $0);
	sub("[#]", "", $0);
	sub("%"," ", $0);
	print $0
}

