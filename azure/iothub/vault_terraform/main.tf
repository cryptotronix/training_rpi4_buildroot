#------------------------------------------------------------------------------
# The best practice is to use remote state file and encrypt it since your
# state files may contains sensitive data (secrets).
#------------------------------------------------------------------------------

# Use Vault provider
provider "vault" {}
