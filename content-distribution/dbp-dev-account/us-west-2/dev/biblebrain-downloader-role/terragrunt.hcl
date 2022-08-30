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



inputs = {
  environment = "dev"
  max_session_duration = 43200  
  s3_source_buckets = [
    "dbp-staging",
    "dbp-vid-staging",
  ]
  s3_downloader_bucket = [ 
    "biblebrain-downloader-content-origin-dev-otc00l0j3b9ggbgc" 
  ]  
}
