#!/bin/bash

apps="bt.C.x cg.C.x dc.B.x ep.D.x ft.B.x is.C.x lu.C.x mg.B.x sp.C.x ua.C.x"

function set-script {
	host=$1
	ssh $host "cat >run-node.sh" <<EOF
for app in $apps
do
	./run-app.sh "\$1" "\$app"
done
EOF

	ssh $host "cat >run-app.sh" <<EOF
app=\$2
node=\$1

T=600

sleep 180s

./run-stat.sh \$1 \$2 &
statpid=\$!
stime=\$(date +%s)
while true; do
cgexec -g cpuset:node\$1 ./npbbin/\$2
etime=\$(date +%s)
if [ \$(( \$stime + \$T )) -lt \$etime ]; then
break
fi
done
kill -9 \$statpid
EOF

	ssh $host "cat >run-stat.sh " <<EOF
sfile=/sys/class/xstat/stat\$1
ofile=\$HOME/\$2-node\${1}.log

rm -f \$ofile

echo 1 >/sys/class/xstat/reset\$1

while true; do
	cat \$sfile >>\$ofile
	sleep 1s
done
EOF

	ssh $host chmod +x run-stat.sh
	ssh $host chmod +x run-app.sh
	ssh $host chmod +x run-node.sh
}

hosts=$( awk '{print $2}' )

echo $hosts

for host in $hosts; do
	set-script $host
	ssh $host ./run-node.sh 0 </dev/null &
	ssh $host ./run-node.sh 1 </dev/null &
done

wait
