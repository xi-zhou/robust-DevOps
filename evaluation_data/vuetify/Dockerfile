ARG image_tag
FROM gitlab.lrz.de:5005/robust-devops/students/noise-tool-chiemsee/base_image${image_tag}

# Install required packages and dependencies
RUN apt-get update && apt-get install -y \
    git-core openssl libssl-dev lsof

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



# Clone the Vuetify repository
RUN git clone https://github.com/vuetifyjs/vuetify.git 
WORKDIR /vuetify/packages/vuetify
RUN git checkout 263e12ca94393be61b4b454197ecab5be3da0bd7

# install cypress dependencies
RUN apt-get update && apt-get install -y \
    libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 xauth xvfb

# Install dependencies
RUN yarn
RUN yarn build vuetify
RUN yarn build api

# set up test reporter
RUN mkdir test-results
RUN sed -i 's|"cy:run": "percy exec -- cypress run --component"|"cy:run": "percy exec -- cypress run --reporter junit --reporter-options mochaFile=test-results/results_[hash].xml --component"|' package.json



# Copy the test script to the container
COPY --chmod=0755 test.sh /test.sh
ENV EXECUTIONS=100
# Run the test script
CMD ["/bin/bash", "-c", "/test.sh $EXECUTIONS"]
