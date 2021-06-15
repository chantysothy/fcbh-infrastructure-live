# member-account: dbp-dev

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "git::https://github.com/faithcomesbyhearing/fcbh-infrastructure-modules.git//elastic-beanstalk?ref=v0.1.6"
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
dependency "bastion" {
  config_path = "../bastion"
  mock_outputs = {
    security_group_id = ""
  }
}
# dependency "rds" {
#   config_path = "../../rds"
#   mock_outputs = {
#     endpoint        = ""
#     reader_endpoint = ""
#   }
# }
# dependency "elasticache" {
#   config_path = "../../elasticache"
#   mock_outputs = {
#     cluster_address = ""
#   }
# }
# dependency "route53" {
#   config_path = "../../route53"
#   mock_outputs = {
#     zone_id = ""
#   }
# }
# dependency "certificate" {
#   config_path = "../../certificate/dev.dbt.io"
#   mock_outputs = {
#     arn = ""
#   }
# }

inputs = {
  namespace = "dbp-web"
  stage     = "dev"
  name      = "newdata"

  application_description      = "dbp web"
  vpc_id                       = dependency.vpc.outputs.vpc_id
  public_subnets               = dependency.vpc.outputs.public_subnet_ids
  private_subnets              = dependency.vpc.outputs.private_subnet_ids
  allowed_security_groups      = [dependency.bastion.outputs.security_group_id, dependency.vpc.outputs.vpc_default_security_group_id]
  additional_security_groups   = [dependency.bastion.outputs.security_group_id, dependency.vpc.outputs.vpc_default_security_group_id]
  keypair                      = "dbp-dev"
  description                  = "DBP Web Elastic Beanstalk"
  autoscale_min                = 1
  # dns_zone_id                  = dependency.route53.outputs.zone_id
  # loadbalancer_certificate_arn = dependency.certificate.outputs.arn
  instance_type                = "t3.small"

  environment_description = "DBP Web for Newdata"
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

  solution_stack_name = "64bit Amazon Linux 2018.03 v4.17.5 running Node.js"
  enable_stream_logs  = true

  // https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-general.html

  env_vars = {
    "BEANSTALK_BUCKET"   = "elasticbeanstalk-us-west-2-078432969830"
    "S3_CONFIG_LOC"      = "https://s3-us-west-2.amazonaws.com/elasticbeanstalk-us-west-2-078432969830/dbp-web-newdata"
    "BASE_API_ROUTE" = "https://dev.dbt.io/api"
    "NODE_ENV" = "development"
    "NPM_USE_PRODUCTION" = "0"
    "npm_config_unsafe_perm" = "1"
  }
}
