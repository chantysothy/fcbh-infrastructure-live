# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

# terraform {
# # # For any terraform commands that use locking, make sure to configure a lock timeout of 20 minutes.
#   extra_arguments "set_download_dir" {
#     commands  = get_terraform_commands_that_need_locking()
#     arguments = ["--terragrunt-download-dir=~/git/fcbh-infrastructure-live/download"]
#   }

# #   # --terragrunt-download-dir=~/git/fcbh-infrastructure-live/download
# }

locals {
  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract the variables we need for easy access
  account_name = local.account_vars.locals.account_name
  account_id   = local.account_vars.locals.aws_account_id
  aws_profile  = local.account_vars.locals.aws_profile
  aws_region   = local.region_vars.locals.aws_region

}

# Generate an AWS provider block
# 7/20/22 - due to error in biblebrain-downloader-role (AWS provider 3.74),
# changed shared_credentials_files to shared_credential_file, and changed it from list to string.
# will this thrash between errors?
# 7/21/22 - yep, upgrading to AWS provider 4.22 resulted in shared_credential_file being deprecated..
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
  profile = "${local.aws_profile}"
  shared_credentials_files = ["$HOME/.aws/credentials"]
  # Only these AWS Account IDs may be operated on by this template
  allowed_account_ids = ["${local.account_id}"]
}
EOF
}

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "s3"
  config = {
    encrypt = true
    bucket  = "${get_env("TG_BUCKET_PREFIX", "")}fcbh-infrastructure-terraform-state-${local.account_name}-${local.aws_region}"
    key     = "${path_relative_to_include()}/terraform.tfstate"
    region  = local.aws_region
    profile = local.aws_profile

    dynamodb_table = "terraform-locks"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}


# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = merge(
  local.account_vars.locals,
  local.region_vars.locals,
  local.environment_vars.locals,
)

