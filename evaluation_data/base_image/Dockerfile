FROM ubuntu:22.04
RUN apt-get update && apt-get install -y \
    git curl build-essential python3.10 python3-pip stress-ng stress iproute2
RUN pip install aggregate-test-results --index-url https://gitlab.lrz.de/api/v4/projects/140733/packages/pypi/simple
# Copy noise_tool tarball if it exists
COPY Dockerfile *noise_tool.tar.gz ./

# install our project from tarball (if exists) or gitlab package registry
RUN if [ -f "./noise_tool.tar.gz" ]; then \
    pip install ./noise_tool.tar.gz; \
    else \
    pip install noise-tool --index-url https://gitlab.lrz.de/api/v4/projects/140223/packages/pypi/simple; \
    fi

#RUN pip install noise-tool --index-url https://gitlab.lrz.de/api/v4/projects/140223/packages/pypi/simple


# Copy the test script to the container
COPY --chmod=0755 noise-tool_setup.sh /noise-tool_setup.sh


# Setup noise, example how to use
#RUN ["noise-tool", "config", "--write", "concurrency --cores 1 --threads 1\nfuzz-load --cpu 10 --ram 20"]
#-OR
#RUN noise-tool config --write $'concurrency --cores 1 --threads 1\nfuzz-load --cpu 10 --ram 20'
#-OR
#RUN noise-tool config --write "concurrency --cores 1 --threads 1"
#RUN noise-tool config --append "fuzz-load --cpu 10 --ram 20"
#Run noise-tool write --config  "memory_io --ram 3 --io 4"
#RUN noise-tool config --write "ram_io --workers 3  --ram 3 --io 4"
#RUN noise-tool config --write "network --delay 20"