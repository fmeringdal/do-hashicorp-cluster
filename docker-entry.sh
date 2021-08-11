#!/bin/bash

if [[ -z "${DO_TOKEN}" ]]; then
	echo "DO_TOKEN env var not set. Exiting."
	exit 1
fi

# Default terraform do_token input variables to this token
echo "TF_VAR_do_token=$DO_TOKEN" >> /root/.bashrc 
export TF_VAR_do_token=$DO_TOKEN 
# Default packer do_token input variables to this token
echo "PKR_VAR_do_token=$DO_TOKEN" >> /root/.bashrc 
export PKR_VAR_do_token=$DO_TOKEN 

/bin/bash