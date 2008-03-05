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
#   This script will start inquiries and store results in work_dir
#
#   The maximun number of devices we are going to serve is hci_amount * 5
#
#

if [ -z "$1" ] || [ -z "$2" ] 
then
	echo usage $0 filter work_dir [Parent_PID];
	exit -1;
fi

FILTER=$1
WORK_DIR=$2

PARENT_PID=0

if [ ! -z "$3" ]
then
	PARENT_PID=$3;
fi

if [ ! -d "$WORK_DIR" ]	
then
	mkdir "$WORK_DIR"
	chmod -R u=rwx,g=rwx,o=rwx "$WORK_DIR"

fi

while [ 1 ]
do
	hcitool scan --flush --info 1> 	/dev/null

	MATCH=`hcitool scan | grep '\<'$FILTER'\>'`;

	MATCH=$(echo -e "${MATCH}" | sed -e "s/\t/ /g" | sed -e "s/\/ /\//g");

	MATCH=${MATCH:1:17};

	if [ ! -d ""$WORK_DIR"/$MATCH" ]
	then
		mkdir ""$WORK_DIR"/$MATCH"
		chmod -R u=rwx,g=rwx,o=rwx ""$WORK_DIR"/$MATCH"
		touch ""$WORK_DIR"/$MATCH/onque";
		echo "MATCH:" $MATCH

		#if [ $PARENT_PID -gt 0 ]; then
			# kill -SIGUSR1 $PARENT_PID;
		#fi	
	fi

	sleep 10;
done

exit $?
