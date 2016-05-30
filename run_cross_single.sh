#!/bin/bash

apps="bt.C.x cg.C.x dc.B.x ep.D.x ft.B.x is.C.x lu.C.x mg.B.x sp.C.x ua.C.x"
apps="bt.B.x cg.B.x ep.B.x ft.B.x is.B.x lu.B.x mg.B.x sp.B.x ua.B.x"
# apps="bt.B.x cg.B.x"

function set-script {
	host=$1
	ssh $host "cat >run-node.sh" <<EOF
./run-stat.sh 0 &
statpid0=\$!
./run-stat.sh 1 &
statpid1=\$!
for app in $apps
do
	./run-app.sh "\$app"
done
kill -9 \$statpid0
kill -9 \$statpid1
wait
EOF

	ssh $host "cat >run-app.sh" <<EOF
app=\$1

sleep 180s

echo "\$1 start" > \$HOME/\${1}-stat.log
cat /sys/class/xstat/last0 >> \$HOME/\${1}-stat.log
./npbbin/\$1
echo "\$1 finish" >> \$HOME/\${1}-stat.log
cat /sys/class/xstat/last0 >> \$HOME/\${1}-stat.log
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
	ssh $host ./run-node.sh </dev/null &
done

wait
