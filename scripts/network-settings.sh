#!/bin/bash

# Shows tcp congestion control algorithm and mptcp settings.


# get congestion algorithm
echo "Congestion Control Algorithm"
sysctl net.ipv4.tcp_congestion_control
echo ""

# get mptcp settings
echo "MPTCP Settings"
sysctl net.mptcp.mptcp_enabled
sysctl net.mptcp.mptcp_scheduler
SCHEDULER=$(sysctl net.mptcp.mptcp_scheduler | cut -d= -f2 | awk '{print $1}') # rbs = ProgMP
sysctl net.mptcp.mptcp_path_manager
echo ""

# get ProgMP scheduler
if [[ $SCHEDULER == "rbs" ]]; then
    echo "ProgMP Scheduler"
    PROGMP_SCHEDULER=$(cat /proc/net/mptcp_net/rbs/default)
    echo $PROGMP_SCHEDULER
fi
