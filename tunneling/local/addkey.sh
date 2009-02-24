#! /bin/bash

for i in $(ls $HOME/keys)
do
	cat $HOME/keys/$i >> $HOME/.ssh/authorized_keys
	rm -f $HOME/keys/$i
done

