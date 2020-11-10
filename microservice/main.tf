//RDS setup

locals {
  engine        = "aurora-postgresql"
  version       = "11.7"
  service_name  = var.service_name
  environment   = var.environment
}

// Generate Random Password
resource "random_password" "dbPassword" {
  length = 21
  special = true
  override_special = "_%@"
}



// Create RDS Instance 
  ### Primary
resource "aws_rds_cluster" "primary-cluster" {
  cluster_identifier = "${local.service_name}-01"
  master_password                     = random_password.dbPassword.result
  master_username                     = var.db_master_username
  engine                              = local.engine
  engine_version                      = local.version
  vpc_security_group_ids              = [tostring(var.db_security_group_id)] 
  storage_encrypted                   = "true"
  db_cluster_parameter_group_name     = "default.aurora-postgresql11"
  db_subnet_group_name                = var.db_subnet_group_name #aws_db_subnet_group.psql-primary-subnet-group.name
  deletion_protection                 = "true"
  backup_retention_period             = 7
  skip_final_snapshot                 = "true"
  iam_database_authentication_enabled = "true"
}

resource "aws_rds_cluster_instance" "primary" {
  identifier           = "${aws_rds_cluster.primary-cluster.cluster_identifier}-instance-01"
  cluster_identifier   = aws_rds_cluster.primary-cluster.id
  engine               = local.engine
  engine_version       = local.version
  instance_class       = var.db_instance_class
  db_subnet_group_name = var.db_subnet_group_name #aws_db_subnet_group.psql-primary-subnet-group.name
  availability_zone    = var.db_az
  promotion_tier       = 1
}


//Secrets Manager to store database credentials
resource "aws_secretsmanager_secret" "databasePW" {
  name = var.secret_name
  description = "Database credentials for search service"
}

resource "aws_secretsmanager_secret_version" "databaseSSNversion" {
  secret_id     = aws_secretsmanager_secret.databasePW.id
  secret_string = <<EOF
  {
    "username": "${aws_rds_cluster.primary-cluster.master_username}",
    "password": "${aws_rds_cluster.primary-cluster.master_password}",
    "engine": "postgres",
    "host": "${aws_rds_cluster.primary-cluster.endpoint}",
    "port": "5432",
    "dbClusterIdentifier": "${aws_rds_cluster.primary-cluster.cluster_identifier}"
  }
  EOF
}


resource "aws_secretsmanager_secret_rotation" "rotate_secret" {
  secret_id           = aws_secretsmanager_secret.databasePW.id
  rotation_lambda_arn = var.secret_rotation_lambda_arn

  rotation_rules {
    automatically_after_days = var.secret_rotation_days
  }
}


//SSM storage
resource "aws_ssm_parameter" "vpc_ssm" {
  name  = "vpc_id"
  type  = "String"
  value = var.ssm_vpc_id
}

resource "aws_ssm_parameter" "private_subnet_ssm" {
  name = "subnet_id"
  type = "String"
  value = var.ssm_subnet_id
}

