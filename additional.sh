#! /bin/bash

# This script should be run with root priviledges.
if [[ "$EUID" -ne 0 ]]; then
    echo -e "\nThis script should be run with root priviledges.\n"
    exit 1
fi

# Updating the apt repositories, and installing basic packages.
apt update -y && apt upgrade -y && \
    apt install -y tig && \
    apt install -y htop && \
    apt install -y pdftk && \
    apt install -y texlive-full texlive-xetex && \
    apt install -y inkscape

# Youtube-DL:
apt install -y ffmpeg libsox-fmt-mp3
curl -L https://yt-dl.org/downloads/latest/youtube-dl \
    -o /usr/local/bin/youtube-dl
chmod a+rx /usr/local/bin/youtube-dl

# Remarkable Markdown:
curl -L https://remarkableapp.github.io/files/remarkable_1.87_all.deb \
    -o remarkable_markdown.deb 
apt install ./remarkable_markdown.deb
rm -fr remarkable_markdown.deb
