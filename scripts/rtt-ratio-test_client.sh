#!/bin/bash

# Script to run IPERF and TCPDUMP

# HOW MANY ROUNDS PER TEST
RUNS_PER_TEST=1

# interfaces and ip addresses
INTF_1="eno1"
IP_1="10.18.17.140"

INTF_2="enp7s0"
IP_2="10.18.18.140"

# kimjo-1 eno1
IP_SERVER="10.18.17.15"

INTF_LO="lo" # for testing
IP_LO="127.0.0.1" # for testing

# CONSTANTS
PACKET_LOSS=0.1
INTF1_RTT="10ms"
PRIMARY_PATH=$IP_1

# delay settings for path 2
INTF2_RTTS=("10ms" "20ms" "50ms" "100ms" "200ms" "300ms" "500ms" "1000ms")

# file sizes
FILE_SIZES=("128K" "1M" "10M")

######################## FIRST RUN ###########################

# TEST
#echo "adding constant traffic control rules to $INTF_LO..."
#sudo tc qdisc add dev $INTF_LO root netem delay $INTF1_RTT loss $PACKET_LOSS%
#tc qdisc show dev $INTF_LO

echo "adding constant traffic control rules to $INTF_1..."
sudo tc qdisc add dev $INTF_1 root netem delay $INTF1_RTT loss $PACKET_LOSS%
tc qdisc show dev $INTF_1

echo "adding constant traffic control rules to $INTF_2..."
sudo tc qdisc add dev $INTF_2 root netem delay ${INTF2_RTTS[0]} loss $PACKET_LOSS%
tc qdisc show dev $INTF_2

for (( run=1; run<=$RUNS_PER_TEST; run++ )); do
    for (( size=0; size<len_sizes; size++ )); do
	    echo -e "\n\nSTARTING RUN $run: ${INTF2_RTTS[0]} delay on $INTF_2, ${FILE_SIZES[$size]}\n\n"

	    # TEST lo
	    #echo "capturing traffing on $INTF_LO..."
	    #sudo tcpdump -i $INTF_LO -w "$INTF_LO-run_$run-$INTF1_RTT-${FILE_SIZES[0]}.pcap" &

	    echo "capturing traffing on $INTF_1..."
	    sudo tcpdump -i $INTF_1 -w "$INTF_1-run_$run-$INTF1_RTT-${FILE_SIZES[$size]}.pcap" &

	    echo "capturing traffing on $INTF_2..."
	    sudo tcpdump -i $INTF_2 -w "$INTF_2-run_$run-${INTF2_RTTS[0]}-${FILE_SIZES[$size]}.pcap" &

	    # TEST lo
	    #echo "starting iperf: connecting to $IP_LO, sending size ${FILE_SIZES[0]}..."
	    #iperf3 -c $IP_LO -B $IP_LO -f m -n ${FILE_SIZES[0]} -b 1000M --logfile "iperf-run_$run-${INTF1_RTT}-${INTF2_RTTS[0]}-${FILE_SIZES[0]}.txt"

	    echo "starting iperf: connecting to $IP_SERVER, sending size ${FILE_SIZES[$size]}..."
	    iperf3 -c $IP_SERVER -B $PRIMARY_PATH -f m -n ${FILE_SIZES[0]} -b 1000M --logfile "iperf-run_$run-$INTF1_RTT-${INTF2_RTTS[0]}-${FILE_SIZES[0]}.txt"

	    echo "pausing to ensure capture..."
	    sleep 3

	    # stop capture
	    echo "stopping tcpdump..."
	    sudo pkill tcpdump
    done
done

##################### REMAINING RUNS ##########################

len_rtts=${#INTF2_RTTS[@]}
len_sizes=${#FILE_SIZES[@]}

# Start withn 2nd rtt value
for (( rtt=1; rtt<$len_rtts; rtt++ )); do
    for (( size=0; size<len_sizes; size++ )); do

        # TEST
        #echo "change traffic control rules on $INTF_LO..."
        #sudo tc qdisc change dev $INTF_LO root netem delay ${INTF2_RTTS[$rtt]} loss $PACKET_LOSS%
        #tc qdisc show dev $INTF_LO

        echo "change traffic control rules on $INTF_2..."
        sudo tc qdisc change dev $INTF_2 root netem delay ${INTF2_RTTS[$rtt]} loss $PACKET_LOSS%
        tc qdisc show dev $INTF_2

        for (( run=1; run<=$RUNS_PER_TEST; run++ )); do
            echo -e "\n\nSTARTING RUN $run: ${INTF2_RTTS[$rtt]} delay on $INTF_2, ${FILE_SIZES[$size]}\n\n"

            # TEST lo
            #echo "capturing traffing on $INTF_LO..."
            #sudo tcpdump -i $INTF_LO -w "$INTF_LO-run_$run-$INTF1_RTT-${FILE_SIZES[$size]}.pcap" &

            echo "capturing traffing on $INTF_1..."
            sudo tcpdump -i $INTF_1 -w "$INTF_1-run_$run-$INTF1_RTT-${FILE_SIZES[$size]}.pcap" &

            echo "capturing traffing on $INTF_2..."
            sudo tcpdump -i $INTF_2 -w "$INTF_2-run_$run-${INTF2_RTTS[$rtt]}-${FILE_SIZES[$size]}.pcap" &

            # TEST lo
#            echo "starting iperf: connecting to $IP_LO, sending size ${FILE_SIZES[$size]}..."
#            iperf3 -c $IP_LO -B $IP_LO -f m -n ${FILE_SIZES[$size]} -b 1000M --logfile "iperf-run_$run-$INTF1_RTT-${INTF2_RTTS[$rtt]}-${FILE_SIZES[$size]}.txt"

            echo "starting iperf: connecting to $IP_SERVER, sending size ${FILE_SIZES[$size]}..."
            iperf3 -c $IP_SERVER -B $PRIMARY_PATH -f m -n ${FILE_SIZES[$size]} -b 1000M --logfile "iperf-run_$run-$INTF1_RTT-${INTF2_RTTS[$rtt]}-${FILE_SIZES[$size]}.txt"

            echo "pausing to ensure capture..."
            sleep 3

            echo "stopping tcpdump..."
            sudo pkill tcpdump
        done
    done
done

######################### end #################################

# TEST lo
#echo -e "\nremoving traffic control rules\n"
#sudo tc qdisc del dev $INTF_LO root netem
#tc qdisc show dev $INTF_LO

echo -e "\nremoving traffic control rules from $INTF_1"
sudo tc qdisc del dev $INTF_1 root netem
tc qdisc show dev $INTF_1

echo -e "\nremoving traffic control rules from $INTF_2"
sudo tc qdisc del dev $INTF_2 root netem
tc qdisc show dev $INTF_2

echo -e "\n\nprogram ending"
