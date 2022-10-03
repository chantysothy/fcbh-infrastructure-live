# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "git::https://github.com/faithcomesbyhearing/fcbh-infrastructure-modules.git//vpc?ref=v0.1.7"
}

#Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# Couchbase cluster configuration is contained in a CloudFormation template associated with the AWS Marketplace subscription called 
# "Couchbase Server and Sync Gateway (BYOL)". 

inputs = {

  namespace = "render"
  stage     = "dev"
  name      = "vpc"

  cidr_block = "172.10.0.0/16" 

}
