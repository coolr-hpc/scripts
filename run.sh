#!/bin/bash

for node in run-1 run-2 run-3 run-4
do
ssh $node ./run-node.sh 0 &
ssh $node ./run-node.sh 1 &
done

wait
