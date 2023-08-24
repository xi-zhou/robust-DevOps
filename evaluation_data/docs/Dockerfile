ARG image_tag
FROM gitlab.lrz.de:5005/robust-devops/students/noise-tool-chiemsee/base_image${image_tag}

ENV NODE_VERSION=18.16.0
ENV NVM_DIR=/root/.nvm
ENV PATH="${NVM_DIR}/versions/node/v${NODE_VERSION}/bin:${PATH}"

# Install required packages and dependencies
RUN apt-get update && \
    apt-get install -y \
    openssl \
    libssl-dev \
    lsof

# Install Node.js and NPM
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash && \
    . "$NVM_DIR/nvm.sh" && \
    nvm install ${NODE_VERSION} && \
    nvm use v${NODE_VERSION} && \
    nvm alias default v${NODE_VERSION} && \
    npm install -g npm

# Clone the docs repository and checkout a specific commit
WORKDIR /docs
RUN git init && \
    git remote add origin https://github.com/github/docs.git && \
    git fetch --depth 1 origin 99ea0fc265ff65bed32d0389cfa7f0ab5a726e7d && \
    git checkout FETCH_HEAD

# Install dependencies and build the project
WORKDIR /docs/.packages/site
RUN npm ci --include=optional && \
    npx playwright install chrome && \
    npm run build

# Copy the test script to the container
COPY --chmod=0755 test.sh /test.sh

# Run the test script
ENV EXECUTIONS=25
CMD ["/bin/bash", "-c", "/test.sh $EXECUTIONS"]
