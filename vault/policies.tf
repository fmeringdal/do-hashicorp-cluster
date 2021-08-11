resource "vault_policy" "admin" {
  name = "admin"

  policy = <<EOT
path "${vault_mount.default_kvv2.path}/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "${vault_mount.db.path}/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
EOT
}

resource "vault_policy" "default_nomad_job" {
  name = "default_nomad_job"

  policy = <<EOT
path "${vault_mount.default_kvv2.path}/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "${vault_mount.db.path}/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
EOT
}

resource "vault_policy" "nomad_server" {
  name = "nomad-server"

  policy = <<EOT
# Allow creating tokens under "nomad-cluster" token role. The token role name
# should be updated if "nomad-cluster" is not used.
path "auth/token/create/nomad-cluster" {
  capabilities = ["update"]
}

# Allow looking up "nomad-cluster" token role. The token role name should be
# updated if "nomad-cluster" is not used.
path "auth/token/roles/nomad-cluster" {
  capabilities = ["read"]
}

# Allow looking up the token passed to Nomad to validate # the token has the
# proper capabilities. This is provided by the "default" policy.
path "auth/token/lookup-self" {
  capabilities = ["read"]
}

# Allow looking up incoming tokens to validate they have permissions to access
# the tokens they are requesting. This is only required if
# `allow_unauthenticated` is set to false.
path "auth/token/lookup" {
  capabilities = ["update"]
}

# Allow revoking tokens that should no longer exist. This allows revoking
# tokens for dead tasks.
path "auth/token/revoke-accessor" {
  capabilities = ["update"]
}

# Allow checking the capabilities of our own token. This is used to validate the
# token upon startup.
path "sys/capabilities-self" {
  capabilities = ["update"]
}

# Allow our own token to be renewed.
path "auth/token/renew-self" {
  capabilities = ["update"]
}

EOT
}

resource "vault_token_auth_backend_role" "nomad_cluster" {
  role_name              = "nomad-cluster"
  allowed_policies       = [vault_policy.default_nomad_job.name]
  disallowed_policies    = [vault_policy.nomad_server.name]
  orphan                 = true
  token_period           = 259200
  renewable              = true
  token_explicit_max_ttl = 0
}