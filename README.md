# MultiPath TCP Research

## Overview

## Machine Pre-Requisites

## MPTCP Configurations

### enable mptcp
os.system('sysctl -w net.mptcp.mptcp_enabled=1')

### congestion controls:
os.system('sysctl -w net.ipv4.tcp_congestion_control=cubic')
os.system('modprobe mptcp_coupled && sysctl -w net.ipv4.tcp_congestion_control=lia')
os.system('modprobe mptcp_olia && sysctl -w net.ipv4.tcp_congestion_control=olia')
os.system('modprobe mptcp_wvegas && sysctl -w net.ipv4.tcp_congestion_control=wvegas')
os.system('modprobe mptcp_balia && sysctl -w net.ipv4.tcp_congestion_control=balia')

### path-managers:
os.system('sysctl -w net.mptcp.mptcp_path_manager=default')
os.system('sysctl -w net.mptcp.mptcp_path_manager=fullmesh')
os.system('echo 1 | sudo tee /sys/module/mptcp_fullmesh/parameters/num_subflows')
os.system('modprobe mptcp_ndiffports && sysctl -w net.mptcp.mptcp_path_manager=ndiffports')
os.system('echo 1 | sudo tee /sys/module/mptcp_ndiffports/parameters/num_subflows')
os.system('modprobe mptcp_binder && sysctl -w net.mptcp.mptcp_path_manager=binder')

### scheduler:
os.system('sysctl -w net.mptcp.mptcp_scheduler=default')
os.system('modprobe mptcp_rr && sysctl -w net.mptcp.mptcp_scheduler=roundrobin')
os.system('echo 1 | sudo tee /sys/module/mptcp_rr/parameters/num_segments')
os.system('echo Y | sudo tee /sys/module/mptcp_rr/parameters/cwnd_limited')
os.system('modprobe mptcp_redundant && sysctl -w net.mptcp.mptcp_scheduler=redundant')

## Resources
