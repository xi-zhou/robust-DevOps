ARG image_tag
FROM gitlab.lrz.de:5005/robust-devops/students/noise-tool-chiemsee/base_image${image_tag}

# Install required packages and dependencies
RUN apt-get update && apt-get install -y \
    git-core openssl libssl-dev lsof

# Install Node.js and NPM
ENV NODE_VERSION=18.16.0
ENV NVM_DIR=/root/.nvm
ENV PATH="${NVM_DIR}/versions/node/v${NODE_VERSION}/bin:${PATH}"
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash && \
    . "$NVM_DIR/nvm.sh" && \
    nvm install ${NODE_VERSION} && \
    nvm use v${NODE_VERSION} && \
    nvm alias default v${NODE_VERSION} && \
    npm install -g pnpm && \
    npm install -g junit-report-merger

### Project specific setting

# Clone the freecodecamp repository and checkout a specific commit
RUN git clone https://github.com/freeCodeCamp/freeCodeCamp.git 
WORKDIR /freeCodeCamp
RUN git checkout 2abd929426f444dab5133e7132c2c63aa66744e5

# install cypress dependencies
RUN apt-get update && apt-get install -y \
    libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 xauth xvfb

# install mongodb
RUN apt-get install gnupg
RUN curl -fsSL https://pgp.mongodb.com/server-6.0.asc | \
    gpg -o /usr/share/keyrings/mongodb-server-6.0.gpg \
    --dearmor
RUN echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list
RUN ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
RUN apt-get update && apt-get install -y mongodb-org

# Install dependencies and build the project
RUN pnpm install
RUN cp sample.env .env
RUN pnpm run create:config

# set up db
RUN mkdir -p /data/db
RUN chmod -R 755 /data/db
RUN mkdir /log
RUN chmod -R 755 /log

# set up test reporter
RUN mkdir test-results
# overwrite cypress:dev:run script to generate junit report
RUN sed -i 's|"cypress:dev:run": "pnpm run cypress run"|"cypress:dev:run": "pnpm run cypress run --reporter junit --reporter-options mochaFile=test-results/results_[hash].xml"|' package.json
# delete retries from cypress config
RUN sed -i '/retries: 4,/d' cypress.config.js

# Copy the test script to the container
COPY --chmod=0755 test.sh /test.sh
ENV EXECUTIONS=100
# Run the test script
CMD ["/bin/bash", "-c", "/test.sh $EXECUTIONS"]