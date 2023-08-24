#!/bin/bash

# Reading the value of the environmental variable
NOISE_TYPE_VALUE=$NOISE_TOOL_TYPE
NOISE_INTENSITY_VALUE=$NOISE_TOOL_INTENSITY

# Checking the value and executing different commands
case $NOISE_TYPE_VALUE in
    cpu)
        # execute if NOISE_VALUE is 'cpu'
        if [ "$NOISE_INTENSITY_VALUE" = "low" ]; then
            noise-tool config --write "concurrency --cores 0 --cpu-load 30"
        elif [ "$NOISE_INTENSITY_VALUE" = "medium" ]; then
            noise-tool config --write "concurrency --cores 0 --cpu-load 50"
        elif [ "$NOISE_INTENSITY_VALUE" = "high" ]; then
            noise-tool config --write "concurrency --cores 0 --cpu-load 90"
        else echo "No valid NOISE_TOOL_INTENSITY ($NOISE_TOOL_INTENSITY)"; fi
        ;;
    ram)
        # execute if NOISE_VALUE is 'ram'
        if [ "$NOISE_INTENSITY_VALUE" = "low" ]; then
            noise-tool config --write "ram_io --workers 1  --ram 10 --io 0"
        elif [ "$NOISE_INTENSITY_VALUE" = "medium" ]; then
            noise-tool config --write "ram_io --workers 1  --ram 50 --io 0"
        elif [ "$NOISE_INTENSITY_VALUE" = "high" ]; then
            noise-tool config --write "ram_io --workers 1  --ram 90 --io 0"
        else echo "No valid NOISE_TOOL_INTENSITY ($NOISE_TOOL_INTENSITY)"; fi
        ;;
    io)
        # execute if NOISE_VALUE is 'io'
        if [ "$NOISE_INTENSITY_VALUE" = "low" ]; then
            noise-tool config --write "ram_io --workers 1  --ram 0 --io 1"
        elif [ "$NOISE_INTENSITY_VALUE" = "medium" ]; then
            noise-tool config --write "ram_io --workers 1  --ram 0 --io 5"
        elif [ "$NOISE_INTENSITY_VALUE" = "high" ]; then
            noise-tool config --write "ram_io --workers 1  --ram 0 --io 10"
        else echo "No valid NOISE_TOOL_INTENSITY ($NOISE_TOOL_INTENSITY)"; fi
        ;;
    netdelay)
        # execute if NOISE_VALUE is 'netdelay'
        if [ "$NOISE_INTENSITY_VALUE" = "low" ]; then
            noise-tool config --write "network --delay 1000"
        elif [ "$NOISE_INTENSITY_VALUE" = "medium" ]; then
            noise-tool config --write "network --delay 3000"
        elif [ "$NOISE_INTENSITY_VALUE" = "high" ]; then
            noise-tool config --write "network --delay 5000"
        else echo "No valid NOISE_TOOL_INTENSITY ($NOISE_TOOL_INTENSITY)"; fi
        ;;
    netpgk)
        # execute if NOISE_VALUE is 'netpgk'
        if [ "$NOISE_INTENSITY_VALUE" = "low" ]; then
            noise-tool config --write "network --packageLoss 10"
        elif [ "$NOISE_INTENSITY_VALUE" = "medium" ]; then
            noise-tool config --write "network --packageLoss 40"
        elif [ "$NOISE_INTENSITY_VALUE" = "high" ]; then
            noise-tool config --write "network --packageLoss 80"
        else echo "No valid NOISE_TOOL_INTENSITY ($NOISE_TOOL_INTENSITY)"; fi
        ;;
    netbandwidth)
        # execute if NOISE_VALUE is 'netpgk'
        if [ "$NOISE_INTENSITY_VALUE" = "low" ]; then
            noise-tool config --write "network --bandwidth 100"
        elif [ "$NOISE_INTENSITY_VALUE" = "medium" ]; then
            noise-tool config --write "network --bandwidth 15"
        elif [ "$NOISE_INTENSITY_VALUE" = "high" ]; then
            noise-tool config --write "network --bandwidth 5"
        else echo "No valid NOISE_TOOL_INTENSITY ($NOISE_TOOL_INTENSITY)"; fi
        ;;
    *)
        # execute default command if MY_VAR_VALUE is none of the above
        echo "default"
        ;;
esac
