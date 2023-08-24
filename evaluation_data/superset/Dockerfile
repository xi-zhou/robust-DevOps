ARG image_tag
FROM gitlab.lrz.de:5005/robust-devops/students/noise-tool-chiemsee/base_image${image_tag}

RUN apt-get update && apt-get install -y \
    git git-core curl build-essential libssl-dev libffi-dev python3-dev python3-pip libsasl2-dev libldap2-dev default-libmysqlclient-dev \
    libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 xauth xvfb \
    libecpg-dev postgresql-client \
    wget socat

#ENV NODE_VERSION=18.16.0
ENV NODE_VERSION=16.20.0
RUN apt install -y curl
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"
RUN node --version
RUN npm --version

# Install required packages
RUN apt-get update && \
    apt-get install -y \
    openssl libssl-dev lsof
RUN npm install -g pnpm
ENV PATH="$PATH:$HOME/.local/bin"

# Install python3.9 (required by tox)
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y python3.9 python3.9-distutils python3.9-dev

# install Chromebrowser
RUN \
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
  echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list && \
  apt-get update && \
  apt-get install -y dbus-x11 google-chrome-stable && \
  rm -rf /var/lib/apt/lists/*

# Clone the superset repository and checkout a specific commit
WORKDIR /superset
RUN git clone https://github.com/apache/superset.git . && \
    git checkout 40fffc396c5206b38ae1be63c05c08f43908d576

# Install Postgres Python Adapter
RUN pip install --no-cache-dir --upgrade pip \
  && pip install --no-cache-dir -r requirements/testing.txt \ 
  && pip install --no-cache-dir psycopg2

# Install further eval requirements
RUN npm install -g junit-report-merger

# Copy the test script to the container
COPY --chmod=0755 test.sh /test.sh

# Run the test script
WORKDIR /superset
ENV EXECUTIONS=100
ENTRYPOINT ["/bin/bash"]
CMD ["-c", "/test.sh $EXECUTIONS"]