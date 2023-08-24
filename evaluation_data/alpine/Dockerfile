ARG image_tag
FROM gitlab.lrz.de:5005/robust-devops/students/noise-tool-chiemsee/base_image${image_tag}

# Install required packages and dependencies
RUN apt-get update && apt-get install -y \
    git-core openssl libssl-dev lsof curl wget

# Install Node.js and NPM
ENV NODE_VERSION=18.16.0
ENV NVM_DIR=/root/.nvm
ENV PATH="${NVM_DIR}/versions/node/v${NODE_VERSION}/bin:${PATH}"
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash && \
    . "$NVM_DIR/nvm.sh" && \
    nvm install ${NODE_VERSION} && \
    nvm use v${NODE_VERSION} && \
    nvm alias default v${NODE_VERSION} && \
    npm install -g junit-report-merger



# Clone the react-hook-form repository and checkout a specific commit
RUN git clone https://github.com/alpinejs/alpine.git
WORKDIR /alpine
RUN git checkout a9206161f0bf878d41a001197553613cf31cbde9

# install cypress dependencies
RUN apt-get update && apt-get install -y \
    libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 xauth xvfb
# Install dependencies
RUN npm install
RUN npm run build
RUN mkdir test-results
RUN chmod -R 755 test-results

COPY --chmod=0755 test.sh /test.sh
ENV EXECUTIONS=100
# Run the test script
CMD ["/bin/bash", "-c", "/test.sh $EXECUTIONS"]
