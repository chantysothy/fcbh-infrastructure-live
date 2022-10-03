# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  account_name   = "obt-dev"
  aws_account_id = "121033846327"
  aws_profile = "obt-dev"
}
