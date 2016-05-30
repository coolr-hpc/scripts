#!/bin/bash

./deploy.sh <$1
sleep 5s
./run_cross_dual.sh <$1
./collect.sh <$1
