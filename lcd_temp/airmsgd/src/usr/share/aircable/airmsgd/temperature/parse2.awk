END {
	val = 0;
	if (match($4, "K")) {
		val = (($2 + $3) / 20) * (9/5) + 32
	} else if (match($4, "I")) {
		val = ($2 / 10) * (9/5) + 32
	}

	#round too one decimal
	val = int(val*10) / 10

	print $4 "*" val
}

