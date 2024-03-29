# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY A COUCHBASE CLUSTER IN AWS
# This is an example of how to deploy Couchbase in AWS with all of the Couchbase services and Sync Gateway in a single
# cluster. The cluster runs on top of an Auto Scaling Group (ASG), with EBS Volumes attached, and a load balancer
# used for health checks and to distribute traffic across Sync Gateway.
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  # This module is now only being tested with Terraform 0.15.x. However, to make upgrading easier, we are setting
  # 0.12.26 as the minimum version, as that version added support for required_providers with source URLs, making it
  # forwards compatible with 0.15.x code.
  required_version = ">= 0.12.26"
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE COUCHBASE CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

module "couchbase" {
  # When using these modules in your own code, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "git::git@github.com:gruntwork-io/terraform-aws-couchbase.git//modules/couchbase-cluster?ref=v0.0.1"
  source = "/Users/bradflood/git/terraform-aws-couchbase/modules/couchbase-cluster"

  cluster_name  = var.cluster_name
  min_size      = 2
  max_size      = 3
  instance_type = "t4g.medium"

  ami_id = var.ami_id
  user_data = data.template_file.user_data_server.rendered

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  # We recommend using two EBS Volumes with your Couchbase servers: one for the data directory and one for the index
  # directory.
  ebs_block_devices = [
    {
      device_name = var.data_volume_device_name
      volume_type = "gp2"
      volume_size = 50
      encrypted   = true
    },
    {
      device_name = var.index_volume_device_name
      volume_type = "gp2"
      volume_size = 50
      encrypted   = true
    },
  ]

  # allow ssh from obt-dev bastion. FIXME: externalize this if we move out of obt-dev
  allowed_ssh_cidr_blocks = ["172.10.0.0/16"]

  ssh_key_name = var.ssh_key_name

  # To make it easy to test this example from your computer, we allow the Couchbase servers to have public IPs. In a
  # production deployment, you'll probably want to keep all the servers in private subnets with only private IPs.
  associate_public_ip_address = true

  # We are using a load balancer for health checks so if a Couchbase node stops responding, it will automatically be
  # replaced with a new one.
  health_check_type = "ELB"

