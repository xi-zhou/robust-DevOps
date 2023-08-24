#!/bin/bash
export PS4='${LINENO}: '

# Get the number of test executions from the first command line argument
EXECUTIONS=$1

#mkdir -p /test-results

#noise-tool activate
echo "Preparing..."
echo "$EXECUTIONS"
pip install psycopg2
socat TCP-LISTEN:15432,fork TCP:172.18.0.10:5432 &
socat TCP-LISTEN:16379,fork TCP:172.18.0.11:6379 &
psql "postgresql://superset:superset@127.0.0.1:15432/superset" <<-EOF
    DROP SCHEMA IF EXISTS sqllab_test_db CASCADE;
    DROP SCHEMA IF EXISTS admin_database CASCADE;
    CREATE SCHEMA sqllab_test_db;
    CREATE SCHEMA admin_database;
EOF
pip install -e .
superset db upgrade
superset load_test_users
superset load_examples --load-test-data
superset init
cd superset-frontend/
# npm ci
# Could be a known bug where static files arnent built properly try with:
npm install -f --no-optional --global webpack webpack-cli
npm install -f --no-optional
#npm run build-instrumented
npm run build
cd cypress-base/
npm ci
nohup flask run --no-debugger -p 8081 >"flask.log" 2>&1 </dev/null &
echo "Executing tests..."


for i in $(seq 1 $EXECUTIONS); do
    echo "[start] Test suite run $i"
    npm run cypress-run-chrome
    #PLAYWRIGHT_JUNIT_OUTPUT_NAME=test-results/results.xml pnpm run test:e2e --reporter=junit
    #mv "/shiki/test-results/results.xml" "/test-results/results_$i.xml"
    #kill -9 $(lsof -t -i:3000)  # kill the server
    echo "[finished] Test suite run $i"
done

#echo "stopping noise-tool"
#ps
#noise-tool deactivate
#ps

#aggregate-test-results parse-junit-xml /test-results