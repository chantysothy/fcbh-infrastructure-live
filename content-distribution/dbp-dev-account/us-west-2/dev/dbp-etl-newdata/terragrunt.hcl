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

dependency "rds" {
  config_path = "../rds-alt"
  mock_outputs = {
    endpoint        = ""
    reader_endpoint = ""
  }
}

inputs = {
  environment = "newdata"
  vpc_id = dependency.vpc.outputs.vpc_id
  ecs_subnets = dependency.vpc.outputs.public_subnet_ids
  ecs_security_group = dependency.vpc.outputs.vpc_default_security_group_id
  lambda_subnets = dependency.vpc.outputs.private_subnet_ids
  lambda_security_group = dependency.vpc.outputs.vpc_default_security_group_id
  database_host = dependency.rds.outputs.endpoint
  database_db_name = "dbp_NEWDATA"
  database_user = "etl"
  acm_certificate_arn = "arn:aws:acm:us-east-1:078432969830:certificate/6d4e6f6b-85b2-49f6-9064-50b16176e8b5"
  alias = "etl.dev.dbt.io"
  s3_bucket = "dbp-prod"
  s3_vid_bucket = "dbp-vid"
  s3_artifacts_bucket = "dbp-etl-artifacts"  
  assume_role_arn = "arn:aws:iam::869054869504:role/dbp-etl-prod"
  etl_source_repository = "https://github.com/faithcomesbyhearing/dbp-etl.git"  
  etl_source_repository_branch = "master"    
  etl_web_source_repository = "https://github.com/faithcomesbyhearing/dbp-etl-web.git"  
  etl_web_source_repository_branch = "main"  
}
