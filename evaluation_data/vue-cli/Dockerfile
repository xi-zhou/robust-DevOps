ARG image_tag
FROM gitlab.lrz.de:5005/robust-devops/students/noise-tool-chiemsee/base_image${image_tag}

# Install required packages and dependencies
RUN apt-get update && apt-get install -y \
    git-core openssl libssl-dev lsof

# Install Node.js and Yarn
ENV NODE_VERSION=14.17.0
ENV NVM_DIR=/root/.nvm
ENV PATH="${NVM_DIR}/versions/node/v${NODE_VERSION}/bin:${PATH}"
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash && \
    . "$NVM_DIR/nvm.sh" && \
    nvm install ${NODE_VERSION} && \
    nvm use v${NODE_VERSION} && \
    nvm alias default v${NODE_VERSION} && \
    npm install -g yarn && \
    npm install -g junit-report-merger

# Clone the Vue cli repository
RUN git clone https://github.com/vuejs/vue-cli.git
WORKDIR /vue-cli
RUN git checkout f0f254e4bc81ed322eeb9f7de346e987e845068e

# install cypress dependencies
RUN apt-get update && apt-get install -y \
    libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 xauth xvfb


# Set environment variable to disable SSL validation
ENV NODE_TLS_REJECT_UNAUTHORIZED 0 
ENV CYPRESS_ELECTRON_RUNNER_FLAGS="--ignore-certificate-errors"


# Install dependencies
RUN yarn
RUN npx browserslist@latest --update-db


RUN sed -i 's|"test:e2e:start": "vue-cli-service test:e2e --mode production --browser chrome --headless --url=http://localhost:4040"|"test:e2e:start": "vue-cli-service test:e2e --mode development --browser chrome --headless --reporter junit --reporter-options mochaFile=test-results/results_[hash].xml --url=http://localhost:4040"|' packages/@vue/cli-ui/package.json

ENV CYPRESS_CHROME_FLAGS="--no-sandbox --disable-dev-shm-usage"


# Install Google Chrome
RUN echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | tee /etc/apt/sources.list.d/google-chrome.list \
 && curl -sSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /usr/share/keyrings/google-chrome-archive-keyring.gpg \
 && echo "deb [signed-by=/usr/share/keyrings/google-chrome-archive-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | tee /etc/apt/sources.list.d/google-chrome.list \
 && apt-get update \
 && apt-get install -y google-chrome-stable


# set up test reporter
RUN mkdir test-results



COPY --chmod=0755 test.sh /test.sh
ENV EXECUTIONS=100
# Run the test script
CMD ["/bin/bash", "-c", "/test.sh $EXECUTIONS"]