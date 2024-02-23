#!/bin/bash
./top_bsv
cat output.log | tools/spike-dasm > multicycle.log