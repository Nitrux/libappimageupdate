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
    gir1.2-freedesktop/trixie \
    gir1.2-glib-2.0/trixie \
    git \
    gnupg2 \
    libcairo2-dev \
    libcurl4-nss-dev \
    libfuse-dev \
    libgcrypt20-dev \
    libgirepository-1.0-1/trixie \
    libglib2.0-0/trixie \
    libglib2.0-bin/trixie \
    libglib2.0-dev-bin/trixie \
    libglib2.0-dev/trixie \
    librsvg2-dev \
    libssh2-1-dev \
    libssl-dev \
    libtool \
    pkg-config \
    python3-dev \
    wget
    xxd \
    zlib1g-dev
