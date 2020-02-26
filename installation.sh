#!/bin/bash
echo "Installation of Elabox..."

# parameters
GITHUB_USER=ademcan
GITHUB_TOKEN=42c8770f7a252e0b935f1e1c9feaad1c21a5e381
ELABOX_HOME=/home/elabox
# ELA_VERSION=
# DID_VERSION=
# CARRIER_VERSION=
BINARY_DIR=/home/elabox/binaries

# Add elabox user
sudo adduser elabox
# Add elabox user to sudo group
sudo usermod -aG sudo elabox

# Format and mount the USB storage
# check that USB is mounted on /dev/sda with sudo fdisk -l
echo 'y' | sudo mkfs.ext4 /dev/sda
# sudo chown -R ubuntu:ubuntu /home/elabox/
sudo mount /dev/sda /home/elabox/
# check the unique identifier of /dev/sda
USD_UUID=$(sudo blkid | grep /dev/sda | cut -d '"' -f 2)
# update the /etc/fstab file to auto-mount the disk on startup
echo "UUID=${USD_UUID} /home/elabox/ ext4 defaults 0 0" >> /etc/fstab


# configurations
# cd ${ELABOX_HOME}
# git config --global user.name "${GITHUB_USER}"
# git clone https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/elabox-back-end

# 1 - SSH security / turn off at the end

echo 'Y' | sudo apt install fail2ban avahi-daemon tar

# open the different ports with ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
# SSH port
sudo ufw allow 22
# companiont app port
sudo ufw allow 80
# elabox back-end port
sudo ufw allow 3001
# ELA DPoS port
sudo ufw allow 20339
# ELA port for SPV peers
sudo ufw allow 20338
# ELA RPC port
sudo ufw allow 20336
# ELA REST port
sudo ufw allow 20334
# DID REST port
sudo ufw allow 20604
# DID RPC port
sudo ufw allow 20606
# DID node port
sudo ufw allow 20608
sudo ufw enable

# 2 - create supernode and elabox directories
mkdir ${ELABOX_HOME}/supernode ${ELABOX_HOME}/supernode/{did,ela,carrier}
# get ela binary and config file
cp ${BINARY_DIR}/ela ${ELABOX_HOME}/supernode/ela
cp ${BINARY_DIR}/ela-cli ${ELABOX_HOME}/supernode/ela
chmod +x ${ELABOX_HOME}/supernode/ela/ela ${ELABOX_HOME}/supernode/ela/ela-cli
cp ${BINARY_DIR}/ela_config.json ${ELABOX_HOME}/supernode/ela
mv ${ELABOX_HOME}/supernode/ela/ela_config.json ${ELABOX_HOME}/supernode/ela/config.json
# get did binary and config file
cp ${BINARY_DIR}/did ${ELABOX_HOME}/supernode/did
chmod +x ${ELABOX_HOME}/supernode/did/did
cp ${BINARY_DIR}/did_config.json ${ELABOX_HOME}/supernode/did
mv ${ELABOX_HOME}/supernode/did/did_config.json ${ELABOX_HOME}/supernode/did/config.json
# get carrier binary and config file
cp ${BINARY_DIR}/ela-bootstrapd ${ELABOX_HOME}/supernode/carrier
# mv ${BINARY_DIR}/ela-bootstrapd -P ${ELABOX_HOME}/supernode/carrier

# create and starts the companion
mkdir ${ELABOX_HOME}/{server,companion}

# Install avahi-daemon
echo "Installing avahi-daemon..."
# Update hostname to elabox
echo "Updating hostname..."
sudo echo "elabox" > /etc/hostname

# Installing and configuring webserver (nginx)
# git clone the companion app to correct path

# git clone the server app to correct path



# Installing tor to get .onion address
mkdir /var/lib/tor/elabox
sudo chown debian-tor:debian-tor /var/lib/tor/elabox
# check if needed
chmod g-s elabox

# add the webserver and SSH to tor
echo "\nHiddenServiceDir /var/lib/tor/elabox/" >> /etc/tor/torrc
echo "HiddenServicePort 80 127.0.0.1:80" >> /etc/tor/torrc
echo "HiddenServicePort 22 127.0.0.1:22\n" >>  /etc/tor/torrc 
sudo systemctl restart tor@default


# connect from mac
ssh -o ProxyCommand="ncat --proxy-type socks5 --proxy 127.0.0.1:9150 %h %p" ubuntu@ydu7muawyhutwuhuwo4udz56xdp7zpp7jvetgggp7knw5qzafutfajad.onion


# 3 - update the scripts to run on start


# 4 - add the carrier script (IP check) to CRON


# Delete user ubuntu
deluser --remove-home ubuntu