#!/bin/bash

# Script to run mininet and iperf test

ROOT=$(pwd)
EXEC_FILE="run-mptcp-mininet.py"
PY3_CMD=$(which python3)
IPERF_FILE="output.txt"

# How many rounds per test
RUNS_PER_TEST=5

# delay settings
INTF_RTTS=("0ms" "10ms" "20ms" "50ms" "100ms" "200ms" "300ms" "500ms" "1000ms")

# congestion algorithms
# ensure to have algorithms pre-loaded with modprobe
#CCAS=("cubic" "balia" "bbr" "bic" "hybla" "lia" "olia" "reno" "veno" "vegas" "wvegas")
CCAS=("cubic" "bbr" "bic" "lia" "vegas")

######################## EXECUTE RUNS ###########################
len_rtts=${#INTF_RTTS[@]}
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

        rtt_dir="${INTF_RTTS[$rtt]}"
        echo "create directory $rtt_size_dir..."
        mkdir $cca_dir/$rtt_dir

        for (( run=1; run<=$RUNS_PER_TEST; run++ )); do
            echo -e "\n\nSTARTING RUN $run: ${INTF_RTTS[$rtt]} delay on eth1\n\n"

            # execute mininet
            sudo $PY3_CMD $ROOT/$TEST_FILE ${INTF_RTTS[$rtt]}

            # move output.txt
            mv $IPERF_FILE $cca_dir/$rtt_dir/iperf-run_$run-${INTF_RTTS[$rtt]}

            echo "pausing to ensure capture..."
            sleep 3
        done # end run
    done # end rtt
done # end cca

######################### Cleanup #################################

echo -e "\nremoving traffic control rules from $INTF_1"
sudo tc qdisc del dev $INTF_1 root netem
tc qdisc show dev $INTF_1

echo -e "\nreset congestion control  algorithm to cubic"
sudo sysctl -w net.ipv4.tcp_congestion_control=cubic

######################### End ####################################

echo -e "\n\nprogram ending"
