#!/bin/bash

function deploy-host {
	hname=$1
	ssh -o StrictHostKeyChecking=no $hname "sudo yum update -y && sudo yum install -y vim libcgroup libcgroup-tools"
	scp -r ~/pkg/* $hname:~
	ssh $hname "sudo cp libiomp5.so /lib64"

	ssh cc@$hname "sudo cgcreate -t cc -a cc -g cpuset:node0"
	ssh cc@$hname "sudo cgcreate -t cc -a cc -g cpuset:node1"
	ssh cc@$hname "echo '0' > /sys/fs/cgroup/cpuset/node0/cpuset.mems"
	ssh cc@$hname "echo '1' > /sys/fs/cgroup/cpuset/node1/cpuset.mems"
	ssh cc@$hname "echo '0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,42,44,46' > /sys/fs/cgroup/cpuset/node0/cpuset.cpus"
	ssh cc@$hname "echo '1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39,41,43,45,47' > /sys/fs/cgroup/cpuset/node1/cpuset.cpus"

	ssh cc@$hname "sudo insmod xstat.ko"
	ssh cc@$hname "sudo echo on >/sys/class/xstat/ctrl"
	ssh cc@$hname "sudo echo 500 >/sys/class/xstat/period"
}

while read CMD; do
	ip=$(echo $CMD | awk '{print $1}')
	host=$(echo $CMD | awk '{print $2}')
	sudo bash -c "echo $CMD >>/etc/hosts"
	deploy-host $host &
done

wait
