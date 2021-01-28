resource "vault_pki_secret_backend" "pki" {
  path = "pki"
}

resource "vault_pki_secret_backend_root_cert" "azure_root_ca" {
  depends_on = [ vault_pki_secret_backend.pki ]
  backend = vault_pki_secret_backend.pki.path
  type = "internal"
  common_name = "AZ_CA"
  ttl = "350640h"
  format = "pem"
  private_key_format = "der"
  key_type = "ec"
  key_bits = "256"
  exclude_cn_from_sans = true
  ou = "AZ_Demo"
  organization = "Advanced_Security_Training"
  country = "US"
}

resource "vault_pki_secret_backend_role" "device" {
  backend = vault_pki_secret_backend.pki.path
  name = "device"
  ttl = "730h"
  allow_any_name = true
  client_flag = true
  require_cn = true
  key_type = "ec"
  key_bits = "256"
}
