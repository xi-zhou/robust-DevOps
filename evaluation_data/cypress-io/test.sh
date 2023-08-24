#!/bin/bash

# Get the number of test executions from the first command line argument
EXECUTIONS=$1

#yarn watch
mkdir -p /test-results
max_time=36000 #10hrs
start=$(date +%s)
cumulative_avg=0


# Start Xvfb (X virtual framebuffer)
Xvfb :99 -screen 0 1024x768x16 &

# Set the browser to Chrome
export BROWSER=chrome

echo "NOISE_TOOL=$NOISE_TOOL"
/bin/bash /noise-tool_setup.sh
noise-tool activate


for i in $(seq 1 $EXECUTIONS); do
    echo "[start] Test suite run $i" 
   yarn workspace @packages/driver cypress:run
    jrm /cypress/packages/driver/test-results/results_final.xml "/cypress/packages/driver/test-results/*.xml"
    mv "/cypress/packages/driver/test-results/results_final.xml" "/test-results/results_$i.xml"
#there is &nbsp characters in newly created xml file and it cause parsing error with parse-junit-xml. So this character will be removed from xml   
 sed -i 's/&nbsp;//g' "/test-results/results_$i.xml"

    rm -r /cypress/packages/driver/test-results/*
    echo "[finished] Test suite run $i"
    # ---Time estimate---
    iteration_end=$(date +%s)
    iteration_duration=$((iteration_end - iteration_start))
    echo "iteration duration: $iteration_duration"
    elapsed_time=$((iteration_end - start))
    cumulative_avg=$((elapsed_time / i))
    echo "Avg time per iteration so far: $cumulative_avg seconds."
    projected_end_time=$((elapsed_time + cumulative_avg))
    if [ $projected_end_time -ge $max_time ]; then
        echo "Projected execution time for the next iteration will exceed the time limit."
        echo "Number of executions done: $i"
        break
    fi

done

echo "stopping noise-tool"
noise-tool deactivate


aggregate-test-results parse-junit-xml /test-results
aggregate-test-results create-artifacts /test-results /experiment-artifacts --aggregation-format junit-xml
