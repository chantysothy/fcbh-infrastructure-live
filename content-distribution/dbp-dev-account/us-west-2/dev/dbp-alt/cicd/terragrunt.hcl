# member-account: dbp

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "git::https://github.com/faithcomesbyhearing/fcbh-infrastructure-modules.git//cicd?ref=v0.1.6"
}

#Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependency "dbp-beanstalk" {
  config_path = "../beanstalk"
  mock_outputs = {
      elastic_beanstalk_application_name = "app"
      elastic_beanstalk_environment_name = "env"
  }  
}

# NOTE: The CodePipeline stage requires access to the GitHub repository containing the Beanstalk configuration. 
# In addition to the input variables listed below, an additional variable (github_oauth_token) must be provided. 
# This token must have permission to access the repository include in the inputs section
# Reference  https://docs.aws.amazon.com/codepipeline/latest/userguide/GitHub-create-personal-token-CLI.html for information on how to generate the access token
# Reference https://www.terraform.io/docs/configuration/variables.html for mechanisms for providing this value. 
# options: 
#   a) add -var="key=value" to the terraform command line
#   b) create an environment variable of the form TF_VAR_key (example: export TF_VAR_github_oauth_token=1111111111) prior to invoking terraform
inputs = {
  namespace               = "dbp"
  stage                   = "altdev"
  name                    = "cicd"
  application_description = "CICD resources for DBP Beanstalk"
  connection_name         = "dbp_cicd_alt"
  full_repository_id      = "faithcomesbyhearing/dbp"
  branch                             = "php81"
  force_destroy                      = true
  elastic_beanstalk_application_name = dependency.dbp-beanstalk.outputs.elastic_beanstalk_application_name
  elastic_beanstalk_environment_name = dependency.dbp-beanstalk.outputs.elastic_beanstalk_environment_name
}
