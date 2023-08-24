#!/bin/bash

# Get the number of test executions from the first command line argument
EXECUTIONS=$1

mkdir -p /test-results

echo "NOISE_TOOL=$NOISE_TOOL"
/bin/bash /noise-tool_setup.sh
noise-tool activate

for i in $(seq 1 $EXECUTIONS); do
    echo "[start] Test suite run $i"
    PLAYWRIGHT_JUNIT_OUTPUT_NAME=test-results/results.xml pnpm run test:e2e --reporter=junit
    mv "/shiki/test-results/results.xml" "/test-results/results_$i.xml"
    kill -9 $(lsof -t -i:3000)  # kill the server
    echo "[finished] Test suite run $i"
done

echo "stopping noise-tool"
ps
noise-tool deactivate
sleep 5
ps

aggregate-test-results parse-junit-xml /test-results
aggregate-test-results create-artifacts /test-results /experiment-artifacts --aggregation-format junit-xml

