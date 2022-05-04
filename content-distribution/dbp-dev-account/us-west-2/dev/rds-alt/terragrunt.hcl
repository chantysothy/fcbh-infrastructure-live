# member-account: dbp-dev

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "git::https://github.com/faithcomesbyhearing/fcbh-infrastructure-modules.git//data-storage/rds?ref=v0.1.6"

}

#Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id                        = "temporary-dummy-id"
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
#
# aws_region: region in which organization resources will be created
# 
# aws_profile: refers to a named profile (https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html) 
# with sufficient permissions to create resources in the master account. 
#
#Before executing, create a snapshot in DBS and move it to DBP. Name the snapshot "pre-terraform-snapshot"
# to copy an RDS snapshot between accounts: https://aws.amazon.com/premiumsupport/knowledge-center/rds-snapshots-share-account/
#
# Note: db.r3.large or greater is needed to support Performance Insights
# aurora mysql engine versions: https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraMySQL.Updates.11Updates.html
#
# security group "sg-0a5c623a606883f6a" is the beanstalk security group. It is not created at the point when RDS is created, so is added after the fact
inputs = {
  namespace                  = "biblebrain"
  stage                      = "contentdev"
  name                       = "rds"
  vpc_id                     = dependency.vpc.outputs.vpc_id
  subnets                    = dependency.vpc.outputs.private_subnet_ids
  security_groups            = [dependency.vpc.outputs.vpc_default_security_group_id, dependency.bastion.outputs.security_group_id, "sg-0a5c623a606883f6a"]
  allowed_cidr_blocks        = ["172.20.0.0/16"]
  instance_type              = "db.t3.medium"
  engine_version             = "8.0.mysql_aurora.3.02.0"
  cluster_size               = 1
  cluster_family             = "aurora-mysql8.0"
  db_name                    = "dbp_dev"
  snapshot_identifier        = "pre-upgrade-to-v3"
  performance_insights_enabled = false  
  autoscaling_enabled        = true
  autoscaling_target_metrics = "RDSReaderAverageCPUUtilization"
  autoscaling_target_value   = 55 
}
