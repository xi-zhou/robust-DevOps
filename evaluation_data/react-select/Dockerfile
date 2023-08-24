ARG image_tag
FROM gitlab.lrz.de:5005/robust-devops/students/noise-tool-chiemsee/base_image${image_tag}

# Install required packages and dependencies
RUN apt-get update && apt-get install -y \
    git-core openssl libssl-dev lsof curl wget

# Install Node.js
ENV NODE_VERSION=16.17.1
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

# Clone the react-select repository and checkout a specific commit
RUN git clone https://github.com/JedWatson/react-select.git
WORKDIR /react-select
RUN git checkout a465818786afd4857c9155bef1e9aa2fe3356097

# install cypress dependencies
RUN apt-get update && apt-get install -y \
    libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 xauth xvfb

# install dependency
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN apt install -y ./google-chrome-stable_current_amd64.deb


RUN yarn 
RUN yarn global add cypress
RUN sed -i 's/"test:cypress": "yarn test:cypress:chrome && yarn test:cypress:firefox"/"test:cypress": "yarn test:cypress:chrome --reporter junit --reporter-options mochaFile=test-results\/results_[hash].xml"/' package.json
RUN mkdir test-results
RUN chmod -R 755 test-results
# Copy the test script to the container
COPY --chmod=0755 test.sh /test.sh
ENV EXECUTIONS=25
# Run the test script
CMD ["/bin/bash", "-c", "/test.sh $EXECUTIONS"]
