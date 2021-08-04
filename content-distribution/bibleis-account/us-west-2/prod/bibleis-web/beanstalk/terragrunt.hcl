# bibleis dbp-web

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "git::https://github.com/faithcomesbyhearing/fcbh-infrastructure-modules.git//elastic-beanstalk?ref=v0.1.6"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../../vpc"
}
dependency "bastion" {
  config_path = "../../bastion"
}
dependency "route53" {
  config_path = "../route53"
}
dependency "certificate" {
  config_path = "../../certificate"
}

inputs = {

  # administrative, to match cloudposse label
  namespace                          = "bibleis"
  name                               = "web"
  stage                              = ""

  application_description = "bible.is Web Elastic Beanstalk Application"
  vpc_id                     = dependency.vpc.outputs.vpc_id
  public_subnets             = dependency.vpc.outputs.public_subnet_ids
  private_subnets            = dependency.vpc.outputs.private_subnet_ids
  allowed_security_groups    = [dependency.bastion.outputs.security_group_id, dependency.vpc.outputs.vpc_default_security_group_id]
  additional_security_groups = [dependency.bastion.outputs.security_group_id]
  keypair                    = "bibleis-prod"

  description = "Bibleis Web"
  # certs aren't yet validated
  #dns_zone_id                  = dependency.route53.outputs.zone_id
  #loadbalancer_certificate_arn = dependency.certificate.outputs.arn

  instance_type     = "t3.small"


  environment_description = "bible.is Web Production environment"
  version_label           = ""
  force_destroy           = true
  root_volume_size        = 8
  root_volume_type        = "gp2"

  rolling_update_enabled  = true
  rolling_update_type     = "Health"
  updating_min_in_service = 0
  updating_max_batch      = 1
  preferred_start_time    = "Sun:18:00"

  healthcheck_url  = "/status"
  application_port = 80

  solution_stack_name = "64bit Amazon Linux 2018.03 v4.17.6 running Node.js"
  enable_stream_logs  = true

 
  env_vars = {
    "BEANSTALK_BUCKET"   = "elasticbeanstalk-us-west-2-529323115138"
    "S3_CONFIG_LOC"      = "https://s3-us-west-2.amazonaws.com/elasticbeanstalk-us-west-2-529323115138/bibleis-web"
    "BASE_API_ROUTE" = "https://4.dbt.io/api"
    "NODE_ENV" = "production"
    "NPM_USE_PRODUCTION" = "1"
    "npm_config_unsafe_perm" = "1"
  }
  additional_settings = [
    # {
    #   name      = "AppSource"
    #   namespace = "aws:cloudformation:template:parameter"
    #   value     = "s3://elasticbeanstalk-us-west-2-529323115138/bibleis-web/bibleis-web-newdata.zip"
    # }
  ]
  # TODO: put this in package.json for the start command
  # {
  #   name      = "NodeCommand"
  #   namespace = "aws:elasticbeanstalk:container:nodejs"
  #   value     = "./node_modules/.bin/cross-env NODE_ENV=production node nextServer"
  # },

}