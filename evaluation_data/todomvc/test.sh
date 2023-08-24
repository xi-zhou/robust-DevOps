#!/bin/bash
#export PS4='${LINENO}: '

# Get the number of test executions from the first command line argument
EXECUTIONS=${1:-1}
echo "Arg: ${1}, Executions: $EXECUTIONS"

mkdir -p /test-results/raw

echo "Preparing..."

# TODO: Add cpyress config file

# Add reporter option to cypress config file
configFile=/todomvc/cypress.json
cypressOptions='  ,"video": false,
  "videoUploadOnPasses": false,
  "screenshotOnRunFailure": false,
  "retries": {
    "runMode": 0,
    "openMode": 0
  },
  "reporter": "junit",
  "reporterOptions": {
    "mochaFile": "/test-results/raw/results_[hash].xml",
    "toConsole": false
  }
'
lastLine=$(tail -n 1 "$configFile")
sed -i '$d' "$configFile" # Delete last line
echo "$cypressOptions" >> "$configFile" # Insert reporter options
echo "$lastLine" >> "$configFile" # Reinsert last line

# Make cypress use chrome browser (more tests are passing with electron so leave out)
# sed -i 's/"cypress run"/"cypress run --browser chrome"/g' package.json

echo "Activating noise-tool..."
echo "NOISE_TOOL_TYPE=$NOISE_TOOL_TYPE"
echo "NOISE_TOOL_INTENSITY=$NOISE_TOOL_INTENSITY"
/bin/bash /noise-tool_setup.sh
export NOISE_TOOL_TYPE_CONFIG=$(cat /tmp/config.ini)
noise-tool activate

echo "Executing tests..."

max_time=18000 #10hrs
start=$(date +%s)
cumulative_avg=0

for i in $(seq 1 $EXECUTIONS); do

    iteration_start=$(date +%s)

    echo "[start] Test suite run $i"
    # See https://github.com/tastejs/todomvc/blob/4e301c7014093505dcf6678c8f97a5e8dee2d250/.travis.yml for a list
    #!/bin/bash

    frameworks=(
        "angular-dart"
        "angular2"
        "angularjs"
        "aurelia"
        "backbone"
        "backbone_marionette"
        "backbone_require"
        "binding-scala"
        "canjs"
        "canjs_require"
        "closure"
        "dijon"
        "dojo"
        "duel"
        "emberjs"
        "enyo_backbone"
        "exoskeleton"
        "jquery"
        "js_of_ocaml"
        "jsblocks"
        "knockback"
        "knockoutjs"
        "knockoutjs_require"
        "kotlin-react"
        "lavaca_require"
        "mithril"
        "polymer"
        "ractive"
        "react"
        "react-alt"
        "react-backbone"
        "reagent"
        "riotjs"
        "scalajs-react"
        "typescript-angular"
        "typescript-backbone"
        "typescript-react"
        "vanilla-es6"
        "vanillajs"
        "vue"
    )

    echo "The number of frameworks is: ${#frameworks[@]}"
    
    for framework in "${frameworks[@]}"
    do
        echo "Running tests for $framework"
        CYPRESS_framework="$framework" npm run test
    done

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