#!/bin/bash

SERVER_DROPLET_IPS=$(terraform output server_droplet_ips)
INGRESS_IP=$(terraform output ingress_droplet_ip)
# Remove double quotes
INGRESS_IP=$(echo "$INGRESS_IP" | tr -d '"')


NOMAD_VAULT_POLICY_NAME=$(terraform -chdir=../vault output nomad_server_policy_name)
# Remove double quotes
NOMAD_VAULT_POLICY_NAME=$(echo "$NOMAD_VAULT_POLICY_NAME" | tr -d '"')
NOMAD_VAULT_TOKEN=$(vault token create -policy $NOMAD_VAULT_POLICY_NAME -period 72h -orphan)
NOMAD_VAULT_TOKEN=$(echo $NOMAD_VAULT_TOKEN | grep -o 'token [^ ]*' | awk '{print $2}')

IFS=',' read -r -a NOMAD_SERVERS <<< "$SERVER_DROPLET_IPS"

# SSH into each nomad server and insert vault token to its config
for NOMAD_SERVER in "${NOMAD_SERVERS[@]}"
do

# Remove double quotes
NOMAD_SERVER=$(echo "$NOMAD_SERVER" | tr -d '"')

echo "Trying to connect to nomad server root@$NOMAD_SERVER ..."
ssh -i ./id_rsa -o StrictHostKeyChecking=no -o ProxyCommand="ssh -i ./id_rsa -o StrictHostKeyChecking=no -W %h:%p root@$INGRESS_IP" root@$NOMAD_SERVER /bin/bash << EOF
	echo "Successfully connected to server via ingress!"

	# Insert the vault token to nomad config file
	sed -i 's/NOMAD_VAULT_TOKEN/$NOMAD_VAULT_TOKEN/' /etc/nomad.d/nomad.hcl
	# Restart nomad to pick up the changes to its config file
	sudo systemctl restart nomad

	echo "Done"
	echo "Exiting server ..."
EOF
echo "Exited from server $NOMAD_SERVER"
done
exit 0

echo "Done configuring nomad servers"
