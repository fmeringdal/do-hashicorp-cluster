#!/bin/bash

echo ""
echo "Open https://cloud.digitalocean.com/spaces"
echo "Click on 'Create a Space'"
echo -n "Configure this space in the same region you want to deploy to and "
echo -n "write down the name you used. You will need it in the next step"
echo ""
echo ""

# https://<bucket-name>.<region>.digitaloceanspaces.com
read -p 'Endpoint URL: ' ENDPOINT_URL
echo 

IFS='//'
read -ra ADDR <<< "$ENDPOINT_URL"
BUCKET_URL="${ADDR[2]}"

# https://www.tutorialkart.com/bash-shell-scripting/bash-split-string/
IFS='.'
read -ra ADDR <<< "$BUCKET_URL"
BUCKET_NAME="${ADDR[0]}"
REGION="${ADDR[1]}"
IFS=' '

echo "Bucket Name: ${BUCKET_NAME}"
echo "Bucket Region: ${REGION}"

echo ""
echo "Next you'll need to generate some credentials. Head to this URL:"
echo ""
echo "https://cloud.digitalocean.com/settings/api/tokens"
echo ""
echo "Under 'Spaces access keys' click 'Generate New Key'"
echo ""


read -sp "Access Key: " ACCESS_KEY
echo ""
read -sp "Secret Key: " SECRET_KEY
echo ""


echo "skip_credentials_validation = true" >> ./backend.hcl
echo "skip_metadata_api_check     = true" >> ./backend.hcl
echo "" >> ./backend.hcl
echo "bucket                 = \"${BUCKET_NAME}\"" >> ./backend.hcl
echo "region                 = \"${REGION}\"" >> ./backend.hcl
echo "skip_region_validation = true" >> ./backend.hcl
echo "endpoint               = \"https://$REGION.digitaloceanspaces.com\"" >> ./backend.hcl
echo "" >> ./backend.hcl
echo "access_key = \"$ACCESS_KEY\"" >> ./backend.hcl
echo "secret_key = \"$SECRET_KEY\"" >> ./backend.hcl

