#!/usr/bin/env python3
"""
Runs a mptcp iperf3 test between a single client and server.
Path 1 remains constant while Path 2 delay increases.


Mininet Topography

 _ _S3_ _
 |       |
H1      H2
 |__S4_ _|


Test Prerequisites
- enable MPTCP
- set congestion control algorithm
- set path manager
- set scheduler

Notes
Do not add delay on the client (sender) links.  Mininet does not use TSQ small
queues (TSQ), thus does not emulate MPTCP correctly.  Source: Mininet/Netem
Emulation Pitfalls by Alexander Frommgen.
"""

import time
from mininet.cli import CLI
from mininet.net import Mininet
from mininet.link import TCLink
import sys


# read in delay (i.e. '10ms')
DELAY = sys.argv[1]

# Packet loss
LOSS = 0.1

# interface bandwidth
BANDWIDTH = 1000

# Iperf3 summary file name
OUTPUT_FILE="output.txt"

# Test time in seconds
TIME = 11

net = Mininet(cleanup=True)

# setup host, switch and controller
# h1 -> client, h2 -> server
c0 = net.addController('c0')
h1 = net.addHost('h1', ip='10.0.1.1')
h2 = net.addHost('h2', ip='10.0.2.1')
s3 = net.addSwitch('s3')
s4 = net.addSwitch('s4')

# add links to host-1
# NOTE: do NOT add delay  or bandwidth for client (sender) links
net.addLink(h1, s3, cls=TCLink)
net.addLink(h1, s4, cls=TCLink)

# add links to host-2
net.addLink(h2, s3, cls=TCLink,
            bw=BANDWIDTH, loss=LOSS)
# delay ONLY on Path 2
net.addLink(h2, s4, cls=TCLink,
            bw=BANDWIDTH, delay=DELAY, loss=LOSS)

h1.setIP('10.0.1.1', intf='h1-eth0')
h1.setIP('10.0.1.2', intf='h1-eth1')

h2.setIP('10.0.2.1', intf='h2-eth0')
h2.setIP('10.0.2.2', intf='h2-eth1')

# routing rules client
h1.cmd('ip route flush all proto static scope global')
h1.cmd('ip rule add from 10.0.1.1 table 1')
h1.cmd('ip rule add from 10.0.1.2 table 2')

h1.cmd('ip route add 10.0.1.0/24 dev h1-eth0 link table 1')
h1.cmd('ip route add default via 10.0.1.1 dev h1-eth0 table 1')

h1.cmd('ip route add 10.0.1.0/24 dev h1-eth1 link table 2')
h1.cmd('ip route add default via 10.0.1.2 dev h1-eth1 table 2')

# routing rules server
h2.cmd('ip route flush all proto static scope global')
h2.cmd('ip rule add from 10.0.2.1 table 1')
h2.cmd('ip rule add from 10.0.2.2 table 2')

h2.cmd('ip route add 10.0.2.0/24 dev h1-eth0 link table 1')
h2.cmd('ip route add default via 10.0.2.1 dev h2-eth0 table 1')

h2.cmd('ip route add 10.0.2.0/24 dev h1-eth1 link table 2')
h2.cmd('ip route add default via 10.0.2.2 dev h2-eth1 table 2')


def start_test():
    ''' start iperf3 test '''

    print('starting iperf server at', h2.IP())
    h2.cmd('iperf3 -s -i 1.0 -f m &')

    print('starting iperf client at', h1.IP(), ', connect to ', h2.IP())
    h1.cmd(f'iperf3 -t 1.0 '
           f'-f m -i 1.0 -c {h2.IP()} '
           f'> {OUTPUT_FILE} &')

    time.sleep(TIME) # iperf runs for 10 seconds


net.start()
time.sleep(1)  # wait for net to startup
start_test()
net.stop()
