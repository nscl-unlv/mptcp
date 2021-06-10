#!/bin/bash


# get all kernal runtime parameters
RUNTIME_PARAMS=$(sudo sysctl -a)

# get congestion algorithm
echo "Congestion Control Algorithm"
echo "$RUNTIME_PARAMS" | grep net.ipv4.tcp_congestion_control
echo ""

# get mptcp settings
echo "MPTCP Settings"
echo "$RUNTIME_PARAMS" | grep net.mptcp
echo ""

