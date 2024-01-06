#!/bin/bash

# Check for GCC and install if not present
if ! command -v wget &> /dev/null; then
    echo "wget is not installed. Installing wget..."
    sudo apt update && sudo apt install wget -y
fi

# Check if pbhelper was successfully downloaded
if [ ! -f pbhelper ]; then
    echo "Compilation failed."
    exit 1
fi

# Download PBhelper from this repo
wget https://raw.githubusercontent.com/DeadPool-4422/kernel_realme_RMX2001/droidian/helpers/power-button/pbhelper

# Copy the compiled program to /usr/bin
sudo cp pbhelper /usr/bin/

# Create a systemd service
sudo bash -c 'echo -e "[Unit]\nDescription=Pbhelper Service\nAfter=multi-user.target\n\n[Service]\nType=simple\nUser=root\nExecStart=/usr/bin/pbhelper\nRestart=on-failure\n\n[Install]\nWantedBy=multi-user.target" > /etc/systemd/system/pbhelper.service'

# Enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable pbhelper.service
sudo systemctl start pbhelper.service

echo "Setup complete. The button service is now installed and running."
