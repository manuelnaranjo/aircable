#!/bin/bash

RSA_SHARED_KEY="some url where you have your shared (daily updated rsa key"
SSH_SERVER="your ssh server ip or url"
SSL_NAME="ssh user name"
SSL_SERVER="ssh server"
SSL_PORT="ssh port to use"

wget -O id_rsa_shared.txt $RSA_SHARED_KEY
mv id_rsa_shared.txt id_rsa_shared
mkdir -p /root/.ssh/

echo "host $SSH_SERVER" >> /root/.ssh/config
echo -e "\tStrictHostKeyChecking no" >> /root/.ssh/config
echo -e "\tForwardX11 yes" >> /root/.ssh/config
echo "" >> /root/.ssh/config 

echo "REMOTE_SSL_NAME=\"$SSL_NAME\"" >> /etc/tunnel.config
echo "REMOTE_SSL_SERVER=\"$SSL_SERVER\"" >> /etc/tunnel.config
echo "REMOTE_SSL_PORT=\"$SSL_PORT\"" >> /etc/tunnel.config
echo '' >> /etc/tunnel.config

/usr/bin/ssh-keygen -t rsa -f /root/.ssh/id_rsa -N ''

chmod 0600 id_rsa_shared

ssh -i id_rsa_shared $SSL_NAME@$SSL_SERVER bin/addkey "$(cat /root/.ssh/id_rsa.pub)"

echo $(ssh $SSL_NAME@$SSL_SERVER cat .ssh/id_rsa.pub) >> /root/.ssh/authorized_keys

echo "tun:2345:respawn:/usr/bin/tunnel.sh" >> /etc/inittab

telinit q
