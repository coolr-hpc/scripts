#!/bin/bash

./deploy.sh <$1
sleep 5s
./run.sh <$1
./collect.sh <$1
