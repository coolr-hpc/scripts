#!/bin/bash

apps="bt.C.x cg.C.x dc.B.x ep.D.x ft.B.x is.C.x lu.C.x mg.B.x sp.C.x ua.C.x"

cat >run-stat.sh <<EOF
sfile=/sys/class/xstat/stat\$1
ofile=\$HOME/\$2-node\${1}.log

rm -f \$ofile

echo 1 >/sys/class/xstat/reset\$1

while true; do
	cat \$sfile >>\$ofile
	sleep 1s
done
EOF

chmod +x run-stat.sh

T=600
./run-stat.sh 0 fan
statpid0=$!
./run-stat.sh 1 fan
statpid1=$!


for app in $apps
do
for node in 0 1
do
	sleep 180s
	stime=$(date +%s)
	while true; do
		cgexec -g cpuset:node$node ~/nbpbin/$app
		etime=$(date +%s)
		if [ $(( $stime + $T )) -lt $etime ]; then
			break
		fi
	done
done
done

kill -9 $statpid0
kill -9 $statpid1
