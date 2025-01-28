#!/usr/bin/env bash

set -euo pipefail

apt update 
#apt upgrade -y
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade

apt install -y curl wget jq net-tools
apt install -y git-all maven
apt install -y openjdk-17-jdk-headless

timedatectl set-timezone 'Asia/Seoul'
timedatectl set-ntp true

netplan apply