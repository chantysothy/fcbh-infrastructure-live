# member-account: dbp-dev

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
# certificate arn:aws:acm:us-east-1:596282610570:certificate/9ca85cb7-cd09-4996-afc7-b29a4c4bc9f1 is from DBP account / us-east-1, with domain wildcard (*.biblebrain.com)
inputs = {
  environment = "dev"
  acm_certificate_arn = "arn:aws:acm:us-east-1:596282610570:certificate/9ca85cb7-cd09-4996-afc7-b29a4c4bc9f1"  
  alias = "dev.downloader.biblebrain.com"  
  source_repository = "https://github.com/faithcomesbyhearing/biblebrain-downloader-web.git"  
  source_repository_branch = "develop"
}