#!/bin/bash
./test.sh $1
./top_pipelined
cat output.log | tools/spike-dasm > pipelined.log