#!/bin/bash

sfile=/sys/class/xstat/stat$1
ofile=~/$2-node${1}.log

rm $ofile

echo 1 > /sys/class/xstat/reset$1

while true; do
	cat $sfile >>$ofile
	sleep 1s
done
