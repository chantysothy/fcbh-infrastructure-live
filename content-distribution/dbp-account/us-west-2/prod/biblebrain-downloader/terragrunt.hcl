# dpb-api bastion host

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "git::https://github.com/faithcomesbyhearing/fcbh-infrastructure-modules.git//biblebrain-downloader?ref=v0.1.6"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}


inputs = {

  namespace    = "biblebrain"
  stage        = "prod"
  name         = "downloader"
  downloader_role_arn = "arn:aws:iam::596282610570:role/biblebrain-downloader-prod-a00rjqiqazyjmgwh"
  source_repository = "https://github.com/faithcomesbyhearing/biblebrain-downloader"
  source_repository_branch = "main"
  s3_audio_source_bucket = "dbp-prod"
  s3_video_source_bucket = "dbp-vid"
  cloudfront_signing_ssm_base = "/prod/biblebrain/cdn/signing_key-otc00l0j3b9ggbgc"
  ssm_biblebrain_dsn_name = "/prod/biblebrain/sql/dsn-otc00l0j3b9ggbgc"
  cloudfront_web_acl = "arn:aws:wafv2:us-east-1:596282610570:global/webacl/IP-restrict-downloader/5b0fa0ff-595f-4983-b5f2-7224c76afaf8"
  #export TF_VAR_ssm_biblebrain_dsn_value =  
}
