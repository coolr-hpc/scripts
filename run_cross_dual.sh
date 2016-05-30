#!/bin/bash

apps="bt.C.x cg.C.x dc.B.x ep.D.x ft.B.x is.C.x lu.C.x mg.B.x sp.C.x ua.C.x"
apps="bt.A.x cg.A.x ep.A.x ft.A.x is.A.x lu.A.x mg.A.x sp.A.x ua.A.x"
# apps="bt.C.x cg.C.x"
# apps="bt.A.x"

function set-script {
	host=$1
	ssh $host "cat >run-node.sh" <<EOF
./run-stat.sh 0 &
statpid0=\$!
./run-stat.sh 1 &
statpid1=\$!
for app0 in $apps
do
for app1 in $apps
do
	./run-app.sh 0 "\$app0" "\$app0-\$app1" &
	pid0=\$!
	./run-app.sh 1 "\$app1" "\$app0-\$app1"&
	pid1=\$!
	while true; do
	if  kill -0 "\$pid0"; then
	if  kill -0 "\$pid1"; then
	continue
	fi
	fi
	break
	done
	killall -9 "\$app0"
	killall -9 "\$app1"
done
done
kill -9 \$statpid0
kill -9 \$statpid1
wait
EOF

	ssh $host "cat >run-app.sh" <<EOF
tag=\$3
app=\$2
node=\$1
lname=\$HOME/\${tag}-\${app}-node\${node}-stat.log

sleep 180s

echo \$1 \$2

echo "\$2 start" > \$lname
cat /sys/class/xstat/last\$1 >> \$lname
cgexec -g cpuset:node\$1 ./npbbin/\$2
echo "\$2 finish" >> \$lname
cat /sys/class/xstat/last\$1 >> \$lname
EOF

	ssh $host "cat >run-stat.sh " <<EOF
sfile=/sys/class/xstat/stat\$1
ofile=\$HOME/stat-node\${1}.log

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
