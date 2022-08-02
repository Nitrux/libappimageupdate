#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    APT_COMMAND="sudo apt-get"
else
    APT_COMMAND="apt-get"
fi

$APT_COMMAND update -q
$APT_COMMAND install -qy --no-install-recommends \
    argagg-dev \
    automake \
    ca-certificates \
    checkinstall \
    cmake \
    curl \
    desktop-file-utils \
    g++ \
    git \
    gnupg2 \
    libcairo2-dev \
    libcurl4-nss-dev \
    libfuse-dev \
    libgcrypt20-dev \
    librsvg2-dev \
    libssh2-1-dev \
    libssl-dev \
    libtool \
    pkg-config \
    python3-dev \
    wget
    xxd \
    zlib1g-dev
