#! /bin/sh
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


TEMP="/tmp/airmsgd/tmp"

mkdir -p $TEMP

curl -d "xml=$1" http://www.smart-tms.com/xmlengine/transaction.cfm -o $TEMP/reply.xml -s -S

sed -e '/^[\n\r \x09]*$/d' $TEMP/reply.xml > $TEMP/reply2.xml
mv $TEMP/reply2.xml $TEMP/reply.xml

cat $TEMP/reply.xml
rm -f $TEMP/reply.xml
