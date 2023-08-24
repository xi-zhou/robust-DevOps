ARG image_tag
FROM gitlab.lrz.de:5005/robust-devops/students/noise-tool-chiemsee/base_image${image_tag}

# Install required packages and dependencies
RUN apt-get update && apt-get install -y \
    git-core openssl libssl-dev lsof

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

# install cypress dependencies
RUN apt-get update && apt-get install -y \
    libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 xauth xvfb

### Project specific setting
# Clone the n8n repository and checkout a specific commit
RUN git clone https://github.com/n8n-io/n8n.git
WORKDIR /n8n
RUN git checkout 3e5f7adcbff23d7e061bbce9dffaaf35227450ca

# Install project dependencies
RUN pnpm install
RUN pnpm run cypress:install
RUN pnpm build

# delete retries, ouput video and specify junit reporter
RUN sed -i '8,11d' cypress.config.js
RUN sed -i '14d' cypress.config.js
RUN sed -i 's|"test:e2e:all": "cross-env E2E_TESTS=true NODE_OPTIONS=--dns-result-order=ipv4first  start-server-and-test start http://localhost:5678/favicon.ico '\''cypress run --headless'\''"|"test:e2e:all": "cross-env E2E_TESTS=true NODE_OPTIONS=--dns-result-order=ipv4first  start-server-and-test start http://localhost:5678/favicon.ico '\''cypress run --reporter junit --reporter-options mochaFile=test-results/results_[hash].xml'\''"|' package.json

#set up test folder
RUN mkdir test-results

# Copy the test script to the container
COPY --chmod=0755 test.sh /test.sh
ENV EXECUTIONS=100
# Run the test script
CMD ["/bin/bash", "-c", "/test.sh $EXECUTIONS"]