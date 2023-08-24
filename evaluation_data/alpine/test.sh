#!/bin/bash

# Get the number of test executions from the first command line argument
EXECUTIONS=$1
mkdir -p /test-results
max_time=36000 #10hrs
start=$(date +%s)
cumulative_avg=0

echo "Activating noise-tool..."
echo "NOISE_TOOL_TYPE=$NOISE_TOOL_TYPE"
echo "NOISE_TOOL_INTENSITY=$NOISE_TOOL_INTENSITY"
/bin/bash /noise-tool_setup.sh
export NOISE_TOOL_TYPE_CONFIG=$(cat /tmp/config.ini)
noise-tool activate

for i in $(seq 1 $EXECUTIONS); do
    iteration_start=$(date +%s)
    echo "[start] Test suite run $i"
    npm run test -- --reporter junit --reporter-options mochaFile=test-results/results_[hash].xml
    jrm test-results/results_final.xml "test-results/*.xml"
    mv "/alpine/test-results/results_final.xml" "/test-results/results_$i.xml"
    rm -r test-results/*
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

echo "Stopping noise-tool..."
ps
noise-tool deactivate
ps

aggregate-test-results parse-junit-xml /test-results
aggregate-test-results create-artifacts /test-results /experiment-artifacts --aggregation-format junit-xml

