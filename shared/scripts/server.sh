#!/bin/bash

set -e

CONFIGDIR=/ops/shared/config

CONSULCONFIGDIR=/etc/consul.d
VAULTCONFIGDIR=/etc/vault.d
NOMADCONFIGDIR=/etc/nomad.d
CONSULTEMPLATECONFIGDIR=/etc/consul-template.d
HOME_DIR=ubuntu

# Wait for network
sleep 15

SERVER_COUNT=$1
RETRY_JOIN=$2
NOMAD_BINARY=$3

# Get IP from metadata service
IP_ADDRESS=$(curl http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address)
# IP_ADDRESS="$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')"

# Consul
sed -i "s/IP_ADDRESS/$IP_ADDRESS/g" $CONFIGDIR/consul.json
sed -i "s/SERVER_COUNT/$SERVER_COUNT/g" $CONFIGDIR/consul.json
sed -i "s/RETRY_JOIN/$RETRY_JOIN/g" $CONFIGDIR/consul.json
sudo cp $CONFIGDIR/consul.json $CONSULCONFIGDIR
sudo cp $CONFIGDIR/consul.service /etc/systemd/system/consul.service

# https://learn.hashicorp.com/tutorials/consul/dns-forwarding#systemd-resolved-setup
# Stop port 53 listener
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved

sudo rm /etc/systemd/resolved.conf
sudo mv $CONFIGDIR/resolved.conf /etc/systemd/resolved.conf
sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf

# Now consul can use port 53
export CONSUL_ALLOW_PRIVILEGED_PORTS=yes
sudo systemctl enable consul.service
sudo systemctl start consul.service


sleep 10
export CONSUL_HTTP_ADDR=$IP_ADDRESS:8500
export CONSUL_RPC_ADDR=$IP_ADDRESS:8400

# Vault
sed -i "s/IP_ADDRESS/$IP_ADDRESS/g" $CONFIGDIR/vault.hcl
sudo cp $CONFIGDIR/vault.hcl $VAULTCONFIGDIR
sudo cp $CONFIGDIR/vault.service /etc/systemd/system/vault.service

sudo systemctl enable vault.service
sudo systemctl start vault.service

# Nomad

## Replace existing Nomad binary if remote file exists
if [[ `wget -S --spider $NOMAD_BINARY  2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then
  curl -L $NOMAD_BINARY > nomad.zip
  sudo unzip -o nomad.zip -d /usr/local/bin
  sudo chmod 0755 /usr/local/bin/nomad
  sudo chown root:root /usr/local/bin/nomad
fi

sed -i "s/IP_ADDRESS/$IP_ADDRESS/g" $CONFIGDIR/nomad.hcl
sed -i "s/SERVER_COUNT/$SERVER_COUNT/g" $CONFIGDIR/nomad.hcl
sudo cp $CONFIGDIR/nomad.hcl $NOMADCONFIGDIR
sudo cp $CONFIGDIR/nomad.service /etc/systemd/system/nomad.service

sudo systemctl enable nomad.service
sudo systemctl start nomad.service
sleep 10
export NOMAD_ADDR=http://$IP_ADDRESS:4646

# Consul Template
sudo cp $CONFIGDIR/consul-template.hcl $CONSULTEMPLATECONFIGDIR/consul-template.hcl
sudo cp $CONFIGDIR/consul-template.service /etc/systemd/system/consul-template.service

# Add hostname to /etc/hosts
echo "127.0.0.1 $(hostname)" | sudo tee --append /etc/hosts

# Add Docker bridge network IP to /etc/resolv.conf (at the top)
# echo "nameserver $DOCKER_BRIDGE_IP_ADDRESS" | sudo tee /etc/resolv.conf.new
# cat /etc/resolv.conf | sudo tee --append /etc/resolv.conf.new
# sudo mv /etc/resolv.conf.new /etc/resolv.conf

sudo rm /etc/resolv.conf
sudo cp $CONFIGDIR/resolv.conf /etc/resolv.conf

# Make docker also pickup the newest resolv.conf
sudo systemctl restart docker
 
# Set env vars for tool CLIs
echo "export CONSUL_RPC_ADDR=$IP_ADDRESS:8400" | sudo tee --append /home/$HOME_DIR/.bashrc
echo "export CONSUL_HTTP_ADDR=$IP_ADDRESS:8500" | sudo tee --append /home/$HOME_DIR/.bashrc
echo "export VAULT_ADDR=http://$IP_ADDRESS:8200" | sudo tee --append /home/$HOME_DIR/.bashrc
echo "export NOMAD_ADDR=http://$IP_ADDRESS:4646" | sudo tee --append /home/$HOME_DIR/.bashrc
