#!/bin/bash

sudo apt install -y git build-essential python3 python3-pip rustc cargo

sudo apt install -y rustscan

if [ ! -d "Decodify" ]; then
    git clone https://github.com/s0md3v/Decodify.git
    cd Decodify
    pip3 install -r requirements.txt
    cd ..
else
    echo "Decodify already cloned."
fi

if [ ! -d "StegCracker" ]; then
    git clone https://github.com/Paradoxis/StegCracker.git
    cd StegCracker
    pip3 install -r requirements.txt
    cd ..
else
    echo "StegCracker already cloned."
fi

if [ ! -d "pdfrip" ]; then
    git clone https://github.com/mufeedvh/pdfrip.git
    cd pdfrip
    cargo build --release
    cd ..
else
    echo "PDFRip already cloned."
fi

pip3 install -r requirements.txt || echo "No requirements.txt file found."

echo "Setup completed. Tools installed and dependencies set up."
