#! /bin/bash
sqlite3 ~/tunnel.db "select * from tunnel" | awk -F\| '{print $2+50000 "\t" $3}'
