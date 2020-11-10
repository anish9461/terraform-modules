variable "service_name" {
    description = "The name for the microservice which will be used to refer in database cluster name"
}

variable "environment" {
    description = "The environment for this microservice"
}

variable "db_security_group_id" {
    description = "The Security group id for the database cluster"
}

variable "db_subnet_group_name" {
    description = "The Subnet group name for the database"
    default = "postgresql"
}

variable "db_master_username" {
    description = "The Master username for the database"
    default = "postgres"
}

variable "db_instance_class" {
    description = "The instance class for the database"
    default = "db.t3.medium"
}

variable "db_az" {
    description = "The availability zone for the database"
    default = "us-west-2a"
}

variable "secret_rotation_lambda_arn" {
    description = "The Lambda ARN for RDS database secrets rotation"
}

variable "secret_rotation_days" {
    description = "The Lambda secret rotation days"
    default = 30
}

variable "secret_name" {
    description = "The secret name for AWS secrets manager to store RDS credentials"
}

variable "ssm_vpc_id" {
    description = "The VPC id to be stored in Parameter store"
}

variable "ssm_subnet_id" {
    description = "The Subnet id to be stored in Parameter store"
}