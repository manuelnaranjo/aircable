#!/bin/bash
# Parses the received batery message
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

APP_DIR="/usr/share/aircable/airmsgd/battery"

#APP_DIR="./battery"

if [ -z $1 ] || [ -z $2 ]; then
    echo "Usage: $0 dir file"
    exit 0
fi

CONTENT=$(cat $1/$2)

echo $CONTENT > $LOG_FILE

BODY=$(cat $1/$2 | grep "BODY" );

# Get temperature and type of node
BATT=$( echo $BODY | awk -f $APP_DIR/parse1.awk | awk -f $APP_DIR/parse2.awk);

ADDR=${2:0:17}

echo $ADDR ${BATT[0]} ${BATT[1]} >> $LOG_FILE
echo $ADDR ${BATT[0]} ${BATT[1]}

