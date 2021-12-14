#!/usr/bin/env python3


import config
import time
from mininet.cli import CLI
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
s5 = net.addSwitch('s5')

# add links to host-1
# NOTE: do not add delay  or bandwidth for client (sender) links
net.addLink(h1, s3, cls=TCLink,
            # bw=config.BANDWIDTH,
            max_queue_size=config.MAX_QUEUE_SIZE)
net.addLink(h1, s4, cls=TCLink,
            # bw=config.BANDWIDTH,
            max_queue_size=config.MAX_QUEUE_SIZE)
# add links to host-2
net.addLink(h2, s3, cls=TCLink,
            bw=config.BANDWIDTH,
            max_queue_size=config.MAX_QUEUE_SIZE,
            delay=50)
net.addLink(h2, s4, cls=TCLink,
            bw=config.BANDWIDTH,
            max_queue_size=config.MAX_QUEUE_SIZE,
            delay=50)

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

h2.cmd('ip route add 10.0.2.0/24 dev h2-eth0 link table 1')
h2.cmd('ip route add default via 10.0.2.1 dev h2-eth0 table 1')

h2.cmd('ip route add 10.0.2.0/24 dev h2-eth1 link table 2')
h2.cmd('ip route add default via 10.0.2.2 dev h2-eth1 table 2')

def under_testing():
    '''
        extra tests:
        - remove a link
        - add a link
    '''
    time.sleep(config.TEST_DURATION/3.0)
    if config.CUT_LINK:
        print('cutting link...')
        h1.intf('h1-eth0').ifconfig('down')
        h2.intf('h2-eth0').ifconfig('down')
        print('link down\n')

    time.sleep(config.TEST_DURATION/3.0)
    if config.ADD_LINK:
        print('adding a new link...\n')
        net.addLink(h1, s5, cls=TCLink,
                    # bw=config.BANDWIDTH,
                    max_queue_size=config.MAX_QUEUE_SIZE)
        net.addLink(h2, s5, cls=TCLink,
                    bw=config.BANDWIDTH,
                    max_queue_size=config.MAX_QUEUE_SIZE,
                    delay=20)

        s3.attach('s5-eth0')  # add interface name
        h1.setIP('10.0.1.3', intf='h1-eth0') # replace cut link
        h2.setIP('10.0.2.3', intf='h2-eth0') # replace cut link

        h1.intf('h1-eth0').ifconfig('up')
        h2.intf('h2-eth0').ifconfig('up')

        h1.cmd('ip rule add from 10.0.1.3 table 1')
        h2.cmd('ip rule add from 10.0.2.3 table 1')

        h1.cmd('ip route add default via 10.0.1.3 dev h1-eth0 table 1')
        h2.cmd('ip route add default via 10.0.2.3 dev h2-eth0 table 1')
        print('link added\n')

    time.sleep(config.TEST_DURATION/3.0)
def start_test():
    ''' start iperf3 test '''

    print('starting iperf server at', h2.IP())
    h2.cmd('iperf3 -s -i 1.0 -f m > iperf_bandwith_server_log_7.txt &')

    print('starting iperf client at', h1.IP(), ', connect to ', h2.IP())
    h1.cmd(f'iperf3 -t {str(config.TEST_DURATION)} '
           f'-f m -i 1.0 -c {h2.IP()} '
           f'> iperf_bandwith_client_log_7.txt &')

    under_testing()

    print('iperf client response:')
    print(h1.cmd('cat iperf_bandwith_client_log_7.txt'))

    print('iperf server response:')
    print(h2.cmd('cat iperf_bandwith_server_log_7.txt'))


net.start()
time.sleep(1)  # wait for net to startup (unless this, it might won't work...)
start_test()
# CLI(net)
net.stop()
