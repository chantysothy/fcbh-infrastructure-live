# member-account: dbp

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "git::https://github.com/faithcomesbyhearing/fcbh-infrastructure-modules.git//biblebrain-downloader-web?ref=v0.1.7"
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
  environment = "prod"
  acm_certificate_arn = "arn:aws:acm:us-east-1:078432969830:certificate/84f16453-8430-4f58-a5c9-0d5366633c68"  
  # alias = "linguasource.dev.dbt.io"  
  source_repository = "https://github.com/faithcomesbyhearing/biblebrain-downloader-web.git"  
  source_repository_branch = "main"
}