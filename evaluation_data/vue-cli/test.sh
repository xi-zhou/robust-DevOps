#!/bin/bash

# Get the number of test executions from the first command line argument
EXECUTIONS=$1

mkdir -p /test-results

echo "NOISE_TOOL=$NOISE_TOOL"
/bin/bash /noise-tool_setup.sh
noise-tool activate


for i in $(seq 1 $EXECUTIONS); do
    echo "[start] Test suite run $i"
    
  yarn workspace @vue/cli-ui test
 # yarn test:e2e:dev 2>&1 | tee /vue-cli/cypress_logs.log

   jrm /vue-cli/packages/@vue/cli-ui/test-results/results_final.xml "/vue-cli/packages/@vue/cli-ui/test-results/*.xml"

    mv "/vue-cli/packages/@vue/cli-ui/test-results/results_final.xml" "/test-results/results_$i.xml"
    rm -r /vue-cli/packages/@vue/cli-ui/test-results/*
    echo "[finished] Test suite run $i"
done

echo "stopping noise-tool"
noise-tool deactivate


aggregate-test-results parse-junit-xml /test-results
aggregate-test-results create-artifacts /test-results /experiment-artifacts --aggregation-format junit-xml