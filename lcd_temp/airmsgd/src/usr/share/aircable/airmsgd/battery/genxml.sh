#!/bin/sh
#
# AIRmsgd: generate xml (battery) file.
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

APP_PATH="/usr/share/aircable/airmsgd/battery"

#APP_PATH="./battery"

if [ -z "$1" ]
then
    echo usage $0 "Path"
    exit 1;
fi

echo "<messages>"
for file in $(ls $1); do
    
    echo -e "\t<message>"
    
    awk -F\* -f $APP_PATH/battery.xml.awk $1/$file
    
    echo -e "\t</message>"
    
done

echo -e "</messages>"

