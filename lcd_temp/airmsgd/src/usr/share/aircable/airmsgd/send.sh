#! /bin/bash
# AIRmsgd do transaction
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

if [ -f /etc/aircable/airmsgd.conf ]; then
    source /etc/aircable/airmsgd.conf
fi

TEMP="/tmp/airmsgd/tmp"

mkdir -p $TEMP

FILE="reply.xml.$RANDOM"
FILE2="reply2.xml.$RANDOM"

curl -d "xml=$1" $URL -o $TEMP/$FILE -s -S

sed -e '/^[\n\r \x09]*$/d' $TEMP/$FILE > $TEMP/$FILE2
mv $TEMP/$FILE2 $TEMP/$FILE

cat $TEMP/$FILE
rm -f $TEMP/$FILE
