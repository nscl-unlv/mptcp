#!/usr/bin/env python3
"""
Runs a iperf3 test between a single client and server.


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

import config
import time
from mininet.net import Mininet
from mininet.link import TCLink


net = Mininet(cleanup=True)

# setup host, switch and controller
# h1 -> client, h2 -> server
c0 = net.addController('c0')
h1 = net.addHost('h1', ip='10.0.1.1')
h2 = net.addHost('h2', ip='10.0.2.1')
s3 = net.addSwitch('s3')
s4 = net.addSwitch('s4')

# add links to host-1
# NOTE: do not add delay for client (sender) links
net.addLink(h1, s3, cls=TCLink,
            bw=config.BANDWIDTH,
            max_queue_size=config.MAX_QUEUE_SIZE)
net.addLink(h2, s3, cls=TCLink,
            bw=config.BANDWIDTH,
            max_queue_size=config.MAX_QUEUE_SIZE,
            delay=config.DELAY)

# add links to host-2
net.addLink(h1, s4, cls=TCLink,
            bw=config.BANDWIDTH,
            max_queue_size=config.MAX_QUEUE_SIZE)
net.addLink(h2, s4, cls=TCLink,
            bw=config.BANDWIDTH,
            max_queue_size=config.MAX_QUEUE_SIZE,
            delay=config.DELAY)

h1.setIP('10.0.1.1', intf='h1-eth0')
h1.setIP('10.0.1.2', intf='h1-eth1')

h2.setIP('10.0.2.1', intf='h2-eth0')
h2.setIP('10.0.2.2', intf='h2-eth1')

net.start()

time.sleep(1)  # wait for net to startup (unless this, it might won't work...)


def under_testing():
    '''
        extra tests:
        - remove a link
        - add a link
    '''
    time.sleep(config.TEST_DURATION/3.0)
    if config.CUT_LINK:
        print('cutting link...')
        print(h1.intf('h1-eth0').ifconfig('down'))
        print('link down\n')
    time.sleep(config.TEST_DURATION/3.0)
    if config.ADD_LINK:
        print('adding a new link...\n')
        net.addLink(h1, s3, cls=TCLink,
                    bw=config.BANDWIDTH)
        s3.attach('s3-eth5')  # add interface name
        h1.setIP('10.0.1.3', intf='h1-eth2')
        print('link added\n')
    time.sleep(config.TEST_DURATION/3.0)

    time.sleep(5)  # wait (a bit) to finish


def start_test():
    ''' start iperf3 test '''

    print('starting iperf server at', h2.IP())
    h2.cmd('iperf3 -s -i 1.0 -f m > iperf_bandwith_server_log.txt &')

    print('starting iperf client at', h1.IP(), ', connect to ', h2.IP())
    h1.cmd(f'iperf3 -t {str(config.TEST_DURATION)} '
           f'-f m -i 1.0 -c {h2.IP()} '
           f'> iperf_bandwith_client_log.txt &')

    under_testing()

    print('iperf client response:')
    print(h1.cmd('cat iperf_bandwith_client_log.txt'))

    print('iperf server response:')
    print(h2.cmd('cat iperf_bandwith_server_log.txt'))


start_test()
# for link in net.links:
#     print(link)
net.stop()
