#!/bin/bash

# Get the number of test executions from the first command line argument
EXECUTIONS=$1

for i in $(seq 1 $EXECUTIONS); do
    echo "[start] Test suite run $i"
    # start server and run test
    npm start & npx wait-on http://localhost:3000 && npm run cy:run -- --config baseUrl=http://localhost:3000 --reporter junit --reporter-options mochaFile=tmp-results/results-[hash].xml
    jrm "test-results/results.xml" "tmp-results/results-*.xml"
    rm -rf tmp-results/*
    mv "test-results/results.xml" "test-results/results_$i.xml"
    echo "[finished] Test suite run $i"
done

aggregate-test-results parse-junit-xml test-results
aggregate-test-results create-artifacts test-results /experiment-artifacts --aggregation-format junit-xml
