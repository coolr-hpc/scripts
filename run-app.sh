#!/bin/bash

app=$2
node=$1
T=600

./run-stat.sh $1 $2 &
statpid=$!
stime=$(date +%s)
while true; do
cgexec -g cpuset:node$1 ./npbbin/$2
etime=$(date +%s)
if [ $(( $stime + $T )) -lt $etime ]; then
break
fi
done
kill -9 $statpid

