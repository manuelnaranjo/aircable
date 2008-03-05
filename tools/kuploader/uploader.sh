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
#   This script will launch the obexftp command for each new AIRcable is found. 
#   Five process will be launched  by the main.sh per BT dongle found. 
#

function cleanUp(){
	rm -f $TEMP
	rmdir "$WORK_DIR"/"$DEVICE"/lock;
	hcitool dc $DEVICE
	if [ ! -z $PARENT_PID ]; then
		kill -SIGUSR1 $PARENT_PID;
	fi
	exit -1;
}

if [ -z "$1" ] || [ -z "$2" ]  || [ -z "$3" ]
then
	echo usage $0 "files_path device work_dir [Parent_PID] [hci]";
	exit -1;
fi

FILE=$1
DEVICE=$2
WORK_DIR=$3
TEMP=/tmp/aircable.$RANDOM

if [ ! -z "$4" ]; then
	PARENT_PID=$4;
fi

if [ ! -z "$5" ]; then
	HCI=$5;
else
	HCI=""
fi

if mkdir "$WORK_DIR"/"$DEVICE"/lock 2>/dev/null
then
	echo "working with $DEVICE";
else
	echo "oops, someone else is working."
	exit -1
fi

rm -f "$WORK_DIR"/"$DEVICE"/onque;
touch "$WORK_DIR"/"$DEVICE"/connecting;

I=1

while [ $I -lt 10 ]; 
do
	if [ ! -z $HCI ]; then
		hcitool -i $HCI cc $DEVICE > $TEMP
	else
		hcitool cc $DEVICE > $TEMP
	fi

	TMP= $(cat $TEMP)

	if [ -n "$TMP" ]; 
	then
		let I=I+1;
		if [ $I -gt 3 ]; then	
			touch "$WORK_DIR"/"$DEVICE"/failure;	
			cleanUp
		fi
		sleep 1;
	else
		rm -f "$WORK_DIR"/"$DEVICE"/connecting;
		touch "$WORK_DIR"/"$DEVICE"/auth;
		let I=10;
    	fi
done

I=1

while [ $I -lt 10 ]; do

	if [ ! -z $HCI ]; then
		hcitool -i $HCI auth $DEVICE > $TEMP
	else
		hcitool auth $DEVICE > $TEMP
	fi

	TMP= $(cat $TEMP)

	if [ -n "$TMP" ]; then
		let I=I+1;
		if [ $I -gt 3 ]; then	
			touch "$WORK_DIR"/"$DEVICE"/failure;	
			cleanUp
		fi
		sleep 1;
	else
		rm -f "$WORK_DIR"/"$DEVICE"/auth;
		touch "$WORK_DIR"/"$DEVICE"/key;
		let I=10;
	fi
done

I=1
while [ $I -lt 10 ]; do


	if [ ! -z $HCI ]; then
		hcitool -i $HCI key $DEVICE > $TEMP
	else
		hcitool key $DEVICE > $TEMP
	fi

	TMP= $(cat $TEMP)

	if [ -n "$TMP" ]; then
		let I=I+1;
		if [ $I -gt 3 ]; then	
			touch "$WORK_DIR"/"$DEVICE"/failure;	
			cleanUp
		fi
		sleep 1;
	else
		rm -f "$WORK_DIR"/"$DEVICE"/key;
		touch "$WORK_DIR"/"$DEVICE"/upload;
		let I=10;
	fi
done

echo $DEVICE "connected, paired";




if [ -f $FILE/AIRcable.bas ]
then
	I=1
	while [ $I -lt 10 ]; do

		if [ ! -z $HCI ]; then
			obexftp -b $DEVICE -B 4 -d $HCI -p $FILE/AIRcable.bas 2> $TEMP
			cat $TEMP
		else
			obexftp -b $DEVICE -B 4 -p $FILE/AIRcable.bas 2> $TEMP
		fi

		RESULT=$(grep '\<Sending\>.*\<AIRcable.bas\>.*\<done\>.*' $TEMP)
		
		if [ -n "$RESULT" ]; then
			touch "$WORK_DIR"/"$DEVICE"/uploaded.AIRcable.bas
			let I=10;
			echo $DEVICE "AIRcable.bas uploaded";
		else
			let I=I+1;
			if [ $I -gt 3 ]; then
				touch "$WORK_DIR"/"$DEVICE"/failed.AIRcable.bas
				echo $DEVICE "AIRcable.bas failed";
				cleanUp
			fi
			sleep 3;
		fi    
	done
fi


if [ -f $FILE/config.txt ]
then
	I=1
	while [ $I -lt 10 ]; do

		if [ ! -z $HCI ]; then
			obexftp -b $DEVICE -B 4 -d $HCI -p $FILE/config.txt 2> $TEMP
		else
			obexftp -b $DEVICE -B 4 -p $FILE/config.txt 2> $TEMP
		fi
		
		RESULT=$(grep '\<Sending\>.*\<config.txt\>.*\<done\>.*' $TEMP)
		
		if [ -n "$RESULT" ]; then
			touch "$WORK_DIR"/"$DEVICE"/uploaded.config.txt
			let I=10;
			echo $DEVICE "config.txt uploaded";
		else
			let I=I+1;
			if [ $I -gt 3 ]; then
				touch "$WORK_DIR"/"$DEVICE"/failed.config.txt
				echo $DEVICE "config.txt failed";
				cleanUp
			fi
			sleep 3;
		fi    
	done
fi


touch "$WORK_DIR"/"$DEVICE"/done.upload

echo $DEVICE "done";

cleanUp
