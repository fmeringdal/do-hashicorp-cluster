#!/bin/bash

SERVER_DROPLET_IPS=$(terraform output server_droplet_ips)
INGRESS_IP=$(terraform output ingress_droplet_ip)
# Remove double quotes
INGRESS_IP=$(echo "$INGRESS_IP" | tr -d '"')
# Just pick one of the servers to connect to (standby will forward to leader anyways)
SERVER_DROPLET_IP=(${SERVER_DROPLET_IPS[0]})
# Remove double quotes
SERVER_DROPLET_IP=$(echo "$SERVER_DROPLET_IP" | tr -d '"')

# Consul tunnel
ssh -4 -f -N -g -o StrictHostKeyChecking=no -o IdentitiesOnly=yes -i ./id_rsa -L 8500:$SERVER_DROPLET_IP:8500 root@$INGRESS_IP
echo "Consul can be accessed at http://localhost:8500"

# Vault tunnel
ssh -4 -f -N -g -o StrictHostKeyChecking=no -o IdentitiesOnly=yes -i ./id_rsa -L 8200:$SERVER_DROPLET_IP:8200 root@$INGRESS_IP
echo "Vault can be accessed at http://localhost:8200"

# Nomad tunnel
ssh -4 -f -N -g -o StrictHostKeyChecking=no -o IdentitiesOnly=yes -i ./id_rsa -L 4646:$SERVER_DROPLET_IP:4646 root@$INGRESS_IP
echo "Nomad can be accessed at http://localhost:4646"

# Traefik tunnel
ssh -4 -f -N -g -o StrictHostKeyChecking=no -o IdentitiesOnly=yes -i ./id_rsa -L 8081:$INGRESS_IP:8081 root@$INGRESS_IP
echo "Traefik can be accessed at http://localhost:0881 (When it is enabled)"