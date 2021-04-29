###################################
# Outputs for remote state reusage
###################################

# VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

# Subnets
output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "database_subnets" {
  description = "List of IDs of database subnets"
  value       = module.vpc.database_subnets
}

output "intra_subnets" {
  description = "List of IDs of intra subnets"
  value       = module.vpc.intra_subnets
}

# NAT gateways
output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.vpc.nat_public_ips
}

output "vpc_cidr_block" {
  description = "ARN block VPC"
  value       = module.vpc.vpc_cidr_block
}

output "ecs_cluster_id_list" {
  description = "The ECS list"
  value       = module.ecs-cluster.ecs_cluster_id_list
}

output "ecs_cluster_name_list" {
  description = "The ECS list of names"
  value       = module.ecs-cluster.aws_ecs_cluster_name
}

output "role_task_execution_arn" {
  description = "The ARN of IAM policy "
  value       = module.role_task_execution.this_iam_role_arn
}

output "ecr_arn" {
  description = "The ARN of ECR "
  value       = module.ecr.ecr_arn
}

output "role_task_service_arn" {
  description = "The ARN of IAM policy "
  value       = module.role_task_service.this_iam_role_arn
}

output "ecs_autoscale_role" {
  description = "The ARN of autoscale "
  value       = module.role_autoscale.this_iam_role_arn
}

output "sg_elb_id" {
  description = "The ID of SG elb layer"
  value       = module.sg_elb.this_security_group_id
}

output "sg_service_id" {
  description = "The ID of SG service layer"
  value       = module.sg_service.this_security_group_id
}

output "tg_main_id" {
  description = "The ID of target group "
  value       = module.elb.aws_alb_target_group_id
}

output "alb_dns_name" {
  description = "The DNS name of the ELB"
  value       = module.elb.aws_alb_dns_name
}