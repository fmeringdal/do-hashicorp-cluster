FROM ubuntu:20.04

# Update
RUN apt-get -y update \
	&& apt-get -y dist-upgrade

# Install some prerequisites and utils
RUN apt-get -y install \
	curl \
	gnupg2 \
	lsb-release \
	software-properties-common \
	vim \
	openssh-client \
	jq

# Install vault, nomad, terraform, packer and consul
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
RUN apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
RUN apt-get -y install vault nomad consul terraform packer

# https://github.com/hashicorp/vault/issues/10924#issuecomment-846123151
RUN apt-get install --reinstall -y vault

# These will be valid when SSH tunnels are up and running
ENV CONSUL_HTTP_ADDR=127.0.0.1:8500
ENV VAULT_ADDR=http://127.0.0.1:8200
ENV NOMAD_ADDR=http://127.0.0.1:4646


COPY docker-entry.sh /scripts/docker-entry.sh
RUN chmod +x /scripts/docker-entry.sh
CMD ["/scripts/docker-entry.sh"]
