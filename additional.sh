#! /bin/bash

# This script should be run with root priviledges.
if [[ "$EUID" -ne 0 ]]; then
    echo -e "\nThis script should be run with root priviledges.\n"
    exit 1
fi

# Updating the apt repositories, and installing basic packages.
apt-get update -y && apt upgrade -y && \
    apt get -y htop && \
    apt get -y pdftk && \
    apt get -y texlive-full texlive-xetex
