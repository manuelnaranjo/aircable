#!/bin/bash

REMOTE_SSL_NAME="root"
REMOTE_SSL_SERVER="192.168.1.105"
REMOTE_SSL_PORT="22"

FREE_PORT="/usr/bin/freeport.sh"

ID=$(md5sum $HOME/.ssh/id_rsa | awk '{ print $1 }')
MEMO=$(hcitool dev | grep hci | awk '{print $2}')

if [ -z "$TUNEL_CONFIG" ]; then
    TUNEL_CONFIG="/etc/tunnel.config"
fi
    
if [ -f "$TUNEL_CONFIG" ]; then
    source $TUNEL_CONFIG
fi

COMMAND=$(echo "$FREE_PORT" "$ID" "$MEMO" )

TUNNEL_PORT=$(ssh "$REMOTE_SSL_NAME@$REMOTE_SSL_SERVER" -p $REMOTE_SSL_PORT "$COMMAND")

echo "port to use: " $TUNNEL_PORT

TUNNEL_PORT=$(echo -e "$TUNNEL_PORT" | grep "[0-9]" | tail -n 1)

if [ -n "$TUNNEL_PORT" ] &&  [ "$TUNNEL_PORT" -ge 0 ]; then
    COMMAND="ssh -nNR $TUNNEL_PORT:localhost:22 $REMOTE_SSL_NAME@$REMOTE_SSL_SERVER -p $REMOTE_SSL_PORT &"
    
    echo "Creating tunnel with: $COMMAND"
    
    $COMMAND

    if [  $? -eq 1 ]; then
	sleep 5m
    fi
fi
