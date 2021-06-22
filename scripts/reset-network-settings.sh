#!/bin/bash

# resets default congestion algorithm and mptcp settings

echo "Reseting congestion control and mptcp settings..."
sudo sysctl -w net.ipv4.tcp_congestion_control=cubic
sudo sysctl -w net.mptcp.mptcp_scheduler=default
sudo sysctl -w net.mptcp.mptcp_path_manager=fullmesh
