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
#   This script will test a device connected to a certain TTY.
#   It will not check for CTS so far.
# 
#

function getLock(){
	mkdir -p "$WORK"/tty/"$DEV" 2>/dev/null
	if mkdir "$WORK"/tty/"$DEV"/lock 2>/dev/null
	then
		echo "working with $DEV";
	else
		echo "oops, someone else is working with this tty."
		exit 0
	fi
}

function cleanUP(){
	rm -rf "$WORK"/tty/"$DEV";
	exit -1
}

function READ(){	
	data="";
	while true; do		
		data=$(/boot/uploader/rtty /dev/"$DEV");
		if [ ! -z "${data}" ]
		then 
			#echo -e "$data";		
			RES=$(echo -e "$data" | grep "$1")
			if [ ! -z "$RES" ]
			then	
				return 1;
			fi
		fi		
		return 0;	
	done
	
}

function WRITE(){
	echo -e "$1" > "$2"	
}

function initiate(){
	let I=0
	
	WRITE "+++" "$1"

	sleep 10

	READ "AIRcable" "$1"	

	if [ $? -gt 0 ]
	then
		WRITE "l" /dev/"$DEV"
		READ "\<BT Address\>" /dev/"$DEV"
		if [ $? -gt 0 ]
		then
			I=`expr index "$RES" 'Address'`
			RES=${RES:$I+7};
			RES=${RES:0:2}:${RES:2:2}:${RES:4:2}:${RES:6:2}:${RES:8:2}:${RES:10:2}
			mkdir -p "$WORK"/"$RES" 2>/dev/null
			if mkdir "$WORK"/"$RES"/lock 2>/dev/null
			then
				return 1
			fi	
		fi
	fi

	WRITE "e" $1

	return 0
}

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]
then
	echo "Usage $0 tty script work_folder";
	echo "tty must not contain the /dev/"
	exit -1;
fi

DEV=$1
SCRIPT=$2
WORK=$3
ADDR=""

getLock;

stty -F /dev/"$DEV" 115200 -parenb -parodd cs8 hupcl -cstopb cread clocal crtscts ignbrk -brkint -ignpar -parmrk -inpck -istrip -inlcr -igncr -icrnl -ixon -ixoff -iuclc -ixany -imaxbel -iutf8 -opost -olcuc -ocrnl -onlcr -onocr -onlret -ofill -ofdel nl0 cr0 tab0 bs0 vt0 ff0 -isig -icanon -iexten -echo -echoe -echok -echonl -noflsh -xcase -tostop -echoprt -echoctl -echoke

sleep 5

trap cleanUP SIGHUP SIGINT SIGTERM

while true
do
	initiate /dev/"$DEV"

	if [ $? -gt 0 ]
	then	
		DEVICE=$RES
		echo "Working with $DEVICE"
		touch "$WORK"/"$DEVICE"/script.running
		# open script
		exec 6<"$SCRIPT"
		# read script
		while read -u 6 line_
		do
			if [ ! -z "$line_" ] &&  ! [[ "$line_" =~ '^[#]' ]] && ! [[ "$line_" =~ '^\s' ]]
			then
				touch "$WORK"/"$DEVICE"/script.running."$line_"
  				echo "$line_"
				if [ ${#line_} -gt 1 ]
				then
					WRITE "$line_\n\r" /dev/"$DEV"
				else
					WRITE "$line_" /dev/"$DEV"
				fi
				sleep 5
				READ "\<$line_\>" /dev/"$DEV"
				if [ $? -le 0 ]
				then
					touch "$WORK"/"$DEVICE"/script.failed."$line_"
				fi
			fi 
		done

		touch "$WORK"/"$DEVICE"/done.script
		rmdir "$WORK"/"$DEVICE"/lock
		echo "$DEVICE" done
		# close script file
		exec 6<&-
		
		# end process
		WRITE "e" /dev/"$DEV"
		sleep 2m
	else
		WRITE "e" /dev/"$DEV"
		sleep 30s
	fi	
done


