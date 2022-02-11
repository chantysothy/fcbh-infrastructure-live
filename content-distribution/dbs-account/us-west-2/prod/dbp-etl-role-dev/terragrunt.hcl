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
#   config_path = "../../../../dbp-dev-account/us-west-2/dev/dbp-etl"
# }

inputs = {
  environment = "dev"
  s3_buckets = [
    "dbp-etl-upload-dev-zrg0q2rhv7shv7hr", # dependency.dbp-etl.outputs.ui_upload_bucket,
    "dbp-etl-artifacts-dev", # dependency.dbp-etl.outputs.ui_artifacts_bucket,
    "dbp-staging",
    "dbp-vid-staging",
    "dbp-etl-mass-batch",
  ]
  elastictranscoder_arns = [
    "arn:aws:elastictranscoder:us-west-2:869054869504:pipeline/1538064910359-jfv2ws",
    "arn:aws:elastictranscoder:us-west-2:869054869504:job/*",
    "arn:aws:elastictranscoder:us-west-2:869054869504:preset/1556116949562-tml3vh",
    "arn:aws:elastictranscoder:us-west-2:869054869504:preset/1538163744878-tcmmai",
    "arn:aws:elastictranscoder:us-west-2:869054869504:preset/1538165037865-dri6c1",
    "arn:aws:elastictranscoder:us-west-2:869054869504:preset/1556118465775-ps3fba",
    "arn:aws:elastictranscoder:us-west-2:869054869504:preset/1351620000001-100070",
  ]
  lambda_function_arns = [
    "arn:aws:lambda:us-west-2:078432969830:function:transcoding-api-create-zip-w9gxhplj7q9mju3h"
  ]
}
