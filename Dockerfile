FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends verilator make g++ python3 ccache && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /work
