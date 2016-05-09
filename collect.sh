#!/bin/bash

d=$(date "+%b%d%H%M")
hosts=$( awk '{print $2}' )
for host in $hosts; do
mkdir -p ~/data/$d/$host
scp $host:~/*.log ~/data/$d/$host
done

