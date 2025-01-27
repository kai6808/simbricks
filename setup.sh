#!/bin/bash

# Exit on error
set -e

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

# Check if verilator.patch exists
if [ ! -f "verilator.patch" ]; then
    echo "Error: verilator.patch not found in current directory"
    exit 1
fi

echo "Starting SimBricks development environment setup..."

# Update package list
echo "Updating package list..."
apt-get update

# Install dependencies
echo "Installing dependencies..."
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    apt-utils \
    autoconf \
    bc \
    bison \
    build-essential \
    cmake \
    doxygen \
    g++ \
    flex \
    git \
    kmod \
    libboost-coroutine-dev \
    libboost-fiber-dev \
    libboost-iostreams-dev \
    libboost-program-options-dev \
    libelf-dev \
    libglib2.0-dev \
    libgmp-dev \
    libgoogle-perftools-dev \
    libnanomsg-dev \
    libpcap-dev \
    libpixman-1-dev \
    libprotobuf-dev \
    libssl-dev \
    libtool \
    ninja-build \
    protobuf-compiler \
    python-is-python3 \
    python3-dev \
    python3-pip \
    rsync \
    scons \
    unzip \
    wget

# Clean apt cache
rm -rf /var/lib/apt/lists/*

# Install Python packages
echo "Installing Python packages..."
pip install --no-cache-dir --upgrade pip wheel pexpect protobuf thrift psutil graphviz

# Install Verilator
echo "Installing Verilator..."
cd /tmp
git clone -b v4.010 https://github.com/verilator/verilator
cd verilator

# Copy and apply the patch
cp "$(dirname $0)/verilator.patch" .
patch -p1 < verilator.patch

autoupdate
autoconf
./configure
make -j$(nproc)
make install
cd ..
rm -rf verilator

# Install Apache Thrift
echo "Installing Apache Thrift..."
cd /tmp
git clone https://github.com/apache/thrift.git
cd thrift
./bootstrap.sh
./configure
make -j$(nproc)
make install
ldconfig
cd ..
rm -rf thrift

echo "Setup completed successfully!"