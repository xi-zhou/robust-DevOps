#!/bin/bash
#export PS4='${LINENO}: '

# Get the number of test executions from the first command line argument
EXECUTIONS=${1:-1}
echo "Arg: ${1}, Executions: $EXECUTIONS"

mkdir -p /test-results/raw

echo "Preparing..."

# Route traffic to externaL docker containers
socat TCP-LISTEN:5432,fork TCP:172.18.0.10:5432 & # Postgres
socat TCP-LISTEN:6379,fork TCP:172.18.0.11:6379 & # Redis

# Add reporter option to cypress config file
configFile=/superset/superset-frontend/cypress-base/cypress.config.ts
cypressOptions="\
  reporter: 'junit',
  reporterOptions: {
    mochaFile: '/test-results/raw/results_[hash].xml',
    toConsole: false,
  },
"
lastLine=$(tail -n 1 "$configFile")
sed -i '$d' "$configFile" # Delete last line
echo "$cypressOptions" >> "$configFile" # Insert reporter options
echo "$lastLine" >> "$configFile" # Reinsert last line

# Set retries to 0
sed -i 's/runMode: [0-9][0-9]*\b/runMode: 0/g' "$configFile" # for runMode
sed -i 's/openMode: [0-9][0-9]*\b/openMode: 0/g' "$configFile" # for openMode

# Allow bash script execution in tox
sed -i '/^allowlist_externals =/a\    bash' tox.ini # add bash to allowlist_externals
sed -i 's|{toxinidir}/superset-frontend/cypress_build.sh|bash &|g' tox.ini # Append .../cypress_build.sh with bash to avoid putting the whole filename in allowlist_externals
# Check checksum of changed tox.ini to make sure the changes are as expected
if [[ $(sha256sum "tox.ini" | awk '{ print $1 }') != "61763be64bff1c0114e8679c174e79be060e85ab94b6adc3bb5d4e00f7d5277c" ]]; then
    echo "tox.ini checksum mismatch! Something must have changed"
    exit 1
fi

echo "Activating noise-tool..."
echo "NOISE_TOOL_TYPE=$NOISE_TOOL_TYPE"
echo "NOISE_TOOL_INTENSITY=$NOISE_TOOL_INTENSITY"
export NOISE_TOOL_TYPE_CONFIG=$(cat /tmp/config.ini)
/bin/bash /noise-tool_setup.sh
noise-tool activate

echo "Executing tests..."

# Timeout stuff
max_time=36000 #10hrs
start=$(date +%s)
cumulative_avg=0

for i in $(seq 1 $EXECUTIONS); do
    # Timeout stuff
    iteration_start=$(date +%s)
    echo "[start] Test suite run $i"
    psql "postgresql://superset:superset@127.0.0.1:5432/superset" <<-EOF
    DROP SCHEMA IF EXISTS sqllab_test_db CASCADE;
    DROP SCHEMA IF EXISTS admin_database CASCADE;
    CREATE SCHEMA sqllab_test_db;
    CREATE SCHEMA admin_database;
EOF
    tox -e cypress

    # Merge spec results
    jrm /test-results/raw/combined.xml "/test-results/raw/results_*.xml"
    mv "/test-results/raw/combined.xml" "/test-results/results_$i.xml"
    rm -r /test-results/raw/*

    echo "[finished] Test suite run $i"

    # Timeout stuff
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