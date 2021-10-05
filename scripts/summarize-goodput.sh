#!/bin/bash

CUR_DIR=$(pwd)
TOTAL_RUNS=10

# loop through directories
for cca in */ ; do
    #echo "$cca"

    # loop through rtt-size folder
    for rtt_size in $cca*; do
        #echo "$rtt_size"

        # loop through trial runs
        bsum=0
        for run in $rtt_size/*; do 
            # echo "$run"

            bitrate=$(cat $run | grep "receiver" | awk -F 'Bytes' '{print $2}' | sed 's/^ *//g' | cut -d ' ' -f 1)
            bsum=$(echo "$bsum + $bitrate" | bc)
        done # end run

        bavg=$(echo "$bsum/$TOTAL_RUNS" | bc -l)

        label=$(echo $rtt_size | sed 's/[/|-]/ /g')
        printf "$label %.2f\n" $bavg
    done # end rtt_size
done # end cca
