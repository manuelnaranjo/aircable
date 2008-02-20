#!/bin/bash
# Parses the received temperature message
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

LOG_FILE="/dev/null";

if [ -f /etc/aircable/airmsgd.conf ]; then
    source /etc/aircable/airmsgd.conf
fi

APP_DIR="/usr/share/aircable/airmsgd/temperature"

#APP_DIR="./temperature"

if [ -z $1 ] || [ -z $2 ]; then
    echo "Usage: $0 dir file"
    exit 0
fi

CONTENT=$(cat $1/$2)

echo $CONTENT >> $LOG_FILE

BODY=$(grep "BODY" $1/$2);

# Get temperature and type of node
PAR=$( echo $BODY | awk -f $APP_DIR/parse1.awk | LC_ALL=en_us awk -f $APP_DIR/parse2.awk) 

ADDR=${2:0:17}

DATE=$( LC_ALL=en_us date -u )

echo $DATE*$ADDR*$PAR >> $LOG_FILE
echo $DATE*$ADDR*$PAR
