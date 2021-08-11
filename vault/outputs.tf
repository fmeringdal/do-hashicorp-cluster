output "nomad_server_token_cmd" {
  value = "vault token create -policy ${vault_policy.nomad_server.name} -period 72h -orphan"
}

output "nomad_server_policy_name" {
  value = vault_policy.nomad_server.name
}