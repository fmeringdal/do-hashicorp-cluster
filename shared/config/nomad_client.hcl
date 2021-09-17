data_dir = "/opt/nomad/data"
# https://discuss.hashicorp.com/t/nomad-server-client-cant-connect-to-each-other-under-consul-connect/16707
bind_addr = "IP_ADDRESS"

# Enable the client
client {
  enabled = true
  options {
    "driver.raw_exec.enable" = "1"
    "docker.privileged.enabled" = "true"
  }
  // servers = ["RETRY_JOIN"]
}

consul {
  address = "127.0.0.1:8500"
}

vault {
  enabled = true
  address = "http://active.vault.service.consul:8200"
}

telemetry {
  collection_interval = "1s"
  disable_hostname = true
  prometheus_metrics = true
  publish_allocation_metrics = true
  publish_node_metrics = true
}