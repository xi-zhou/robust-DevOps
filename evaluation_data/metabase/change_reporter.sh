#!/bin/bash

# change reporter to junit
awk '/reporter: "mochawesome",/ { gsub("mochawesome", "junit") } {print}' e2e/support/config.js > tmp.js
mv tmp.js e2e/support/config.js

awk '/retries: {/,/},/ {
    if ($0 ~ /retries: {/) {getline; getline; getline; getline;}
} !(/retries: {/) {print}' e2e/support/config.js > tmp.js
mv tmp.js e2e/support/config.js

awk '/reporterOptions: {/,/},/ {
    if ($0 ~ /reporterOptions: {/) { print "  reporterOptions: {\n    mochaFile: \"./test-results/results_[hash].xml\",\n    toConsole: false\n  }"; getline; while($0 !~ /},/) {getline}; next }
} !(/reporterOptions: {/) {print}' e2e/support/config.js > tmp.js
mv tmp.js e2e/support/config.js

# delete generate html report
sed -i '43,50d' e2e/runner/cypress-runner-run-tests.js


