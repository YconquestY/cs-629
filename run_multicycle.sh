#!/bin/bash
./test.sh $1
./top_bsv
cat output.log | tools/spike-dasm > multicycle.log