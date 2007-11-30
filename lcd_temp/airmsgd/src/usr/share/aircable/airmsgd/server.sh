#!/bin/bash
# AIRmsgd daemon
# Copyright (C) 2007 Wireless Cables Inc.
# Copyright (C) 2007 Naranjo, Manuel <manuel@aircable.net>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

kill_obex(){
    OPUSH=$(sdptool browse --uuid 0x1105 local | grep "Service RecHandle:" \
    		| sed -e "s/Service RecHandle: 0x//g")
    FTP=$(sdptool browse --uuid 0x1106 local | grep "Service RecHandle:" \
    		| sed -e "s/Service RecHandle: 0x//g")
    
    echo $(date) "deregistering services"
    sdptool del $OPUSH
    sdptool del $FTP
        
    echo $(date) "killing obexftpd"
    PID=$(cat $OBEX_PID) 
    kill $PID
    
    echo $(date) "stoping daemon"
    
    exit 0
}

LOG_FILE="/dev/null"

APP_DIR="/usr/share/aircable/airmsgd"

#APP_DIR="."

PID_DIR="/var/run/airmsgd"

echo $$ > $PID_DIR/pid

OBEX_PID=$PID_DIR/obexftpd
LOG_DIR="/var/log/airmsgd"
MSG_DIR="/tmp/airmsgd/msg"
TEMPERATURE_DIR="/tmp/airmsgd/temperature"
BATT_DIR="/tmp/airmsgd/batt"
UPDATE_DIR="/tmp/airmsgd/update"

rm -rf $MSG_DIR
rm -rf $TEMPERATURE_DIR
rm -rf $BATT_DIR
rm -rf $UPDATE_DIR

mkdir -p $LOG_DIR
mkdir -p $MSG_DIR
mkdir -p $TEMPERATURE_DIR
mkdir -p $BATT_DIR
mkdir -p $UPDATE_DIR

OBEX_LOG="$LOG_DIR/obexftpd.log"

trap kill_obex SIGHUP SIGINT SIGTERM TERM

obexftpd -c $MSG_DIR -b -B 10 > /dev/null &

echo $! > $OBEX_PID

sdptool add --channel 10 OPUSH

echo $(date) "Obex Server Running" >> $LOG_FILE

while [ 1 ];
do
    FILES=$( ls $MSG_DIR )
    for i in $FILES
    do
	FILEN=$MSG_DIR/$i
	echo $(date) "Received Message from $i" >> $LOG_FILE
	echo "Received Message from $i"
	
	FILE=$( cat $FILEN );
	echo -e "$FILE" >> $LOG_FILE;
	echo -e "$FILE"
	
	BODY=$( echo -n $FILE | grep "BODY:" );
	TEMPERATURE=$( echo $BODY | grep -E \
		'BODY:\$(+|-)?[0-9]+:(+|-)?[0-9]+!(+|-)?[0-9]+\#[A-Z]$' );
	BATT=$( echo $BODY | grep -E 'BODY:#*' );
	UPDATE=$( echo $BODY | grep -E 'BODY:\?UPDATE' );
	
	if [ -n $TEMPERATURE  ]; then
	    echo "Temperature Reading"
	    PARSE=$( bash $APP_DIR/temperature/parse.sh $MSG_DIR $i )
	    echo $PARSE > $TEMPERATURE_DIR/reading.$RANDOM
	    echo "Reading generated"
	else 
	    if [ -n $BATT ]; then
		echo "Battery Reading"
	    else 
		if [ -n $UPDATE ]; then
		    echo "Update Ready"
		fi
	    fi
	fi
	
	rm $MSG_DIR/$i
	
    done
    
    sleep 10
done
