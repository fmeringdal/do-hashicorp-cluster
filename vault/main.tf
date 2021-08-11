
terraform {
  required_version = ">= 0.11.8"
}

provider "vault" {
  address = "http://127.0.0.1:8200"
}