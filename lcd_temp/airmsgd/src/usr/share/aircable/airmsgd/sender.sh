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

function generic_send(){
	XML=$($2 $1)
	echo -e "$XML" >> $LOG_FILE

	REPLY=$($APP_DIR/send.sh "$XML")
	echo -e "$REPLY" >> $LOG_FILE
}

function generic_prepare(){
    let count=0
    FOLDER="/tmp/airmsgd/divide.$RANDOM"
    mkdir -p $FOLDER
    
    mount -osize=10m tmpfs $FOLDER -t tmpfs
    
    for i in $FILES ; do
    
	cp $TEMPERATURE_DIR/$i $FOLDER
	let count++
	
	if [ $count -ge 100 ]; then
	    generic_send $FOLDER $1
	    rm $FOLDER/*
	    let count=0
	fi
    done
    
    echo "end"
    
    generic_send $FOLDER $1
    
    rm -rf $FOLDER/*
    
    umount $FOLDER
    rmdir $FOLDER
    
}

function temperature_prepare(){
    generic_prepare "$APP_DIR/temperature/genxml.sh"
}

function battery_prepare(){
    generic_prepare "$APP_DIR/battery/genxml.sh"
}

LOG_FILE="/dev/null"
LOG_DIR="/var/log/airmsgd"

if [ -f /etc/aircable/airmsgd.conf ]; then
    source /etc/aircable/airmsgd.conf
fi
    

APP_DIR="/usr/share/aircable/airmsgd/"

#APP_DIR="."

TEMPERATURE_DIR="/tmp/airmsgd/temperature"
BATT_DIR="/tmp/airmsgd/batt"

while [ 1 ];
do
    FILES=$( ls $TEMPERATURE_DIR )
    
    if [ -n "$FILES" ]; then
	temperature_prepare

	battery_prepare
    
	for i in $FILES; do
	    rm -rf $TEMPERATURE_DIR/$i
	done
    fi
    
    sleep 60
done
