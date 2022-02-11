# member-account: dbp-dev

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "git::https://github.com/faithcomesbyhearing/fcbh-infrastructure-modules.git//elasticache?ref=v0.1.7"
}

#Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id = "temporary-dummy-id"
    private_subnet_ids = []
    vpc_default_security_group_id = ""
  }
}

inputs = {
  namespace       = "dbp"
  stage           = "altdev"
  name            = "memcached1.6"
  vpc_id          = dependency.vpc.outputs.vpc_id
  private_subnets = dependency.vpc.outputs.private_subnet_ids
  allowed_security_groups = [dependency.vpc.outputs.vpc_default_security_group_id]  
  engine_version = "1.6.6"
  max_item_size   = 20971520
}
