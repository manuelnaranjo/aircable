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
#   This script detects how many Bluetooth dongles are connected to the computer,
#   and in case it founds at least one, it will start with the inquiry process.
#   It will also launch all the uploaders, which will work in parallel with the inquiry.
# 
#

#$SPATH Points to where the files will be installed
#SPATH=/usr/share/aircable/uploader/
SPATH=./
SINQ=$SPATH'inquiry.sh'
SUP=$SPATH'uploader.sh'
STTY=$SPATH'ttyTester.sh'

LOCK_FILE=/tmp/aircable.lock

function kill_childs(){
	let I=0;

	M=${#PIDS[*]}
	
	while [ $I -lt $M ]
	do
		kill ${PIDS[I]};
		let I=I+1;
	done 

	rm -f /tmp/aircable;
	rm -f /tmp/aircable2;
	rm -f $LOCK_FILE;
	exit -1;
}

#function found(){
#	let I=1;

#	M=${#PIDS[*]}

#	echo "FOUND - main.sh";
	
	#while [ $I -lt $M ]
	#do
	#	kill -SIGUSR1 ${PIDS[I]};
	#	let I=I+1;
	#done
#}

function child_gone(){
	let AMOUNT_OPEN=AMOUNT_OPEN-1;
}

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]
then
	echo usage $0 "file_path filter ttyFilter [Mult]";
	exit -1;
fi

if [ -e $LOCK_FILE ]
then
    OPID=`cat $LOCK_FILE`;
    OPID=`ps -p $OPID | grep $OPID`;
    if [ -n "$OPID" ]
    then
	echo -e "There's a copy of the tool running, I can't continue\n";
	echo "PID:" $OPID;
	exit -1;
    else
	rm -f $LOCK_FILE;
	echo -e "Cleaned up LOCK File\n";
    fi
fi

echo $$ > $LOCK_FILE

FILE=$1
FILTER=$2
TTYFILTER=$3

MULT=5;

if [ ! -z "$4" ]
then
	MULT=$4;
fi

MATCH=($(hcitool dev | grep "hci[[:digit:]]*"));
HCI_COUNT=`hcitool dev | grep "hci[[:digit:]]*" | wc -l`;

let K=0

if [ $HCI_COUNT -ge 1 ]; then
	echo 'COUNT:' $HCI_COUNT;
	echo 'MATCH:';
	for element in $(seq 0 $((${#MATCH[@]}-1)))
	do
		if [[ ${MATCH[$element]} =~ "hci" ]]; then
			HCI[$K]=${MATCH[$element]}
			echo ${HCI[$K]}
			((++K))
		fi
	done
else
 	echo "ERROR, no USB dongles, can't go on";
 	exit -1;
fi

trap kill_childs SIGHUP SIGINT SIGTERM

# trap found SIGUSR1

trap child_gone SIGUSR1

let I=0; 

let AMOUNT_OPEN=0;
let MAX_OPEN=HCI_COUNT*MULT;

PIDS[0]=0;

echo "Starting inquiry.sh";
bash $SINQ $FILTER '/tmp/aircable.work' $$ & 

PIDS[$I]=$!;

((++I))
echo 'PID: '${PIDS[0]};

DEVICES=($(ls /dev/ | grep "$TTYFILTER"))
for element in $(seq 0 $((${#DEVICES[@]}-1)))
do
	DEVICES[$element]=${DEVICES[$element]/@/}
	echo "${DEVICES[$element]}"
	bash $STTY "${DEVICES[$element]}" "$FILE"/script '/tmp/aircable.work' &	
	PIDS[$I]=$!
	((++I))
done

let K=0
while [ 1 ]
do		
	while [ $AMOUNT_OPEN -lt $MAX_OPEN ]
	do
		ON_QUE=`tree -aif --noreport /tmp/aircable.work/ | grep "onque"`
		if [ ! -z $ON_QUE ]; then
			[[ $ON_QUE =~ '([[:xdigit:]][[:xdigit:]]:){5,5}([[:xdigit:]][[:xdigit:]])' ]]
			let AMOUNT_OPEN=$AMOUNT_OPEN+1;
			
			bash $SUP $FILE $BASH_REMATCH /tmp/aircable.work/ $$ "${HCI[$K]}" &

			((++K))
			if [ $K -eq $HCI_COUNT ]; then
				let K=0
			fi

			PIDS[$I]=$!;
			((++I))

			echo 'PID: '${PIDS[$I]};

		fi
		sleep 1;
	done

	sleep 2;
done

exit $?


