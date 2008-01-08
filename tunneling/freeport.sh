#! /bin/sh

check_range() {

    if [ $1 -gt $PORT_HIGH ]; then
	    echo "Reached port limit, report to admin"
	    echo -1
	    exit 1
    fi
}

create_db() {
    echo "CREATE TABLE tunnel (		\
	    id VARCHAR(30) PRIMARY KEY, \
    	    port INTEGER,		\
            extra VARCHAR(100)		\
    	);"
}

if [ -z $1 ]; then
    echo "Usage: $0 <ID> [MEMO]"
    echo -1
    exit 1
fi

DB_FILE="$HOME/tunnel.db"
PORT_LOW="50000"
PORT_HIGH="51000"

if [ -z "$TUNEL_CONFIG" ]; then
    TUNEL_CONFIG="$HOME/tunnel.config"
fi

if [ -f "$TUNEL_CONFIG" ]; then
    CONTENT=$( cat $TUNEL_CONFIG )
    eval "$CONTENT"
fi

if [ ! -f "$DB_FILE" ] ; then
    sqlite3 $DB_FILE "$(create_db)"
fi

ID="$1"

EXTRA="$2"

REGISTER=$( sqlite3 $DB_FILE "select port from tunnel where id='$ID'")

if [ -z $REGISTER ]; then
    BIGGEST=$( sqlite3 $DB_FILE "select max(port) from tunnel" )
    
    if [ -z "$BIGGEST" ]; then
	PORT=$PORT_LOW
    else
	let PORT=$BIGGEST+1
    fi
    
    while [ ! -z $( netstat -A inet -l -n | awk '{ print $4} ' | grep $PORT) ];
    do
	let PORT=$PORT+1
	check_range $PORT
    done
    
    sqlite3 $DB_FILE "insert  into tunnel (id, port, extra) values \
	('$ID', $PORT, '$EXTRA')"
else
    PORT=$( sqlite3 $DB_FILE "select port from tunnel where id='$ID'" )
fi

echo $PORT
