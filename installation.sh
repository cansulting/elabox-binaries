#!/bin/bash
echo "Installation of Elabox..."

##############################
# 1 - Create new user
##############################

# Create elabox user
echo 'Elab0x' | sudo useradd -p $(openssl passwd -1 elabox) elabox
# Add elabox user to sudo group
sudo usermod -aG sudo elabox
# switch user
sudo -s -u elabox

##############################
# Define parameters
##############################

# define parameters
ELABOX_HOME=/home/elabox
BINARY_DIR=/home/elabox/elabox-binaries/binaries
SCRIPTS_DIR=/home/elabox/elabox-binaries

##############################
# Install required packages + Misc
##############################

# add nodejs PPA
echo 'elabox' | curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
# curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
# echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
echo 'Y' | sudo apt update && sudo apt install fail2ban avahi-daemon tar nodejs make build-essential tor nginx zip # yarn
sudo npm_config_user=root npm install -g onoff
# increase size for nodemon files watcher
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p

# add swapfile
# https://askubuntu.com/questions/33697/how-do-i-add-swap-after-system-installation
sudo mkdir -v /var/cache/swap
cd /var/cache/swap
sudo dd if=/dev/zero of=swapfile bs=1K count=4M
sudo chmod 600 swapfile
sudo mkswap swapfile
sudo swapon swapfile
# check
top -bn1 | grep -i swap
# add to fstab
echo "/var/cache/swap/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab

# Delete user ubuntu
sudo deluser --remove-home ubuntu

##############################
# Format and mount USB
##############################

# Format and mount the USB storage to /home/elabox
# check that USB is mounted on /dev/sda with sudo fdisk -l
echo 'y' | sudo mkfs.ext4 /dev/sda
sudo mount /dev/sda /home/elabox/
# check the unique identifier of /dev/sda
USD_UUID=$(sudo blkid | grep /dev/sda | cut -d '"' -f 2)
# update the /etc/fstab file to auto-mount the disk on startup
echo "UUID=${USD_UUID} /home/elabox/ ext4 defaults 0 0" | sudo tee -a /etc/fstab > /dev/null
cd /home/
sudo chown -R elabox:elabox elabox/
cd /home/elabox
sudo rm -rf lost+found/

# check that the external USB is properly mounted on /home/elabox
lsblk

##############################
# Configure firewall
##############################

# open the different ports with ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
# SSH port
sudo ufw allow 22
# companiont app port
sudo ufw allow 80
# elabox back-end port
sudo ufw allow 3001
sudo ufw allow 3002
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
echo 'y' | sudo ufw enable

##############################
# Configure elabox-binaries
##############################

# clone the elabox-binaries repo
git clone https://elaboxx:elabox_2020@github.com/cansulting/elabox-binaries
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
cp ${BINARY_DIR}/bootstrapd.conf ${ELABOX_HOME}/supernode/carrier
chmod +x ${ELABOX_HOME}/supernode/carrier/ela-bootstrapd
chmod 664 ${ELABOX_HOME}/supernode/carrier/bootstrapd.conf

##############################
# Configure elabox-companion
##############################

cd; git clone https://elaboxx:elabox_2020@github.com/cansulting/elabox-companion
cd elabox-companion
# npm
# npm build
sudo mkdir /var/www/elabox
sudo cp -R build /var/www/elabox/build
/etc/init.d/nginx restart

##############################
# Configure elabox-master
##############################

# git clone the server app to correct path
cd /home/elabox/
git clone https://elaboxx:elabox_2020@github.com/cansulting/elabox-master
cd elabox-master
npm install
sudo apt-get install chromium-browser
sudo npm install -g pm2
pm2 start index.js --name ebmaster --watch . --time --log /home/elabox/ebmaster.log
pm2 startup
pm2 save
sudo cp /home/elabox/elabox-master/default /etc/nginx/sites-available/default

##############################
# Configure TOR
##############################

# add the webserver and SSH to tor
echo ""  | sudo tee -a /etc/tor/torrc
echo "HiddenServiceDir /var/lib/tor/elabox/"  | sudo tee -a /etc/tor/torrc
echo "HiddenServicePort 80 127.0.0.1:80" | sudo tee -a /etc/tor/torrc
echo "HiddenServicePort 22 127.0.0.1:22" | sudo tee -a /etc/tor/torrc
echo "HiddenServicePort 3001 127.0.0.1:3001" | sudo tee -a /etc/tor/torrc
echo ""  | sudo tee -a /etc/tor/torrc
sudo systemctl restart tor@default

##############################
# Configure hostname
##############################

# Update hostname to elabox
echo "Updating hostname..."
echo "elabox" | sudo tee /etc/hostname
echo "127.0.0.1 elabox" | sudo tee /etc/hosts
sudo hostnamectl set-hostname elabox
# hostnamectl to check
/etc/init.d/avahi-daemon restart
systemctl restart systemd-logind.service





# Delete history
history -c
history -w