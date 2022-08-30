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
  downloader_role_arn = "arn:aws:iam::596282610570:role/biblebrain-downloader-prod-o6wuebweiwbb21mb"
  source_repository = "https://github.com/faithcomesbyhearing/biblebrain-downloader"
  source_repository_branch = "main"
  s3_audio_source_bucket = "dbp-prod"
  s3_video_source_bucket = "dbp-vid"
  # s3_downloader_bucket  = "biblebrain-downloader-content"
  cdn_signing_key_secret_id = "/prod/biblebrain/cdn/signing_key-13soz5r4mytkk"
}
