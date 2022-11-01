output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnets_ids" {
  description = "The private subnets IDs of the VPC"
  value       = module.vpc.private_subnets
}

output "public_subnets_ids" {
  description = "The public subnets IDs of the VPC"
  value       = module.vpc.public_subnets
}
