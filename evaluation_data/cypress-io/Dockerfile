ARG image_tag
FROM gitlab.lrz.de:5005/robust-devops/students/noise-tool-chiemsee/base_image${image_tag}

# Install required packages and dependencies
RUN apt-get update && apt-get install -y \
    git-core openssl libssl-dev lsof wget

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


# Install Google Chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list \
    && apt-get update && apt-get install -y google-chrome-stable


### Project specific setting
RUN npm install -g yarn

# Clone the repository and checkout a specific commit
RUN git clone https://github.com/cypress-io/cypress.git 
WORKDIR /cypress
RUN git checkout 9517def6b7a95a975b5eadc9454ff0541c8eca0e


# install cypress dependencies
RUN apt-get update && apt-get install -y \
    libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 xauth xvfb


# Install dependencies
RUN yarn install


RUN sed -i 's|"cypress:run": "node ../../scripts/cypress run"|"cypress:run": "node ../../scripts/cypress run --reporter junit --reporter-options mochaFile=test-results/results_[hash].xml"|' packages/driver/package.json


# set up test reporter
RUN mkdir test-results

# Copy the test script to the container
COPY --chmod=0755 test.sh /test.sh
ENV EXECUTIONS=2
# Run the test script
CMD ["/bin/bash", "-c", "google-chrome-stable --headless & /test.sh $EXECUTIONS"]
