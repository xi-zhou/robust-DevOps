#!/bin/bash

# Get the number of test executions from the first command line argument
EXECUTIONS=$1

mkdir -p /test-results


echo "NOISE_TOOL=$NOISE_TOOL"
/bin/bash /noise-tool_setup.sh
noise-tool activate



# Run the Cypress tests
for i in $(seq 1 $EXECUTIONS); do
    echo "[start] Test suite run $i"
   # start server in the background
    bundle exec jekyll serve --host 0.0.0.0 --port 4000 > /jekyll.log 2>&1 &
   
   #  Wait for the server to start
    until $(curl --output /dev/null --silent --head --fail http://localhost:4000); do
        echo "Waiting for the server to start..."
        sleep 2
    done
    # Start the headless X virtual framebuffer (Xvfb)
    Xvfb :99 -screen 0 1024x768x24 > /dev/null 2>&1 &
    export DISPLAY=:99

    # Run the Cypress tests and generate results
    npm run cypress-run
    jrm test-results/results_final.xml "test-results/*.xml"
    mv "/bulma/docs/test-results/results_final.xml" "/test-results/results_$i.xml"
    rm -r test-results/*
    # Kill the server
    kill $(lsof -t -i:4000)   
    echo "[finished] Test suite run $i"
done

echo "stopping noise-tool"
noise-tool deactivate


aggregate-test-results parse-junit-xml /test-results
aggregate-test-results create-artifacts /test-results /experiment-artifacts --aggregation-format junit-xml
