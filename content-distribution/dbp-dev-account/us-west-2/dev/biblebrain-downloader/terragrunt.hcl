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
  stage        = "dev"
  name         = "downloader"
  downloader_role_arn = "arn:aws:iam::078432969830:role/biblebrain-downloader-dev-hxul4ii4m7svimec"
  source_repository = "https://github.com/faithcomesbyhearing/biblebrain-downloader"
  source_repository_branch = "develop"
  s3_audio_source_bucket = "dbp-staging"
  s3_video_source_bucket = "dbp-vid-staging"
  cloudfront_signing_ssm_base = "/dev/biblebrain/cdn/signing_key-otc00l0j3b9ggbgc"
  ssm_biblebrain_dsn_name = "/dev/biblebrain/sql/dsn-otc00l0j3b9ggbgc"
  #export TF_VAR_ssm_biblebrain_dsn_value = 
}
