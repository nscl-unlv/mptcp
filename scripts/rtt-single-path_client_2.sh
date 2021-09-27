#!/bin/bash

# Script to run IPERF and TCPDUMP

# HOW MANY ROUNDS PER TEST
RUNS_PER_TEST=1

# interfaces and ip addresses
#INTF_1="eno1"
#IP_1="10.18.17.140"
INTF_1="lo"
IP_1="127.0.0.1"

# kimjo-1 eno1
#IP_SERVER="10.18.17.15"
IP_SERVER="127.0.0.1"

# CONSTANTS
PACKET_LOSS=0.1
PRIMARY_PATH=$IP_1

# delay settings
INTF1_RTTS=("0ms"  "10ms" "20ms" "50ms" "100ms" "200ms" "300ms" "500ms" "1000ms")

# file sizes
FILE_SIZES=("128K" "1M" "10M")

######################## EXECUTE RUNS ###########################
len_rtts=${#INTF1_RTTS[@]}
len_sizes=${#FILE_SIZES[@]}

for (( rtt=0; rtt<$len_rtts; rtt++ )); do
    for (( size=0; size<$len_sizes; size++ )); do

        echo "change traffic control rules on $INTF_1..."
        sudo tc qdisc add dev $INTF_1 root netem delay ${INTF1_RTTS[$rtt]} loss $PACKET_LOSS%
        tc qdisc show dev $INTF_1

        dir="${INTF1_RTTS[$rtt]}-${FILE_SIZES[$size]}"
        echo "create directory $dir..."
        mkdir $dir

        for (( run=1; run<=$RUNS_PER_TEST; run++ )); do
            echo -e "\n\nSTARTING RUN $run: ${INTF1_RTTS[$rtt]} delay on $INTF_1, ${FILE_SIZES[$size]}\n\n"

            echo "starting iperf: connecting to $IP_SERVER, sending size ${FILE_SIZES[$size]}..."
            iperf3 -c $IP_SERVER -B $PRIMARY_PATH -f m -n ${FILE_SIZES[$size]} -b 1000M \
                --logfile "$dir/iperf-run_$run-${INTF1_RTTS[$rtt]}-${FILE_SIZES[$size]}.txt"

            echo "pausing to ensure capture..."
            sleep 3
        done # end run

        echo -e "\nremoving traffic control rules from $INTF_1"
        sudo tc qdisc del dev $INTF_1 root netem
        tc qdisc show dev $INTF_1
    done # end size
done # end rtt

######################### end #################################

echo -e "\n\nprogram ending"
