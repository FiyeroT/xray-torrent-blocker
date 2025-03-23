#!/bin/bash

set -e

if [ "$EUID" -ne 0 ]; then
  echo "Please run the script with root privileges (sudo)."
  exit 1
fi

echo "Installing necessary dependencies..."
if command -v apt-get &> /dev/null; then
  apt-get update -qq
  apt-get install -y ipset > /dev/null
else
  echo "Unable to determine package manager. Please install ipset manually."
  exit 1
fi

ARCH=""
if [ "$(uname -m)" == "x86_64" ]; then
  ARCH="amd64"
else
  echo "Unsupported architecture."
  exit 1
fi

echo "Downloading the latest version of torrent-blocker..."
URL="https://github.com/fiyerot/xray-torrent-blocker/releases/latest/download/tblocker-linux-amd64"

mkdir -p /opt/tblocker
wget -O /opt/tblocker/tblocker "$URL"

CONFIG_PATH="/opt/tblocker/config.yaml"
CONFIG_URL="https://raw.githubusercontent.com/fiyerot/xray-torrent-blocker/main/config.yaml.example"

if [ ! -f "$CONFIG_PATH" ]; then
  wget -O "$CONFIG_PATH" "$CONFIG_URL"
  echo "New configuration file created at $CONFIG_PATH"
else
  echo "Configuration file already exists. Checking its contents..."
fi

echo "Setting up systemd service..."
wget -O /etc/systemd/system/tblocker.service https://raw.githubusercontent.com/fiyerot/xray-torrent-blocker/main/tblocker.service

systemctl daemon-reload
systemctl enable tblocker
systemctl start tblocker

systemctl status tblocker --no-pager
