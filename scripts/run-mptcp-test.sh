#!/bin/bash

ROOT=$(pwd)

# create results folder
if [ ! -d "$ROOT/results" ]; then
    echo "creating results folder ..."
    mkdir $ROOT/results
fi

# clear results folder
echo "removing previous test files ..."
rm -rf $ROOT/results/*

# show current network settings
./scripts/network-settings.sh

# run test
echo "executing mptcp_test.py ..."
sudo python $ROOT/mptcp_test.py

# parse iperf files
for f in $ROOT/iperf*.txt; do
    file_name=$(basename $f | cut -d. -f1)
    echo "parsing $file_name ..."
    awk '/[0-9]*\.[0-9]* .Bytes/ {split($3,a,"-"); print a[2], $7}' $f | head -n -2 > $file_name.dat
done

# move out to results
echo "test complete, moving iperf files to ./results"
mv iperf* ./results
