#!/bin/bash
./pipelined
cat output.log | tools/spike-dasm > pipelined.log