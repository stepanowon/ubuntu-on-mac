#!/usr/bin/env bash

set -euo pipefail

apt update -y
apt upgrade -y

apt install -y curl wget jq net-tools
apt install -y git-all maven
apt install -y openjdk-17-jdk-headless

timedatectl set-timezone 'Asia/Seoul'
timedatectl set-ntp true
