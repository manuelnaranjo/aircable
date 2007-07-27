#!/bin/bash
# Parses the received message
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

if [ -z $1 ]; then
    echo "Usage: $0 file [log file]"
    exit 0
fi

if [ ! -z $2 ]; then
    LOG_FILE="$2"
fi

##check if it's a message for us
## FORMAT $TIME:VAL!CORR#TYPE
BODY=$( grep -E 'BODY:\$(+|-)?[0-9]+:(+|-)?[0-9]+!(+|-)?[0-9]+\#[A-Z]$' $1 )
	
if [ -z "$BODY" ]; then    
    echo "Wrong file"
    FILE=$( cat $1 )
    echo -e "$FILE"    
    exit 1
fi

##PARSE MESSAGE $TIME:VAL!CORR#TYPE
	    
##first suppress BODY:
TOKEN=$( echo "$BODY" | sed 's/BODY:\$//g' | tr -cs '\+\-[:digit:][:alpha:]' '|' | grep . )

echo $TOKEN

exit 0
