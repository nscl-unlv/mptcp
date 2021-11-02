import config
import time
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
s5 = net.addSwitch('s5')
s6 = net.addSwitch('s6')


#add link
net.addLink(h1,s2,cls = TCLink, bw = config.BANDWIDTH, max_queue_size = config.MAX_QUEUE_SIZE)
net.addLink(h1,s3,cls = TCLink, bw = config.BANDWIDTH, max_queue_size = config.MAX_QUEUE_SIZE)
net.addLink(h1,s4,cls = TCLink, bw = config.BANDWIDTH, max_queue_size = config.MAX_QUEUE_SIZE)
net.addLink(h1,s5,cls = TCLink, bw = config.BANDWIDTH, max_queue_size = config.MAX_QUEUE_SIZE)
net.addLink(h1,s6,cls = TCLink, bw = config.BANDWIDTH, max_queue_size = config.MAX_QUEUE_SIZE)


net.addLink(h2,s2,cls = TCLink, bw = config.BANDWIDTH, max_queue_size = config.MAX_QUEUE_SIZE)
net.addLink(h2,s3,cls = TCLink, bw = config.BANDWIDTH, max_queue_size = config.MAX_QUEUE_SIZE)
net.addLink(h2,s4,cls = TCLink, bw = config.BANDWIDTH, max_queue_size = config.MAX_QUEUE_SIZE)
net.addLink(h2,s5,cls = TCLink, bw = config.BANDWIDTH, max_queue_size = config.MAX_QUEUE_SIZE)
net.addLink(h2,s6,cls = TCLink, bw = config.BANDWIDTH, max_queue_size = config.MAX_QUEUE_SIZE)


h1.setIP('10.0.1.1', intf='h1-eth0')
h1.setIP('10.0.1.2', intf='h1-eth1')
h1.setIP('10.0.1.3', intf='h1-eth2')
h1.setIP('10.0.1.4', intf='h1-eth3')
h1.setIP('10.0.1.5', intf='h1-eth4')


h2.setIP('10.0.2.1', intf='h2-eth0')
h2.setIP('10.0.2.2', intf='h2-eth1')
h2.setIP('10.0.2.3', intf='h2-eth2')
h2.setIP('10.0.2.4', intf='h2-eth3')
h2.setIP('10.0.2.5', intf='h2-eth4')

net.start()
time.sleep(1)

#Starting, we only use  swith 234
h1.intf('h1-eth3').ifconfig('down')
h1.intf('h1-eth4').ifconfig('down')
h2.intf('h2-eth3').ifconfig('down')
h2.intf('h2-eth4').ifconfig('down')
#disconnect s2 and conncet s4
def under_testing():

    time.sleep(config.TEST_DURATION/3.0)
    #net.delLinkBetween(h1, s2, index=0, allLinks=False)
    #net.delLinkBetween(h2, s2, index=0, allLinks=False)
    h1.intf('h1-eth0').ifconfig('down')
    h2.intf('h2-eth0').ifconfig('down')

    h1.intf('h1-eth3').ifconfig('up')
    h2.intf('h2-eth3').ifconfig('up')


    time.sleep(config.TEST_DURATION/3.0)
    h1.intf('h1-eth2').ifconfig('down')
    h2.intf('h2-eth2').ifconfig('down')

    h1.intf('h1-eth4').ifconfig('up')
    h2.intf('h2-eth4').ifconfig('up')
    time.sleep(config.TEST_DURATION/3.0)

    time.sleep(5)  # wait to finish


print('starting iperf server at', h2.IP())
h2.cmd('iperf3 -s -i 1.0 -f m > iperf_bandwidth_server_log_disconnect_connect.txt&')

print('starting iperf client at', h1.IP(), ', connect to' , h2.IP())
h1.cmd(f'iperf3 -t {str(config.TEST_DURATION)}'
       f'-f m -i 1.0 -c {h2.IP()}'
       f'>  iperf_bandwidth_client_log_disconnected_connect.txt&')

under_testing()

print(h1.cmd('cat iperf_bandwidth_client_log_disconnect_connect.txt'))
print(h2.cmd('cat iperf_bandwidth_server_log_disconnect_connect.txt'))

net.stop()
