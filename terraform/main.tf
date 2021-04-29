###########################
# AWS Profile configuration
###########################
provider "aws" {
  profile = "development"
  region  = "us-east-1"
}

###################################################
# Bucket configuration for holding the remote state
###################################################
terraform {
  backend "s3" {
    bucket  = "s3-development-tf"
    key     = "Devops.Challenge/terraform.tfstate"
    region  = "us-east-1"
    profile = "development"
    encrypt = true
  }
}

##################
# Local variables 
##################
locals {
  project_name     = "devops-challenge"
  environment      = "development"
  region           = "us-east-1"
  certificate_arn  = "arn:aws:acm:us-east-1:xxxx:certificate/xxxx"
  domains          = ["devops.evacenter.com"]
}

#############
# VPC Module
#############
module "vpc" {

  source = "modules/vpc/"

  name =  local.project_name

  cidr = "10.70.0.0/16"

  azs                 = ["us-east-1b", "us-east-1c"]
  private_subnets     = ["10.70.1.0/24","10.70.3.0/24"]
  public_subnets      = ["10.70.2.0/24","10.70.4.0/24"]
  database_subnets    = ["10.70.5.0/24", "10.70.6.0/24"]

  create_database_subnet_group = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_classiclink             = false
  enable_classiclink_dns_support = false

  enable_nat_gateway = true
  single_nat_gateway = true

}

#############
# ECS Module
#############
module "ecs-cluster" {
  source = "modules/ecs-cluster/"
  ecs_cluster_name_list = ["ecs-development"]
  environment = local.environment
}

#########################################
# IAM role for task execution role
#########################################
module "role_task_execution" {
    source = "modules/iam/iam-assumable-role"

    create_role = true

    role_name         = "ecsTaskExecutionRole"
    role_requires_mfa = false

    trusted_role_services = [
       "ecs-tasks.amazonaws.com"
     ]

    custom_role_policy_arns = [
      "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
      "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser",
    ]
}

#############
# ECR Module
#############
module "ecr" {
  source = "modules/ecr"

  name = local.project_name
}

############################
# IAM role for auto scaling
############################
module "role_autoscale" {
  source = "modules/iam/iam-assumable-role"

  create_role = true

  role_name         = "ecs${local.project_name}AutoscaleRole"
  role_requires_mfa = false

  trusted_role_services = [
    "application-autoscaling.amazonaws.com"
  ]

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole",
  ]
}

#################################
# IAM role for task service role
#################################
module "role_task_service" {
  source = "modules/iam/iam-assumable-role"

  create_role = true

  role_name         = "rl-${local.project_name}"
  role_requires_mfa = false

  trusted_role_services = [
    "ecs-tasks.amazonaws.com"
  ]

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
  ]
}

####################################
# Security Group for the public ALB
####################################

module "sg_elb" {
  source = "modules/security-group"

  name        = "sg_prod_pub_elb_${local.project_name}"
  description = "SG for the public ALB"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "all-all"
      source_security_group_id = module.sg_elb.this_security_group_id
      description              = "Same SG"
    },
  ]
  ingress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
      description = "Internet"
    },
  ]

  egress_with_source_security_group_id = [
    {
      from_port                = 3000
      to_port                  = 3000
      protocol                 = "tcp"
      source_security_group_id = module.sg_service.this_security_group_id
      description              = "Traffic to the microservice"
    },
    {
      rule                     = "all-all"
      source_security_group_id = module.sg_elb.this_security_group_id
      description              = "Same SG"
    },
  ]
}

######################################
# Security Group for the Microservice
######################################

module "sg_service" {
  source = "modules/security-group"

  name        = "sg_prod_priv_presl_${local.project_name}"
  description = "SG for Microservice layer"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = 3000
      to_port                  = 3000
      protocol                 = "tcp"
      source_security_group_id = module.sg_elb.this_security_group_id
      description              = "Traffic from the ALB"
    },
    {
      rule                     = "all-all"
      source_security_group_id = module.sg_service.this_security_group_id
      description              = "Same SG"
    },
  ]

  egress_with_source_security_group_id = [
    {
      rule                     = "all-all"
      source_security_group_id = module.sg_service.this_security_group_id
      description              = "Same SG"
    },
  ]
  egress_with_cidr_blocks = [
    {
      rule        = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "Internet"
    },
    {
      rule        = "http-80-tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "Internet"
    },
  ]
}

######
# ALB
######
module "elb" {
  source              = "modules/elb"
  name                = "pub-${local.project_name}"
  enable_metrics      = true
  vpc_id              = module.vpc.vpc_id
  subnet_pub_list     = module.vpc.public_subnets
  security_group      = module.sg_elb.this_security_group_id
  internal            = false
  health_check_path   = "/ping"
  healthy_threshold   = 10
  unhealthy_threshold = 10
  kind_implementation = 1 #internet facing alb
  timeout                    = 10
  interval                   = 60
  enable_logs                = true
  enable_deletion_protection = true
  environment                = local.environment
}

#############
# ECS Service
#############
module "ecs-service" {
  source                            = "modules/ecs-service"
  name                              = local.project_name
  task_role_arn                     = module.role_task_service.this_iam_role_arn
  ecs_task_execution_role           = module.role_task_execution.this_iam_role_arn
  app_image                         = "${module.ecr.ecr_uri}:latest"
  fargate_cpu                       = 1024
  fargate_memory                    = 2048
  app_port                          = 8080
  app_count                         = 2
  aws_ecs_cluster_id                = tostring(module.ecs-cluster.ecs_cluster_id_list[0])
  aws_ecs_cluster_name              = tostring(module.ecs-cluster.aws_ecs_cluster_name[0])
  sg_task_id                        = module.sg_service.this_security_group_id
  target_group_arn                  = module.elb.aws_alb_target_group_id
  aws_lb_listener_http              = module.elb.aws_lb_listener_http
  aws_region                        = local.region
  health_check_path                 = "/ping"
  health_check_grace_period_seconds = 120
  subnet_priv                       = module.vpc.private_subnets
  ecs_autoscale_role                = module.role_autoscale.this_iam_role_arn
  enable_elb                        = true #flag to enble elb for ecs service

  environment = local.environment
  secret_id   = "${local.project_name}/${local.environment}"

  memory_autoscale_comparison_operator = "GreaterThanOrEqualToThreshold"
  memory_evaluation_periods            = 2
  memory_autoscale_metric_name         = "MemoryUtilization"
  memory_autoscale_namespace           = "AWS/ECS"
  memory_autoscale_period_time         = 60
  memory_autoscale_threshold           = 60

  cpu_autoscale_comparison_operator = "GreaterThanOrEqualToThreshold"
  cpu_evaluation_periods            = 2
  cpu_autoscale_metric_name         = "CPUUtilization"
  cpu_autoscale_namespace           = "AWS/ECS"
  cpu_autoscale_period_time         = 60
  cpu_autoscale_threshold           = 75
}

############
# Cloudfront
############
module "cloudfront" {
  source          = "modules/cloudfront"
  name            = "cf-${local.project_name}"
  origin          = module.elb.aws_alb_dns_name
  origin_id       = split(".", module.elb.aws_alb_dns_name)[0]
  domains         = local.domains
  certificate_arn = local.certificate_arn

  comment = "Managed by Terraform"

  allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]

  cache_headers   = ["*"]
  forward_cookies = "all"

  tags = {
    "Environment" = local.environment
  }
}