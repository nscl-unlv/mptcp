#!/bin/bash

# Script to run IPERF and TCPDUMP

# HOW MANY ROUNDS PER TEST
RUNS_PER_TEST=10

# interfaces and ip addresses
# kimjo-2
INTF_1="eno1"
IP_1="10.18.17.140"
#INTF_1="lo"
#IP_1="127.0.0.1"

# kimjo-1 eno1
IP_SERVER="10.18.17.15"
#IP_SERVER="127.0.0.1"

# CONSTANTS
PACKET_LOSS=0.1
PRIMARY_PATH=$IP_1
TIME_INTERVAL=1
BANDWIDTH="1000M"

# delay settings
INTF1_RTTS=("10ms" "20ms" "50ms" "100ms" "200ms" "300ms" "500ms" "1000ms")

# congestion algorithms
# ensure to have algorithms pre-loaded with modprobe
CCAS=("cubic" "balia" "bbr" "bic" "hybla" "olia" "reno" "veno" "vegas" "wvegas")

######################## EXECUTE RUNS ###########################
len_rtts=${#INTF1_RTTS[@]}
len_ccas=${#CCAS[@]}

# loop through congestion algorithms
for (( cca=0; cca<$len_ccas; cca++ )); do

    echo "changing congestion control algorithm"
    sudo sysctl -w net.ipv4.tcp_congestion_control=${CCAS[$cca]}
    cca_dir=${CCAS[$cca]}

    echo "creating directory $cca_dir..."
    mkdir $cca_dir

    # loop through delays
    for (( rtt=0; rtt<$len_rtts; rtt++ )); do
        echo "change traffic control rules on $INTF_1..."
        sudo tc qdisc add dev $INTF_1 root netem delay ${INTF1_RTTS[$rtt]} loss $PACKET_LOSS%
        tc qdisc show dev $INTF_1

        rtt_dir="${INTF1_RTTS[$rtt]}"
        echo "create directory $rtt_size_dir..."
        mkdir $cca_dir/$rtt_dir

        for (( run=1; run<=$RUNS_PER_TEST; run++ )); do
            echo -e "\n\nSTARTING RUN $run: ${INTF1_RTTS[$rtt]} delay on $INTF_1\n\n"

            echo "starting iperf: connecting to $IP_SERVER..."
            iperf3 -c $IP_SERVER -B $PRIMARY_PATH -f m \
                -i $TIME_INTERVAL -b $BANDWIDTH \
                --logfile "$cca_dir/$rtt_dir/iperf-run_$run-${INTF1_RTTS[$rtt]}.txt"

            echo "pausing to ensure capture..."
            sleep 3
        done # end run

        echo -e "\nremoving traffic control rules from $INTF_1"
        sudo tc qdisc del dev $INTF_1 root netem
        tc qdisc show dev $INTF_1
    done # end rtt
done # end cca

echo -e "\nreset congestion control  algorithm to cubic"
sudo sysctl -w net.ipv4.tcp_congestion_control=cubic

######################### end #################################

echo -e "\n\nprogram ending"
