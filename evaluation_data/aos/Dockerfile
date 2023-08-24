ARG image_tag
FROM gitlab.lrz.de:5005/robust-devops/students/noise-tool-chiemsee/base_image${image_tag}

# Install required packages and dependencies
RUN apt-get update && apt-get install -y \
    git-core openssl libssl-dev lsof curl wget

# Install Node.js and NPM
ENV NODE_VERSION=10.24.1
ENV NVM_DIR=/root/.nvm
ENV PATH="${NVM_DIR}/versions/node/v${NODE_VERSION}/bin:${PATH}"
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash && \
    . "$NVM_DIR/nvm.sh" && \
    nvm install ${NODE_VERSION} && \
    nvm use v${NODE_VERSION} && \
    nvm alias default v${NODE_VERSION} && \
    npm install -g junit-report-merger

# Install Yarn using npm
RUN npm install --global yarn

# Clone the react-hook-form repository and checkout a specific commit
RUN git clone https://github.com/michalsnik/aos.git
WORKDIR /aos
RUN git checkout 329fb34f777034345f4d3f4def4dc3bcc300cc2e

# install cypress dependencies
RUN apt-get update && apt-get install -y \
    libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 xauth xvfb

# Install dependencies
RUN sed -i 's/"cypress": "^2.1.0"/"cypress": "3.8.0"/g' package.json
RUN yarn
RUN cd scripts && sed -i "/cypress.run().then(({ failures }) => {/,/});/c\cypress\n  .run({\n    reporter: 'junit',\n    reporterOptions: {\n      mochaFile: 'test-results\/results_[hash].xml',\n      toConsole: false\n    }\n  })\n  .then(({ failures }) => {\n    server.close();\n    process.exit(0);\n  });" run-cypress-tests.js && cd ..

RUN mkdir test-results
RUN chmod -R 755 test-results

COPY --chmod=0755 test.sh /test.sh
ENV EXECUTIONS=100
# Run the test script
CMD ["/bin/bash", "-c", "/test.sh $EXECUTIONS"]
