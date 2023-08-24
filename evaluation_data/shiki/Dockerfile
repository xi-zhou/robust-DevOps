ARG image_tag
FROM gitlab.lrz.de:5005/robust-devops/students/noise-tool-chiemsee/base_image${image_tag}

RUN apt-get update && apt-get install -y \
    git git-core curl build-essential python3-pip

ENV NODE_VERSION=18.16.0
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

# Clone the shiki repository and checkout a specific commit
WORKDIR /shiki
RUN git clone https://github.com/shikijs/shiki . && \
    git checkout ed61842e982342dc1338c16639e2f868e12152e6

# Install dependencies and build the project
RUN pnpm install && \
    pnpm run update && \
    pnpm run build && \
    pnpm exec playwright install --with-deps chromium

# Copy the test script to the container
COPY --chmod=0755 test.sh /test.sh

# Run the test script
WORKDIR /shiki/.packages/site
ENV EXECUTIONS=25
CMD ["/bin/bash", "-c", "/test.sh $EXECUTIONS"]
