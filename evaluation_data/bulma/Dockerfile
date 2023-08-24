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
    npm install -g junit-report-merger


# Install Ruby and Jekyll
RUN apt-get install -y ruby-full build-essential zlib1g-dev
RUN gem install jekyll bundler webrick

# Clone the Bulma repository
RUN git clone https://github.com/jgthms/bulma.git
WORKDIR /bulma
RUN git checkout 89a8b8f208f44bef1473180dc143faafb9c65168

# Install Cypress dependencies
RUN apt-get update && apt-get install -y \
    libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 xauth xvfb

RUN echo "source 'https://rubygems.org'\n\ngem 'jekyll', '~> 4.2.0'\ngem 'webrick'" > /bulma/docs/Gemfile 

# Install dependencies and build
WORKDIR /bulma/docs
RUN bundle install


RUN find . -type f -print0 | perl -n0e '$new = $_; if($new =~ s/[^[:ascii:]]/_/g) { print("Renaming $_ to $new\n"); rename($_, $new); }'
RUN npm install
RUN npm run bulma-sass


# set up test reporter
RUN mkdir test-results
RUN sed -i 's|"cypress-run": "./node_modules/.bin/cypress run"|"cypress-run": "./node_modules/.bin/cypress run --reporter junit --reporter-options mochaFile=test-results/results_[hash].xml"|' package.json

# Copy the test script to the container
COPY --chmod=0755 test.sh /test.sh
ENV EXECUTIONS=100

# Run the test script
CMD ["/bin/bash", "-c", "/test.sh $EXECUTIONS"]
