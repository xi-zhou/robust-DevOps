ARG image_tag
FROM gitlab.lrz.de:5005/robust-devops/students/noise-tool-chiemsee/base_image${image_tag}

# Install required packages and dependencies
RUN apt-get update && apt-get install -y \
    git-core openssl libssl-dev lsof

ENV NODE_VERSION=16.20.0
ENV NVM_DIR=/root/.nvm
ENV PATH="${NVM_DIR}/versions/node/v${NODE_VERSION}/bin:${PATH}"
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash && \
    . "$NVM_DIR/nvm.sh" && \
    nvm install ${NODE_VERSION} && \
    nvm use v${NODE_VERSION} && \
    nvm alias default v${NODE_VERSION}

# install cypress dependencies
RUN apt-get update && apt-get install -y \
    libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 xauth xvfb

### Project specific setting
# Clone the angular repository and checkout a specific commit
RUN git clone https://github.com/angular/angular.git
WORKDIR /angular
RUN git checkout 1ca6362c06b1249d3a12aa88223e608be8e5163a

# Install Yarn, Bazel
RUN curl -o- -L https://yarnpkg.com/install.sh | bash
RUN npm install -g @bazel/bazelisk
RUN corepack enable
RUN yarn
RUN yarn add junit-report-merger

# set up cypress
RUN yarn add cypress@9.0.0 && \
    yarn add cypress-iframe
RUN mv devtools/cypress.json .

#set up test folder
RUN mkdir test-results

# Copy the test script to the container
COPY --chmod=0755 test.sh /test.sh
ENV EXECUTIONS=100
# Run the test script
CMD ["/bin/bash", "-c", "/test.sh $EXECUTIONS"]