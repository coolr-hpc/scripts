#!/bin/bash

apps="bt.C.x cg.C.x dc.B.x ep.D.x ft.B.x is.C.x lu.C.x mg.B.x sp.C.x ua.C.x"
# apps="bt.C.x cg.C.x"

function set-script {
	host=$1
	ssh $host "cat >run-node.sh" <<EOF
./run-stat.sh \$1 &
statpid=\$!
for app in $apps
do
	./run-app.sh "\$1" "\$app"
done
kill -9 \$statpid
wait
EOF

	ssh $host "cat >run-app.sh" <<EOF
app=\$2
node=\$1

T=400

sleep 180s

echo \$1 \$2

stime=\$(date +%s)
echo "\$2 start" > \$HOME/\${2}-node\${1}-stat.log
cat /sys/class/xstat/last\$1 >> \$HOME/\${2}-node\${1}-stat.log
while true; do
cgexec -g cpuset:node\$1 ./npbbin/\$2
etime=\$(date +%s)
if [ \$(( \$stime + \$T )) -lt \$etime ]; then
break
fi
done
echo "\$2 finish" >> \$HOME/\${2}-node\${1}-stat.log
cat /sys/class/xstat/last\$1 >> \$HOME/\${2}-node\${1}-stat.log
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
