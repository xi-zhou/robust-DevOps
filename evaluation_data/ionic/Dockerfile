ARG image_tag
FROM gitlab.lrz.de:5005/robust-devops/students/noise-tool-chiemsee/base_image${image_tag}

RUN apt-get update && apt-get install -y \
    git git-core curl build-essential libssl-dev libffi-dev python3-dev python3-pip libsasl2-dev libldap2-dev default-libmysqlclient-dev \
    libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 xauth xvfb \
    wget

ENV NODE_VERSION=18.16.0
#ENV NODE_VERSION=16.20.0
RUN apt install -y curl
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"
RUN node --version
RUN npm --version

# # Install required packages
# RUN apt-get update && \
#     apt-get install -y \
#     openssl libssl-dev lsof
# RUN npm install -g pnpm
# ENV PATH="$PATH:$HOME/.local/bin"

# install Chromebrowser
RUN \
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
  echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list && \
  apt-get update && \
  apt-get install -y dbus-x11 google-chrome-stable && \
  rm -rf /var/lib/apt/lists/*

# Clone the ionic repository and checkout a specific commit
WORKDIR /ionic
RUN git clone https://github.com/ionic-team/ionic-framework.git . && \
    git checkout e75fa582c4ca507b09f62bbce649f02ca49da7a0

# Set environmental variables

# Install requirements

# # Install dependencies and build the project
WORKDIR /ionic/core
RUN npm install && \
    npm run build
WORKDIR /ionic/packages/vue
RUN npm install && \
    npm run build
WORKDIR /ionic/packages/vue-router/
RUN npm install && \
    npm run build
WORKDIR /ionic/packages/vue/test
RUN ./build.sh vue3
WORKDIR /ionic/packages/vue/test/build/vue3
RUN npm install

# Install further eval requirements
RUN npm install -g junit-report-merger

# Copy the test script to the container
COPY --chmod=0755 test.sh /test.sh

# Run the test script
ENV EXECUTIONS=100
ENTRYPOINT ["/bin/bash"]
CMD ["-c", "/test.sh $EXECUTIONS"]