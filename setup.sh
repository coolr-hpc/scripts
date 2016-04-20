#!/bin/bash

sudo bash -c  'cat >>/etc/hosts' <<EOF
10.140.83.45	run-1
10.140.83.46	run-2
10.140.83.47	run-3
10.140.83.48	run-4
EOF

for host in run-1 run-2 run-3 run-4; do
	scp libiomp5.so cc@$host:~
	scp xstat.ko cc@$host:~
	ssh cc@$host "sudo cp libiomp5.so /lib64"
	ssh cc@$host "sudo yum update -y && sudo yum install -y vim libcgroup libcgroup-tools"
	ssh cc@$host "sudo cgcreate -t cc -a cc -g cpuset:node0"
	ssh cc@$host "sudo cgcreate -t cc -a cc -g cpuset:node1"
	ssh cc@$host "echo '0' > /sys/fs/cgroup/cpuset/node0/cpuset.mems"
	ssh cc@$host "echo '1' > /sys/fs/cgroup/cpuset/node1/cpuset.mems"
	ssh cc@$host "echo '0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,42,44,46' > /sys/fs/cgroup/cpuset/node0/cpuset.cpus"
	ssh cc@$host "echo '1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39,41,43,45,47' > /sys/fs/cgroup/cpuset/node1/cpuset.cpus"
	scp -r npbbin cc@$host:~
	ssh cc@$host "sudo insmod xstat.ko"
	ssh cc@$host "sudo echo on >/sys/class/xstat/ctrl"
done
