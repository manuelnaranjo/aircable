#!/bin/bash
#
#  Copyright 2007 Wireless Cable Inc.
#
#  Author: Naranjo, Manuel Francisco <naranjo.manuel@gmail.com>
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#
#   This script is part of the new AIRcable Tester.
#   This script will launch all the tty testers for devices that match a certain
#   name pattern (regex possible)
#

function cleanUP(){
	rm -rf "$WORK"/tty/"$DEV";
	exit -1
}

echo $1
echo $2
echo $3
exit -1

if [ -z $1 ] || [ -z $2 ] || [ -z $3 ]
then
	echo "usage $0 tty_filter script work_dir"
fi

FILTER=$1
SCRIPT=$2
WORK_DIR=$3

let I=0

DEVICES=($(ls /dev/ | grep "FILTER"))
for element in $(seq 0 $((${#DEVICES[@]}-1)))
do
	DEVICES[$element]=${DEVICES[$element]/@/}
done

for element in $(seq 0 $((${#DEVICES[@]}-1)))
do
	bash /usr/share/aircable/uploader/ttytester.sh $DEVICES[$element] $SCRIPT $WORK_DIR
	PID[$element]=$!
done

trap 