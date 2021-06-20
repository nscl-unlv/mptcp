#!/bin/bash

# displays info about the Congestion Control Algorithms (CCA)

# select string after equal sign
CUT_EQ="cut -d= -f2"

# current CCA
LOADED_CCA=$(sysctl net.ipv4.tcp_congestion_control | $CUT_EQ)

# available (loaded) CCA
AVAILABLE_CCA=$(sysctl net.ipv4.tcp_available_congestion_control | $CUT_EQ)

# main output
if [ "$#" -eq 0 ]; then
    echo "Current congestion control algorithm: $LOADED_CCA"
    echo "Loaded congestion control algorithms: $AVAILABLE_CCA"
    echo "use '-a' option to list all algorithms."
elif [[ $1 == "-a" ]]; then
    KERNAL_VER=$(uname -r)
    CCA_LOCATION="/lib/modules/$KERNAL_VER/kernel/net/ipv4"
    ALL_CCA=$(ls $CCA_LOCATION | grep "tcp*" | cut -d. -f1)

    echo "Current congestion control algorithm: $LOADED_CCA"
    echo "Loaded congestion control algorithms: $AVAILABLE_CCA"
    echo "All congestion control algorithms:"
    echo "$ALL_CCA"
else
    echo "invalid option. usage ./<script>.sh -a (all algorithms)."
fi
