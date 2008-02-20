END {
	if ( match ($1, "hci0") )
		print $2
}

