resource "vault_mount" "default_kvv2" {
  path        = "kv"
  type        = "kv-v2"
  description = "Default secret engine mount"
}

resource "vault_mount" "db" {
  path        = "database"
  type        = "database"
  description = "Default database mount"
}

