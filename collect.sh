#!/bin/bash

hosts=$( awk '{print $2}' )
for host in $hosts; do
mkdir -p ~/data/haswell/$host
scp $host:~/*.log ~/data/haswell/$host
done

mkdir ~/data/haswell/merge
for host in $hosts; do
for f in ~/data/haswell/$host/*.log; do
fname=$(basename $f)
cp $f ~/data/haswell/merge/$host-$fname
done
done
