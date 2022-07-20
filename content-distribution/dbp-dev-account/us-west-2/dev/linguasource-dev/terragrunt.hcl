# member-account: dbp-dev

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "git::https://github.com/faithcomesbyhearing/fcbh-infrastructure-modules.git//linguasource-web?ref=v0.1.7"
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
# certificate arn:aws:acm:us-east-1:295824083926:certificate/83871135-66ad-4dee-93bb-4d0d216b51f1 is from FCBH Primary / us-east-1, with domain wildcard (*.dbt.io)
inputs = {
  environment = "dev"
  # vpc_id = dependency.vpc.outputs.vpc_id
  # ecs_subnets = dependency.vpc.outputs.public_subnet_ids
  # ecs_security_group = dependency.vpc.outputs.vpc_default_security_group_id
  # lambda_subnets = dependency.vpc.outputs.private_subnet_ids
  # lambda_security_group = dependency.vpc.outputs.vpc_default_security_group_id
  acm_certificate_arn = "arn:aws:acm:us-east-1:078432969830:certificate/84f16453-8430-4f58-a5c9-0d5366633c68"  
  # database_host = "biblebrain-contentdev-rds.cluster-c43uzts2g90s.us-west-2.rds.amazonaws.com"
  # database_db_name = "dbp_TEST"
  # database_user = "sa"
  # s3_bucket = "dbp-staging"
  # s3_vid_bucket = "dbp-vid-staging"
  # s3_artifacts_bucket = "dbp-etl-artifacts-dev"
  alias = "linguasource.dev.dbt.io"  
  # assume_role_arn = "arn:aws:iam::869054869504:role/dbp-etl-dev"
  source_repository = "https://github.com/faithcomesbyhearing/linguasource-web.git"  
  source_repository_branch = "develop"    
}