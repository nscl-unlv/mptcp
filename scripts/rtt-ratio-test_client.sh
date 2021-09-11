#!/bin/bash

# Script to run IPERF and TCPDUMP

INTF_1="eno1"
INTF_2="enp7s0"
INTF_LO="lo" # test
IP_LO="127.0.0.1"

# constants
PACKET_LOSS=0.1
INTF1_RTT=10 

# delay settings for path 2
INTF2_RTTS=(10 20 50)

# RTT ratios
RATIOS=(1 2 5)

# file sizes
FILE_SIZES=("128K" "1M" "10M")

######################## first run ###########################

#echo -e "adding 1st run traffic control rules to $INTF_1...\n"
#sudo tc qdisc add dev eno1 root netem delay ${INTF2_RTTS[0]}ms loss $PACKET_LOSS%
#tc qdisc show dev $INTF_1
#
#echo -e "\ncapturing traffing on $INTF_1...\n"
#sudo tcpdump -i $INTF_3 -w "$INTF_1-$INTF1_RTT-${FILE_SIZES[0]}.pcap" &
#
## TODO capture interface 2
#
#echo -e "starting iperf: connecting to $IP_1, sending size ${FILE_SIZES[0]}...\n"
#iperf3 -c $IP_1 -B $IP_1 -f m -n ${FILE_SIZES[0]} -b 1000M --logfile "iperf-${RATIOS[0]}-${FILE_SIZES[0]}.txt"
#
#
#echo -e "pausing to ensure capture...\n"
#sleep 2
#
## stop capture
#echo -e "stopping tcpdump...\n"
#sudo pkill tcpdump


##################### remaining runs ##########################

len_rtts=${#INTF2_RTTS[@]}
len_sizes=${#FILE_SIZES[@]}

# TODO: change to INTF_2
for (( rtt=1; rtt<$len_rtts; rtt++ )); do
    echo -e "test run: ${INTF2_RTTS[rtt]}ms delay, ${FILE_SIZES[size]}\n"

    for (( size=1; size<len_sizes; size++ )); do
        echo -e "adding traffic control rules to $INTF_1...\n"
        sudo tc qdisc add dev eno1 root netem delay ${INTF2_RTTS[$rtt]}ms loss $PACKET_LOSS%
        tc qdisc show dev $INTF_1

        # TODO: change to INTF_1
        echo -e "\ncapturing traffing on $INTF_1...\n"
        sudo tcpdump -i $INTF_LO -w "$INTF_LO-$INTF1_RTT-${FILE_SIZES[0]}.pcap" &

        # TODO: listen to INTF_2

        echo -e "starting iperf: connecting to $IP_1, sending size ${FILE_SIZES[0]}...\n"
        iperf3 -c $IP_LO -B $IP_LO -f m -n ${FILE_SIZES[0]} -b 1000M --logfile "iperf-${RATIOS[0]}-${FILE_SIZES[0]}.txt"

        echo -e "stopping tcpdump...\n"
        sudo pkill tcpdump
    done
done



######################### end #################################

#echo "removing traffic control rules"
#sudo tc qdisc del dev $INTF_1 root netem
#tc qdisc show dev $INTF_1

echo "program ending"
