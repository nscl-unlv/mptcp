#!/usr/bin/env python3
import time
import config
import os
from mininet.net import Mininet
from mininet.link import TCLink

for k in range(5): #CAA
    # add command for CCA 
    os.sys('sudo sysctl -w net.ipv4.tcp_congestion_control ={config.CCA[k]}')
    for i in range(8):  #delay
        for j in range(2): #file size
            net = Mininet(cleanup=True)

            # setup host, switch and controller
            # h1 -> client, h2 -> server
            h1 = net.addHost('h1', ip='10.0.1.1')
            h2 = net.addHost('h2', ip='10.0.2.1')
            s3 = net.addSwitch('s3')
            c0 = net.addController('c0')

            # add links to host-1
            # NOTE: do not add delay for client (sender) links
            net.addLink(h1, s3, cls=TCLink, 
                        bw=config.BANDWIDTH)

            # add links to host-2
            net.addLink(h2, s3, cls=TCLink,
                        bw=config.BANDWIDTH, 
                        delay=config.DELAY[i])

            h1.setIP('10.0.1.1', intf='h1-eth0')
            h2.setIP('10.0.2.1', intf='h2-eth0')

            net.start()

            time.sleep(1)  # wait for net to startup (unless this, it might won't work...)


            def start_test():
                ''' start iperf3 test '''

                print('starting iperf server at', h2.IP())
                h2.cmd('iperf3 -s -i 1.0 -f m > iperf_bandwith_server_log.txt &')

                print('starting iperf client at', h1.IP(), ', connect to ', h2.IP())
                h1.cmd(f'iperf3 -t {str(config.TEST_DURATION)} -f m -i {config.FILE_SIZE[j]} '
                    f'-c {h2.IP()} > iperf_bandwith_client_log_{config.CCA[k]}_{config.FILE_SIZE[j]}_{config.DELAY[i]}.txt &')

                time.sleep(config.TEST_DURATION + 5)

            start_test()
            net.stop()
