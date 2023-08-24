ARG image_tag
FROM gitlab.lrz.de:5005/robust-devops/students/noise-tool-chiemsee/base_image${image_tag}

# Install required packages and dependencies
RUN apt-get update && apt-get install -y \
    git-core openssl libssl-dev lsof curl wget

# Install Node.js
ENV NODE_VERSION=16.10.0
ENV NVM_DIR=/root/.nvm
ENV PATH="${NVM_DIR}/versions/node/v${NODE_VERSION}/bin:${PATH}"
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash && \
    . "$NVM_DIR/nvm.sh" && \
    nvm install ${NODE_VERSION} && \
    nvm use v${NODE_VERSION} && \
    nvm alias default v${NODE_VERSION}

### Project specific setting

# Clone the metabase repository and checkout a specific commit
RUN git clone https://github.com/metabase/metabase.git
WORKDIR /metabase
RUN git checkout 5c5fe51ca8abc123b300bf237e906cf0a78c4838

# install cypress dependencies
RUN apt-get update && apt-get install -y \
    libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 xauth xvfb

# Install dependencies
RUN corepack enable
RUN apt-get install -y openjdk-11-jdk rlwrap
RUN curl -O https://download.clojure.org/install/linux-install-1.11.1.1347.sh
RUN chmod +x linux-install-1.11.1.1347.sh
RUN ./linux-install-1.11.1.1347.sh
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN apt install -y ./google-chrome-stable_current_amd64.deb

RUN yarn
RUN yarn add junit-report-merger

RUN mkdir test-results
RUN chmod -R 755 test-results
COPY --chmod=0755 change_reporter.sh .
RUN ./change_reporter.sh

# Build Uberjar
RUN ./bin/build.sh

# Copy the test script to the container
COPY --chmod=0755 test.sh /test.sh
ENV EXECUTIONS=100
# Run the test script
CMD ["/bin/bash", "-c", "/test.sh $EXECUTIONS"]