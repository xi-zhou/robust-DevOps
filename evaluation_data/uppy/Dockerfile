ARG image_tag
FROM gitlab.lrz.de:5005/robust-devops/students/noise-tool-chiemsee/base_image${image_tag}

# Install required packages and dependencies
RUN apt-get update && apt-get install -y \
    git-core openssl libssl-dev lsof redis-server

# Install Node.js and Yarn
ENV NODE_VERSION=18.16.0
ENV NVM_DIR=/root/.nvm
ENV PATH="${NVM_DIR}/versions/node/v${NODE_VERSION}/bin:${PATH}"
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash && \
    . "$NVM_DIR/nvm.sh" && \
    nvm install ${NODE_VERSION} && \
    nvm use v${NODE_VERSION} && \
    nvm alias default v${NODE_VERSION} && \
    npm install -g yarn && \
    npm install -g junit-report-merger



# Clone the Uppy repository
RUN git clone https://github.com/transloadit/uppy.git
WORKDIR /uppy
RUN git checkout 71e3f062b7968efd7388d9afc4038c4360be8938

# Install cypress dependencies
RUN apt-get update && apt-get install -y \
    libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 xauth xvfb

# Install Corepack
RUN npm i -g corepack
RUN corepack enable

# Install dependencies
RUN corepack yarn install --immutable

# Build the project
RUN corepack yarn build 

RUN mkdir test-results

RUN sed -i 's|"cypress:headless": "cypress run"|"cypress:headless": "cypress run --reporter junit --reporter-options mochaFile=test-results/results_[hash]_$(date +%s).xml"|' e2e/package.json
#RUN sed -i 's|"cypress:headless": "cypress run"|"cypress:headless": "cypress run --reporter junit --reporter-options mochaFile=test-results/results_$(date +%s).xml"|' e2e/package.json
#RUN sed -i 's|"cypress:headless": "cypress run" |"cypress:headless": "cypress run --reporter junit --reporter-options mochaFile=test-results/results_[hash].xml"|' /uppy/e2e/package.json


# Copy the test script to the container
COPY --chmod=0755 test.sh /test.sh

# Define the number of test executions as an environment variable
ENV EXECUTIONS=100

# Run the test script
CMD ["/bin/bash", "-c", "/test.sh $EXECUTIONS"]
