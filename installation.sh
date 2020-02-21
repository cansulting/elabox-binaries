#!/bin/bash
echo "Installation of Elabox..."

# parameters
GITHUB_USER=ademcan
GITHUB_TOKEN=42c8770f7a252e0b935f1e1c9feaad1c21a5e381
ELABOX_HOME=/home/ubuntu/elabox
# ELA_VERSION=
# DID_VERSION=
# CARRIER_VERSION=
BINARY_DIR=/home/ubuntu/elabox-binaries/binaries

# Format and mount the USB storage
echo 'y' | sudo mkfs.ext4 /dev/sda
sudo mkdir /home/ubuntu/elabox/
sudo chown -R ubuntu:ubuntu /home/ubuntu/elabox/
sudo mount /dev/sda /home/ubuntu/elabox/
# check the unique identifier of /dev/sda
USD_UUID=$(sudo blkid | grep /dev/sda | cut -d '"' -f 2)
# update the /etc/fstab file to auto-mount the disk on startup
echo "UUID=${USD_UUID} /home/ubuntu/elabox/ ext4 defaults 0 0" >> /etc/fstab


# configurations
# cd ${ELABOX_HOME}
# git config --global user.name "${GITHUB_USER}"
# git clone https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/elabox-back-end

# 1 - change SSH default port
# 2 - create supernode and elabox directories
mkdir ${ELABOX_HOME}/supernode ${ELABOX_HOME}/supernode/{did,ela,carrier}
# get ela binary and config file
mv ${BINARY_DIR}/ela ${ELABOX_HOME}/supernode/ela
mv ${BINARY_DIR}/ela-cli ${ELABOX_HOME}/supernode/ela
chmod +x ${ELABOX_HOME}/supernode/ela/ela ${ELABOX_HOME}/supernode/ela/ela-cli
mv ${BINARY_DIR}/ela_config.json ${ELABOX_HOME}/supernode/ela
mv ${ELABOX_HOME}/supernode/ela/ela_config.json ${ELABOX_HOME}/supernode/ela/config.json
# get did binary and config file
mv ${BINARY_DIR}/did ${ELABOX_HOME}/supernode/did
chmod +x ${ELABOX_HOME}/supernode/did/did
mv ${BINARY_DIR}/did_config.json ${ELABOX_HOME}/supernode/did
mv ${ELABOX_HOME}/supernode/did/did_config.json ${ELABOX_HOME}/supernode/did/config.json
# get carrier binary and config file
mv ${BINARY_DIR}/ela-bootstrapd ${ELABOX_HOME}/supernode/carrier
mv ${BINARY_DIR}/ela-bootstrapd -P ${ELABOX_HOME}/supernode/carrier

# create and starts the companion
mkdir ${ELABOX_HOME}/{server,companion}

# Install avahi-daemon
echo "Installing avahi-daemon..."
echo 'Y' | sudo apt-get install avahi-daemon
# Update hostname to elabox
echo "Updating hostname..."
sudo echo "elabox" > /etc/hostname

# Mount external USB disk

# 3 - update the scripts to run on start


# 4 - add the carrier script (IP check) to CRON
