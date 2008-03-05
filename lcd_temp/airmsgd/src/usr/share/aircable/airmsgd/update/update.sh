#!/bin/bash
#
# Update a bluetooth device
#
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

APP_DIR="/usr/share/aircable/airmsgd/update"

#APP_DIR="./update"
PAR_DIR="/usr/share/aircable/airmsgd"
WRK_DIR="/tmp/airmsgd/update"

if [ -z "$1" ] || [ -z "$2" ] ; then
    echo "Usage: $0 btaddr message"
    exit 0
fi

WORK_DIR=$WRK_DIR/$1

mkdir -p $WORK_DIR

echo "Parsing settings from LCD" 
echo "Parsing settings from LCD"  >> $LOG_FILE

# peer address
PEER=$( hcitool dev | awk -f $APP_DIR/parsepeer.awk );

REQUEST=$( echo "$1|$2" | awk -F\| -f $APP_DIR/requestxml.awk )

echo -e "$REQUEST" >> $LOG_FILE

RESPONSE=$( $PAR_DIR/send.sh "$REQUEST" )

echo -e "$RESPONSE" >> $LOG_FILE

PRESPONSE=$( echo -e "$RESPONSE" | xmlparse )

echo -e "$PRESPONSE" >> $LOG_FILE

FILE="AIRcable.bas.tmp.$RANDOM"

touch $FILE

NVERSION=$( echo -e "$PRESPONSE" | grep '\<basicversion\>' | awk '{print $2}' )

NTYPE=$( echo -e "$PRESPONSE" | grep "\<type\>" | awk '{print $2}' )

if [ -z "$NTYPE" ]; then
    NTYPE="monitor"
fi

if [ -n "$NVERSION" ]; then
    echo New version of code: $NVERSION
    URL=$( echo -e "$PRESPONSE" | grep "\<basicurl\>" | awk '{print $2}' )
    
    curl -S -s -o $WORK_DIR/$FILE $URL/$NTYPE/tags/$NVERSION/AIRcable.bas >> $LOG_FILE
    
    NPEER=$( echo -e "$2" | awk -F\| '{ print $2 }' )
    
    echo 3 $NPEER >> $WORK_DIR/$FILE
    
    echo 'Got New Code'
fi

echo -e "$PRESPONSE"

NPEER=$( echo -e "$PRESPONSE" | grep "\<peer\>" | awk '{print $2}' | sed 's/\://' )
if [ -n "$NPEER" ]; then
    echo 3 $NPEER >> $WORK_DIR/$FILE
fi

NRATE=$( echo -e "$PRESPONSE" | grep "\<sendrate\>" | awk '{print $2}' )
if [ -n "$NRATE" ]; then
    echo 4 $NRATE >> $WORK_DIR/$FILE
fi

NCAL=$( echo -e "$PRESPONSE" | grep "\<kcalibration\>" | awk '{print $2}' | sed 's/\/r//' )
if [ -n "$NCAL" ]; then
    echo 5 $NCAL >> $WORK_DIR/$FILE
fi
 

NCON=$( echo -e "$PRESPONSE" | grep "\<lcdcontrast\>" | awk '{print $2}' | sed 's/\/r//' )
if [ -n "$NCON" ]; then
    echo 6 $NCON >> $WORK_DIR/$FILE
fi

NPROBE=$( echo -e "$PRESPONSE" | grep "\<probe\>" | awk '{print $2}' | sed 's/\/r//' )
if [ -n "$NPROBE" ]; then
    echo 7 $NPROBE >> $WORK_DIR/$FILE
fi

NTEMPTYPE=$( echo -e "$PRESPONSE" | grep "\<temptype\>" | awk '{print $2}' | sed 's/\/r//' )
if [ -n "$NTEMPTYPE" ]; then
    echo $NTEMPTYPE | awk -f $APP_DIR/parsestemp2.awk >> $WORK_DIR/$FILE
fi

NNAME=$( echo -e "$PRESPONSE" | grep "\<visiblename\>" | awk '{print $2}' | sed 's/\/r//' )
if [ -n "$NNAME" ]; then
    echo 16 $NNAME >> $WORK_DIR/$FILE
fi

NWELCOME=$( echo -e "$PRESPONSE" | grep "\<welcometext\>" | awk '{print $2}' | sed 's/\/r//' )
if [ -n "$NWELCOME" ]; then
    echo 17 $NWELCOME >> $WORK_DIR/$FILE
fi

echo "" >> $WORK_DIR/$FILE

cat $WORK_DIR/$FILE | tail -n 20

mv $WORK_DIR/$FILE $WORK_DIR/AIRcable.bas

echo "Generated Basic File" >> $LOG_FILE

echo "Updating device" >> $LOG_FILE

cat $WORK_DIR/AIRcable.bas >> $LOG_FILE

obexftp -b $1 -B 3 -p $WORK_DIR/AIRcable.bas >> $LOG_FILE

echo "Updated device" >> $LOG_FILE

rm -rf $WORK_DIR

