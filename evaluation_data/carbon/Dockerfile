# refer to .github/workflows/validate.yml for reference
ARG image_tag
FROM gitlab.lrz.de:5005/robust-devops/students/noise-tool-chiemsee/base_image${image_tag}

# Install required packages and dependencies
RUN apt-get update && apt-get install -y \
    git-core openssl libssl-dev lsof curl wget


# Install Node.js using nvm
ENV NODE_VERSION=18.16.0
ENV NVM_DIR=/root/.nvm
ENV PATH="${NVM_DIR}/versions/node/v${NODE_VERSION}/bin:${PATH}"
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash && \
    . "$NVM_DIR/nvm.sh" && \
    nvm install ${NODE_VERSION} && \
    nvm use v${NODE_VERSION} && \
    nvm alias default v${NODE_VERSION} && \
    npm -g install junit-report-merger

# Install Yarn using npm
RUN npm install --global yarn

# Clone the react-hook-form repository and checkout a specific commit
RUN git clone https://github.com/carbon-app/carbon.git
WORKDIR /carbon
RUN git checkout baba32a2da17dfdb58bb188e9f89f507b3b072ed

# install cypress dependencies
RUN apt-get update && apt-get install -y \
    libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 xauth xvfb

RUN yarn
RUN npm run build --if-present

RUN mkdir test-results
RUN chmod -R 755 test-results
# Copy the test script to the container
COPY --chmod=0755 test.sh /test.sh
ENV EXECUTIONS=5
# Run the test script
CMD ["/bin/bash", "-c", "/test.sh $EXECUTIONS"]
