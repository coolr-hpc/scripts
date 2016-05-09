#!/bin/bash

./deploy.sh <$1
./run.sh <$1
./collect.sh <$1
