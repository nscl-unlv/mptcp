#!/bin/bash

################## Global Varibales #############

ROOT=$(pwd)

# get mptcp settings
RUNTIME_PARAMS=$(sudo sysctl -a)
CONGESTION_ALG=$(echo "$RUNTIME_PARAMS" | grep net.ipv4.tcp_congestion_control | cut -d= -f2 | awk '{print $1}')
PATH_MANAGER=$(echo "$RUNTIME_PARAMS" | grep net.mptcp.mptcp_path_manager | cut -d= -f2 | awk '{print $1}')
SCHEDULER=$(echo "$RUNTIME_PARAMS" | grep net.mptcp.mptcp_scheduler | cut -d= -f2 | awk '{print $1}')

NEW_FILE_NAME="$SCHEDULER-$CONGESTION_ALG-$PATH_MANAGER"

################## Functions ##################

create_results_folder() {
    if [ ! -d "$ROOT/results" ]; then
        echo "creating results folder..."
        mkdir $ROOT/results
    fi
}

clear_results() {
    echo "removing previous test files..."
    rm -rf $ROOT/results/*
    echo ""
}

execute_mptcp_test() {
    echo "executing mptcp_test.py..."
    PY3_CMD=$(which python3)
    sudo $PY3_CMD $ROOT/mptcp_test.py
}

parse_iperf_files() {
    for f in $ROOT/iperf*.txt; do
        local file_name=$(basename $f | cut -d. -f1)
        echo "parsing $file_name..."
        awk '/[0-9]*\.[0-9]* .Bytes/ {split($3,a,"-"); print a[2], $7}' $f | head -n -2 > $file_name.dat
    done
}

plot_client_bandwidth() {
    local script="$ROOT/scripts/plot.sh"
    local data="iperf_bandwith_client_log.dat"
    local output="$SCHEDULER-$CONGESTION_ALG-$PATH_MANAGER.png"
    local title="$SCHEDULER-$CONGESTION_ALG-$PATH_MANAGER"
    gnuplot -c $script $data $output $title
}

rename_client_logs() {
    for f in $ROOT/iperf*_client_*.*; do
        extention=$(basename $f | cut -d. -f2)
        sudo mv $f $NEW_FILE_NAME-client.$extention
    done
}

rename_server_logs() {
    for f in $ROOT/iperf*_server_*.*; do
        extention=$(basename $f | cut -d. -f2)
        sudo mv $f $NEW_FILE_NAME-server.$extention
    done
}

################## Main #######################

main() {
    create_results_folder
    clear_results

    # show current network settings
    ./scripts/network-settings.sh

    execute_mptcp_test
    parse_iperf_files
    plot_client_bandwidth
    rename_client_logs
    rename_server_logs

    echo "test complete, moving iperf files to ./results"
    mv $NEW_FILE_NAME*.* ./results
}

main
