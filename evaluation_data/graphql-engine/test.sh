#!/bin/bash
#export PS4='${LINENO}: '

# Get the number of test executions from the first command line argument
EXECUTIONS=${1:-1}
echo "Arg: ${1}, Executions: $EXECUTIONS"

mkdir -p /test-results/raw

echo "Preparing..."

# Add reporter option to cypress config file
configFile=/hasura-graphql-engine/frontend/apps/console-ce-e2e/cypress.config.ts
cypressOptions="\
  reporter: 'junit',
  reporterOptions: {
    mochaFile: '/test-results/raw/results_[hash].xml',
    toConsole: true,
  },
"
lastLine=$(tail -n 1 "$configFile")
sed -i '$d' "$configFile" # Delete last line
echo "$cypressOptions" >> "$configFile" # Insert reporter options
echo "$lastLine" >> "$configFile" # Reinsert last line

# Set retries to 0
sed -i 's/runMode: [0-9][0-9]*\b/runMode: 0/g' "$configFile" # for runMode
sed -i 's/openMode: [0-9][0-9]*\b/openMode: 0/g' "$configFile" # for openMode

echo "Activating noise-tool..."
echo "NOISE_TOOL_TYPE=$NOISE_TOOL_TYPE"
echo "NOISE_TOOL_INTENSITY=$NOISE_TOOL_INTENSITY"
/bin/bash /noise-tool_setup.sh
noise-tool activate

echo "Executing tests..."

max_time=18000 #10hrs
start=$(date +%s)
cumulative_avg=0

for i in $(seq 1 $EXECUTIONS); do

    iteration_start=$(date +%s)

    echo "[start] Test suite run $i"
    yarn test:e2e

    # Merge spec results
    jrm /test-results/raw/combined.xml "/test-results/raw/results_*.xml"
    mv "/test-results/raw/combined.xml" "/test-results/results_$i.xml"
    rm -r /test-results/raw/*

    echo "[finished] Test suite run $i"

    
    iteration_end=$(date +%s)
    iteration_time=$((iteration_end - iteration_start))
    elapsed_time=$((iteration_end - start))
    echo "iteration time: $iteration_time"
    cumulative_avg=$((cumulative_avg + (iteration_time - cumulative_avg) / i))
    echo "Avg time per iteration so far: $cumulative_avg seconds."
    projected_end_time=$((elapsed_time + cumulative_avg))
    if [ $projected_end_time -ge $max_time ]; then
        echo "Projected execution time for the next iteration will exceed the time limit."
        echo "Number of executions done: $i"
        break
    fi
done

echo "stopping noise-tool"
ps
noise-tool deactivate
ps

aggregate-test-results parse-junit-xml /test-results
aggregate-test-results create-artifacts /test-results /experiment-artifacts --aggregation-format junit-xml