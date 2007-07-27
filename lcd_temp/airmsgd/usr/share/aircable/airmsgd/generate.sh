#!/bin/sh
#
# AIRmsgd: fill obex -> server xml file.
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


APP_PATH="/usr/share/aircable/airmsgd"
#APP_PATH="."

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]
then
    echo usage $0 "DeviceID Celcius_Temp type"
    exit 1;
fi

FAR=$(echo "$2 * 1.8 + 32" | bc -l )

# Truncate values
DOT=$(expr index $2 .)
let DOT=DOT+1
CEL=$(expr substr $2 1 $DOT)

DOT=$(expr index $FAR .)
let DOT=DOT+1
FAR=$(expr substr $FAR 1 $DOT)

DATETIME=$(date  +"%m\/%d\/%Y %H:%M:%S")
GMT=$(date +%z)

CONTENT=`sed -e "s/ID/$1/g" $APP_PATH/format.xml | 
	    sed -e "s/CELCIUS/$CEL/g" | 
	    sed -e "s/FAHRENHEIT/$FAR/g" | 
	    sed -e "s/DATETIME/$DATETIME/g" |
	    sed -e "s/GMT/$GMT/g" | 
	    sed -e "s/TYPE/$3/g" 
	    ` 

echo -e "$CONTENT"
