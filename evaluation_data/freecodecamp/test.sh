#!/bin/bash

# Get the number of test executions from the first command line argument
EXECUTIONS=$1

mkdir -p /test-results
max_time=36000 #10hrs
start=$(date +%s)
cumulative_avg=0

echo "NOISE_TOOL=$NOISE_TOOL"
/bin/bash /noise-tool_setup.sh
export NOISE_TOOL_TYPE_CONFIG=$(cat /tmp/config.ini)
noise-tool activate

for i in $(seq 1 $EXECUTIONS); do
    echo "[start] Test suite run $i"
    # start mongodb in backgroud
    echo "starting mongodb"
    mongod --fork --logpath /log/mongodb.log
    pnpm run seed
    # start server and run test
    pnpm run e2e:dev:run
    jrm test-results/results_final.xml "test-results/*.xml"
    mv "/freeCodeCamp/test-results/results_final.xml" "/test-results/results_$i.xml"
    rm -r test-results/*
    kill -9 $(lsof -t -i:27017)  # kill mongodb
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