  # An example of custom tags
  tags = [
    {
      key                 = "Environment"
      value               = "development"
      propagate_at_launch = true
    },
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# THE USER DATA SCRIPT THAT WILL RUN ON EACH EC2 INSTANCE WHEN IT'S BOOTING
# This script will configure and start Couchbase and Sync Gateway
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "user_data_server" {
  template = file("/Users/bradflood/git/terraform-aws-couchbase/examples/couchbase-cluster-simple/user-data/user-data.sh")

  vars = {
    cluster_asg_name = var.cluster_name
    cluster_port     = module.couchbase_security_group_rules.rest_port

    # We expose the Sync Gateway on all IPs but the Sync Gateway Admin should ONLY be accessible from localhost, as it
    # provides admin access to ALL Sync Gateway data.
    sync_gateway_interface       = ":${module.sync_gateway_security_group_rules.interface_port}"
    sync_gateway_admin_interface = "127.0.0.1:${module.sync_gateway_security_group_rules.admin_interface_port}"

    # Pass in the data about the EBS volumes so they can be mounted
    data_volume_device_name  = var.data_volume_device_name
    data_volume_mount_point  = var.data_volume_mount_point
    index_volume_device_name = var.index_volume_device_name
    index_volume_mount_point = var.index_volume_mount_point
    volume_owner             = var.volume_owner
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY A LOAD BALANCER FOR COUCHBASE
# We use this load balancer to (1) perform health checks and (2) route traffic to the Couchbase Web Console. Note that
# we do NOT route any traffic to other Couchbase APIs/ports: https://blog.couchbase.com/couchbase-101-q-and-a/
# ---------------------------------------------------------------------------------------------------------------------

module "load_balancer" {
  # When using these modules in your own code, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "git::git@github.com:gruntwork-io/terraform-aws-couchbase.git//modules/load-balancer?ref=v0.0.1"
  source = "/Users/bradflood/git/terraform-aws-couchbase/modules/load-balancer"

  name       = var.cluster_name
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  http_listener_ports            = [var.couchbase_load_balancer_port, var.sync_gateway_load_balancer_port]
  https_listener_ports_and_certs = []

  # To make testing easier, we allow inbound connections from any IP. In production usage, you may want to only allow
  # connectsion from certain trusted servers, or even use an internal load balancer, so it's only accessible from
  # within the VPC

  allow_inbound_from_cidr_blocks = ["0.0.0.0/0"]
  internal                       = false

  # Since Sync Gateway and Couchbase Lite can have long running connections for changes feeds, we recommend setting the
  # idle timeout to the maximum value of 3,600 seconds (1 hour)
  # https://developer.couchbase.com/documentation/mobile/1.5/guides/sync-gateway/nginx/index.html#aws-elastic-load-balancer-elb
  idle_timeout = 3600
  tags = {
    Name = var.cluster_name
  }
}

module "couchbase_target_group" {
  # When using these modules in your own code, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "git::git@github.com:gruntwork-io/terraform-aws-couchbase.git//modules/load-balancer-target-group?ref=v0.0.1"
  source = "/Users/bradflood/git/terraform-aws-couchbase/modules/load-balancer-target-group"

  target_group_name = "${var.cluster_name}-cb"
  asg_name          = module.couchbase.asg_name
  port              = module.couchbase_security_group_rules.rest_port
  health_check_path = "/ui/index.html"
  vpc_id            = var.vpc_id

  listener_arns                   = [module.load_balancer.http_listener_arns[var.couchbase_load_balancer_port]]
  num_listener_arns               = 1
  listener_rule_starting_priority = 100

  # The Couchbase Web Console uses web sockets, so it's best to enable stickiness so each user is routed to the same
  # server
  enable_stickiness = true
}

module "sync_gateway_target_group" {
  # When using these modules in your own code, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "git::git@github.com:gruntwork-io/terraform-aws-couchbase.git//modules/load-balancer-target-group?ref=v0.0.1"
  source = "/Users/bradflood/git/terraform-aws-couchbase/modules/load-balancer-target-group"

  target_group_name = "${var.cluster_name}-sg"
  asg_name          = module.couchbase.asg_name
  port              = module.sync_gateway_security_group_rules.interface_port
  health_check_path = "/"
  vpc_id            = var.vpc_id

  listener_arns                   = [module.load_balancer.http_listener_arns[var.sync_gateway_load_balancer_port]]
  num_listener_arns               = 1
  listener_rule_starting_priority = 100
}

# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE THE SECURITY GROUP RULES FOR COUCHBASE AND SYNC GATEWAY
# This controls which ports are exposed and who can connect to them
# ---------------------------------------------------------------------------------------------------------------------

module "couchbase_security_group_rules" {
  # When using these modules in your own code, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "git::git@github.com:gruntwork-io/terraform-aws-couchbase.git//modules/couchbase-server-security-group-rules?ref=v0.0.1"
  source = "/Users/bradflood/git/terraform-aws-couchbase/modules/couchbase-server-security-group-rules"

  security_group_id = module.couchbase.security_group_id

  # To keep this example simple, we allow these client-facing ports to be accessed from any IP. In a production
  # deployment, you may want to lock these down just to trusted servers.

  rest_port_cidr_blocks      = ["0.0.0.0/0"]
  capi_port_cidr_blocks      = ["0.0.0.0/0"]
  query_port_cidr_blocks     = ["0.0.0.0/0"]
  fts_port_cidr_blocks       = ["0.0.0.0/0"]
  memcached_port_cidr_blocks = ["0.0.0.0/0"]
  moxi_port_cidr_blocks      = ["0.0.0.0/0"]
}

module "sync_gateway_security_group_rules" {
  # When using these modules in your own code, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "git::git@github.com:gruntwork-io/terraform-aws-couchbase.git//modules/sync-gateway-security-group-rules?ref=v0.0.1"
  source = "/Users/bradflood/git/terraform-aws-couchbase/modules/sync-gateway-security-group-rules"

  security_group_id = module.couchbase.security_group_id

  # To keep this example simple, we allow these interface port to be accessed from any IP. In a production
  # deployment, you may want to lock this down just to trusted servers.
  interface_port_cidr_blocks = ["0.0.0.0/0"]
}

# ---------------------------------------------------------------------------------------------------------------------
# ATTACH IAM POLICIES TO THE CLUSTER
# These policies allow the cluster to automatically bootstrap itself
# ---------------------------------------------------------------------------------------------------------------------

module "iam_policies" {
  # When using these modules in your own code, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "git::git@github.com:gruntwork-io/terraform-aws-couchbase.git//modules/couchbase-server-security-group-rules?ref=v0.0.1"
  source = "/Users/bradflood/git/terraform-aws-couchbase/modules/couchbase-iam-policies"

  iam_role_id = module.couchbase.iam_role_id
}
