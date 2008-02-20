END {
	val = 0;
	if (match($4, "K")) {
		val = (($2 + $3) / 20) * (9/5) + 32
	} else if (match($4, "I")) {
		val = ($2 / 10) * (9/5) + 32
	}

	#round too one decimal
	val = int(val*10) / 10
	
	val2 = 0;
	
	if (match($5, "1")) {
	    val2 = ($5 / 20) * 9 /5 + 32
	    val3 = 1
	} else 
	    val3 = 0

	print $4 "*" val "*" $1 "*" val3 "*" $2 "*" $3 "*" val2
}

