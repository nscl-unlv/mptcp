<p align="center">
  <img src="./assets/imgs/unlv-emblem.png" width="250" />
</p>

# MultiPath TCP Research

Adivsors: Dr. Yoohwan Kim (Associate Professor), Dr. Juyeon Jo (Associate Professor)

Graduate Research Assistants: Phillipe Austria, Cholhyun Park

Undergraduate Research Assistant: Rahul Sundaresan

University: The University of Nevada, Las Vegas

## Overview

(TODO)

## Machine Pre-Requisites
* [MPTCP](https://multipath-tcp.org): kernal with multi-path TCP
* [Mininet](http://mininet.org): network simuluation. Ensure to install with python3
* [ProgMP](https://progmp.net): create custom mptcp schedulers
* Python3: for mininet api library
* Python2: for loading ProgMP schedulers
* [pipenv](https://pypi.org/project/pipenv): create virtual python environment
* [Iperf3](https://iperf.fr): for bandwidth testing

## Project Structure

* **mptcp-tests/**: individual mininet test files.
* **results/**: iperf logs and gnuplots images are moved to this after after each test.
    - this folder will automatically be created when a running a test.
* **scripts/**: utility bash scripts (i.e. show current scheduler)
* **plots/**: folder to store gnuplots

## Running a MPTCP Test

1. Install all pre-requisites.
2. Ensure the kernel with ProgMP is loaded. Use `uname -r` to check the running kernel version v4.20.
    - you can select the kernel version in the advance GRUB menu when the manchine is first starting.
4. Start the virtual python virtual environment with `pipenv shell`.
5. Install python libries with `pipenv istall`. This only needs to be done once. You may get a lock error, in that case use the option `--skip-lock`.
6. While in the root directory, run the command `make run FILE=<test_file.py>`. This executes a single mininet test.
    - <test_file.py> must exist in mininet-tests/

## Available Make Commands

* `make run-test`: Execute the Mininet test described in mptcp_test.py
* `make reset-mn`: Resets mininet. Good to run this after every test.
* `make reset-network`: Resets congestion algorithm, scheduler and path manager to cubic, default and full-mesh respectively.
* `make clean`: Clears all files in the results directory.

## MPTCP Configurations

Python commands to enable mptcp and set congestion *control algorithm*, *path-manager* & *scheduler*.

### enable mptcp
```
os.system('sysctl -w net.mptcp.mptcp_enabled=1')
```

### congestion controls:
```
os.system('sysctl -w net.ipv4.tcp_congestion_control=cubic')
os.system('modprobe mptcp_coupled && sysctl -w net.ipv4.tcp_congestion_control=lia')
os.system('modprobe mptcp_olia && sysctl -w net.ipv4.tcp_congestion_control=olia')
os.system('modprobe mptcp_wvegas && sysctl -w net.ipv4.tcp_congestion_control=wvegas')
os.system('modprobe mptcp_balia && sysctl -w net.ipv4.tcp_congestion_control=balia')
```

### path-managers:
```
os.system('sysctl -w net.mptcp.mptcp_path_manager=default')
os.system('sysctl -w net.mptcp.mptcp_path_manager=fullmesh')
os.system('echo 1 | sudo tee /sys/module/mptcp_fullmesh/parameters/num_subflows')
os.system('modprobe mptcp_ndiffports && sysctl -w net.mptcp.mptcp_path_manager=ndiffports')
os.system('echo 1 | sudo tee /sys/module/mptcp_ndiffports/parameters/num_subflows')
os.system('modprobe mptcp_binder && sysctl -w net.mptcp.mptcp_path_manager=binder')
```

### scheduler:
```
os.system('sysctl -w net.mptcp.mptcp_scheduler=default')
os.system('modprobe mptcp_rr && sysctl -w net.mptcp.mptcp_scheduler=roundrobin')
os.system('echo 1 | sudo tee /sys/module/mptcp_rr/parameters/num_segments')
os.system('echo Y | sudo tee /sys/module/mptcp_rr/parameters/cwnd_limited')
os.system('modprobe mptcp_redundant && sysctl -w net.mptcp.mptcp_scheduler=redundant')
```

## Resources
