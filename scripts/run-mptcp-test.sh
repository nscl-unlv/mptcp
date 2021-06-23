#!/bin/bash

# The file does the following:
# 1.) creates a results folder if not exist.
# 2.) clears results folder (optional).
# 3.) parses iperf log files.
# 4.) creates gnuplot from log files.
# 5.) moves all files to results folder.

################## Global Varibales #############

ROOT=$(pwd)
MPTCP_TEST="mptcp_test.py"
CLEAR_RESULTS="N" # Y to clear results each run

# get mptcp settings
CONGESTION_ALG=$(sysctl net.ipv4.tcp_congestion_control | cut -d= -f2 | awk '{print $1}')
PATH_MANAGER=$(sysctl net.mptcp.mptcp_path_manager | cut -d= -f2 | awk '{print $1}')
SCHEDULER=$(sysctl net.mptcp.mptcp_scheduler | cut -d= -f2 | awk '{print $1}') # rbs = ProgMP

# get ProgMP scheduler
if [[ $SCHEDULER == "rbs" ]]; then
    SCHEDULER=$(cat /proc/net/mptcp_net/rbs/default)
    echo $PROGMP_SCHEDULER
fi

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
    sudo $PY3_CMD $ROOT/$MPTCP_TEST
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

    if [[ $CLEAR_RESULTS =~ yes|Y|y ]]; then
        clear_results
    fi

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
