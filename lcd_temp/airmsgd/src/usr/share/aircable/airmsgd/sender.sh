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

LOG_FILE="/dev/null"

#APP_DIR="/usr/share/aircable/airmsgd/"

APP_DIR="."

LOG_DIR="/var/log/airmsgd"
TEMPERATURE_DIR="/tmp/airmsgd/temperature"
BATT_DIR="/tmp/airmsgd/batt"

while [ 1 ];
do
    FILES=$( ls $TEMPERATURE_DIR )
    
    if [ -n "$FILES" ]; then
	XML=$($APP_DIR/temperature/genxml.sh $TEMPERATURE_DIR)
	echo -e "$XML"

	REPLY=$($APP_DIR/send.sh "$XML")
	echo -e "$REPLY"
	CONT=$( echo "$REPLY" | grep "\<recorded\>" ) ;
	
	if [ -n "$CONT" ]; then
	    echo "Server got readings"
	    for i in $FILES
	    do
		rm $TEMPERATURE_DIR/$i
	    done
	else
	    echo "Server didn't got readings"
	fi
    fi
    
    FILES=$( ls $BATT_DIR )
    
    if [ -n "$FILES" ]; then
	XML=$($APP_DIR/battery/genxml.sh $BATT_DIR)
	echo -e "$XML"

	REPLY=$($APP_DIR/send.sh "$XML")
	echo -e "$REPLY"
	CONT=$( echo "$REPLY" ) ;
	

	echo "Server got readings"
	for i in $FILES
	do
	    rm $BATT_DIR/$i
	done
    fi
    
    sleep 60
done
