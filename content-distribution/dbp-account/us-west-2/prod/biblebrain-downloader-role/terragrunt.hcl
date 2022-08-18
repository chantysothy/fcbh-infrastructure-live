# member-account: dbp

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "git::https://github.com/faithcomesbyhearing/fcbh-infrastructure-modules.git//dbp-etl-role?ref=v0.1.7"
}

#Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# dependency "dbp-etl" {
#   config_path = "../../../../dbp-dev-account/us-west-2/dev/dbp-etl-newdata"
# }

inputs = {
  environment = "dev"
  max_session_duration = 43200  
  s3_source_buckets = [
    "dbp-prod",
    "dbp-vid",
  ]
  s3_downloader_bucket = [ 
    "biblebrain-downloader" 
  ]  
}
