# member-account: dbp-dev

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "git::https://github.com/faithcomesbyhearing/fcbh-infrastructure-modules.git//dbp-etl?ref=v0.1.7"
}

#Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id                        = "temporary-dummy-id"
    public_subnet_ids             = []
    private_subnet_ids            = []
    vpc_default_security_group_id = ""
  }
}

inputs = {
  environment = "dev"
  vpc_id = dependency.vpc.outputs.vpc_id
  ecs_subnets = dependency.vpc.outputs.public_subnet_ids
  ecs_security_group = dependency.vpc.outputs.vpc_default_security_group_id
  lambda_subnets = dependency.vpc.outputs.private_subnet_ids
  lambda_security_group = dependency.vpc.outputs.vpc_default_security_group_id
  database_host = "dbp-dev-api.cluster-c43uzts2g90s.us-west-2.rds.amazonaws.com"
  database_db_name = "dbp_TEST"
  s3_bucket = "dbp-staging"
  s3_vid_bucket = "dbp-vid-staging"
  s3_artifacts_bucket = "dbp-etl-artifacts-dev"
  assume_role_arn = "arn:aws:iam::869054869504:role/dbp-etl-dev"
}
