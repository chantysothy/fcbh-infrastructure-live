# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  account_name   = "dbp-dev"
  aws_account_id = "000000000000"
  aws_profile = "dbp-dev-admin"
}