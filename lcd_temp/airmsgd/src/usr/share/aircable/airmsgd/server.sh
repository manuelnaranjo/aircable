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

APP_DIR="/usr/share/aircable/airmsgd"

PID_DIR="/var/run/airmsgd"

echo $$ > $PID_DIR/pid

OBEX_PID=$PID_DIR/obexftpd
LOG_DIR="/var/log/airmsgd"
MSG_DIR="/tmp/airmsgd/msg"

##TIME:VALUE!CORRECTION#TYPE

mkdir -p $LOG_DIR
mkdir -p $MSG_DIR

OBEX_LOG="$LOG_DIR/obexftpd.log"

trap kill_obex SIGHUP SIGINT SIGTERM TERM

obexftpd -c $MSG_DIR -b > /dev/null &

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
	
	##call parser	
	TOKEN=$( $APP_DIR/parse.sh $FILEN )
	
	if [ $? -gt 0 ]; then
	    echo -e "$TOKEN" >> $LOG_FILE
	    echo -e "$TOKEN"
	    rm -rf $FILEN
	else
	    IFS='|'
	    VAL=(${TOKEN})
	    	    
	    echo "VALUE: ${VAL[1]}, TIME: ${VAL[0]}, CORR: ${VAL[2]}, \
	    	TYPE: ${VAL[3]}"
	    echo "VALUE: ${VAL[1]}, TIME: ${VAL[0]}, CORR: ${VAL[2]}, \ 
	    	TYPE: ${VAL[3]}" >> $LOG_FILE
	
	    echo "SENDING...."
	    echo "SENDING...." >> $LOG_FILE
	
	    TRUE_VAL=$( echo "(125/2566.4)*(${VAL[1]}+ ${VAL[2]})" | bc -l )
	
	    ## TRUE_VAL is not truncated, generate.sh does that for us
	
	    echo "TRUE VALUE: $TRUE_VAL"
	    echo "TRUE VALUE: $TRUE_VAL" >> $LOG_FILE
	
	    ## we consider ID as the BT addr, we need to get this from the file name
	
	    LOW=$(expr index "$FILEN" _ );	
	    let LOW=$LOW-1	
	    NAME=$(expr substr "$FILEN" 1 $LOW);
	
	    XML=$($APP_DIR/generate.sh $NAME $TRUE_VAL ${VAL[3]})
	
	    echo "XML FILE: $XML"
	    echo "XML FILE: $XML" >> $LOG_FILE
	
	    REPLY=$($APP_DIR/send.sh "$XML")
	
	    ## if reply contains nodeid then we have submmited the info correctly
	    INDEX=$(expr index "$REPLY" "<nodeid>")

	    if [ $INDEX -gt 0 ]
	    then
		echo "SUCCESS"
	        echo "SUCCESS" >> $LOG_FILE
		rm $FILEN
	    else
		echo "FAILED, we try again in 1 second"
		echo "FAILED, we try again in 1 second" >> $LOG_FILE
	    fi
	fi
    done
    sleep 1
done
