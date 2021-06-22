#!/bin/bash

# shows tcp congestion control algorithm and mptcp settings

# get congestion algorithm
echo "Congestion Control Algorithm"
sysctl net.ipv4.tcp_congestion_control
echo ""

# get mptcp settings
echo "MPTCP Settings"
sysctl net.mptcp.mptcp_enabled
sysctl net.mptcp.mptcp_scheduler
sysctl net.mptcp.mptcp_path_manager
echo ""
