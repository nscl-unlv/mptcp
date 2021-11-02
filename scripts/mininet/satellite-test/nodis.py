import time
import config
from mininet.net import Mininet
from mininet.link import TCLink

net = Mininet(cleanup=True)

#setup
c0  = net.addController('c0')
h1 = net.addHost('h1', ip = '10.0.1.1')
h2 = net.addHost('h2', ip = '10.0.2.1')
s2 = net.addSwitch('s2')
s3 = net.addSwitch('s3')
s4 = net.addSwitch('s4')

#add link
net.addLink(h1,s2,cls = TCLink, bw = config.BANDWIDTH, max_queue_size = config.MAX_QUEUE_SIZE)
net.addLink(h1,s3,cls = TCLink, bw = config.BANDWIDTH, max_queue_size = config.MAX_QUEUE_SIZE)
net.addLink(h1,s4,cls = TCLink, bw = config.BANDWIDTH, max_queue_size = config.MAX_QUEUE_SIZE)
net.addLink(h2,s2,cls = TCLink, bw = config.BANDWIDTH, max_queue_size = config.MAX_QUEUE_SIZE)
net.addLink(h2,s3,cls = TCLink, bw = config.BANDWIDTH, max_queue_size = config.MAX_QUEUE_SIZE)
net.addLink(h2,s4,cls = TCLink, bw = config.BANDWIDTH, max_queue_size = config.MAX_QUEUE_SIZE)

h1.setIP('10.0.1.1', intf='h1-eth0')
h2.setIP('10.0.2.1', intf='h2-eth0')


net.start()
time.sleep(1)

print('starting iperf server at', h2.IP())
h2.cmd('iperf3 -s -i 1.0 -f m > iperf_bandwidth_server_log_all_connected.txt&')

print('starting iperf client at', h1.IP(), ', connect to' , h2.IP())
h1.cmd(f'iperf3 -t {str(config.TEST_DURATION)}'
       f'-f m -i 1.0 -c {h2.IP()}'
       f'>  iperf_bandwidth_client_log_all_connected.txt&')

time.sleep(config.TEST_DURATION + 5)

print(h1.cmd('cat iperf_bandwidth_client_log_all_connected.txt'))
print(h2.cmd('cat iperf_bandwidth_server_log_all_connected.txt'))

net.stop()








