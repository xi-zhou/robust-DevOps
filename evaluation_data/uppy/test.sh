#!/bin/bash

# Get the number of test executions from the first command line argument
EXECUTIONS=$1

mkdir -p /test-results


# Setup .env from .env.example if it doesn't exi
if [ ! -f .env ]; then
    cp .env.example .env
fi


echo "NOISE_TOOL=$NOISE_TOOL"
/bin/bash /noise-tool_setup.sh
noise-tool activate


for i in $(seq 1 $EXECUTIONS); do
    echo "[start] Test suite run $i"
    # Run the test
    corepack yarn e2e:ci
    jrm  e2e/test-results/results_final.xml e2e/test-results/*.xml
    mv "e2e/test-results/results_final.xml" "/test-results/results_$i.xml"
    rm -r e2e/test-results/*
    echo "[finished] Test suite run $i"
done

echo "stopping noise-tool"
noise-tool deactivate



# Aggregate test results
aggregate-test-results parse-junit-xml /test-results
aggregate-test-results create-artifacts /test-results /experiment-artifacts --aggregation-format junit-xml
