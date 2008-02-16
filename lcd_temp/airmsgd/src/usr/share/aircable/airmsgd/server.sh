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
    kill -9 $PID
    
    PID=$(cat $SENDER_PID)
    kill -9 $PID
    
    echo $(date) "stoping daemon"
    
    exit 0
}


LOG_DIR="/var/log/airmsgd"
OBEX_LOG="$LOG_DIR/obexftpd.log"
LOG_FILE="/dev/stdout"

if [ -f /etc/aircable/airmsgd.conf ]; then
    source /etc/aircable/airmsgd.conf
fi
    

APP_DIR="/usr/share/aircable/airmsgd"

PID_DIR="/var/run/airmsgd"

echo $$ > $PID_DIR/pid

OBEX_PID=$PID_DIR/obexftpd
SENDER_PID=$PID_DIR/sender

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

trap kill_obex SIGHUP SIGINT SIGTERM TERM

obexftpd -c $MSG_DIR -b -B 10 > $OBEX_LOG &

echo $! > $OBEX_PID

sdptool add --channel 10 OPUSH

echo $(date) "Obex Server Running" >> $LOG_FILE

$APP_DIR/sender.sh >>$LOG_FILE  &

echo $! > $SENDER_PID

while [ 1 ];
do
    FILES=$( ls $MSG_DIR )
    for i in $FILES
    do
	FILEN=$MSG_DIR/$i
	echo $(date) "Received Message from $i" >> $LOG_FILE
	
	FILE=$( cat $FILEN );
	echo -e "$FILE" >> $LOG_FILE;
	
	BODY=$( echo -e "$FILE" | grep "BODY:" );
	echo "BODY: $BODY"
	TEMPERATURE=$( echo -e "$BODY" | grep -E \
		'BODY:\$(+|-)?[0-9]+:(+|-)?[0-9]+!(+|-)?[0-9]+\#(K|IR)+$' );
	BATT=$( echo -e "$BODY" | grep -E 'BODY:\#.*\%.*' );
	UPDATE=$( echo -e "$BODY" | grep -E 'BODY:\?UPDATE' );

	if [ -n "$TEMPERATURE"  ]; then
	    echo "Temperature Reading" >> $LOG_FILE
	    PARSE=$( bash $APP_DIR/temperature/parse.sh $MSG_DIR $i )
	    echo $PARSE > $TEMPERATURE_DIR/reading.$RANDOM
	    echo "Reading generated: " $PARSE >> $LOG_FILE
	else 
	    if [ -n "$BATT" ]; then
		echo "Battery Reading" >> $LOG_FILE
		PARSE=$( bash $APP_DIR/battery/parse.sh $MSG_DIR $i )
		echo $PARSE > $BATT_DIR/reading.$RANDOM
		echo "Battery generated: " $PARSE >> $LOG_FILE
	    else 
		if [ -n "$UPDATE" ]; then
		    echo "Update Request" >> $LOG_FILE
		    $APP_DIR/update/update.sh ${i:0:17} "$UPDATE" $LOG_FILE
		fi
	    fi
	fi
	
	rm $MSG_DIR/$i
	
    done
    
    sleep 60
done
