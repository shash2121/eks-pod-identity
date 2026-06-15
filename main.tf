# Random Password Generators
resource "random_password" "jwt_secret" {
  length  = 64
  special = true
}

resource "random_password" "mysql_password" {
  length  = 32
  special = false
}

# Secrets Manager Module - Store RDS credentials
module "secrets_manager" {
  source                  = "./modules/secrets-manager"
  secret_name             = var.secret_name
  description             = var.secret_description
  secret_string = {
    JWT_SECRET    = random_password.jwt_secret.result
    DB_USERNAME   = var.mysql_username
    DB_PASSWORD   = random_password.mysql_password.result
  }
  recovery_window_in_days = var.recovery_window_in_days
  tags                    = var.tags
}

module "vpc" {
  source           = "./modules/vpc"
  vpc_cidr         = var.vpc_cidr
  environment_name = var.environment_name
  aws_region       = var.region
  tags             = var.tags
  subnet_newbits   = var.subnet_newbits
  cluster_name     = var.cluster_name
}

# EC2 Security Group Module
module "ec2_security_group" {
  source              = "./modules/security-group"
  security_group_name = "${var.environment_name}-ec2-sg"
  description         = "Security group for EC2 instance with SSH access"
  vpc_id              = module.vpc.vpc_id
  ingress_rules = {
    ssh = {
      description = "SSH access from anywhere"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
    }
  }
  tags = var.tags
}

module "ec2" {
  source                 = "./modules/ec2"
  ami_id                 = var.ami_id
  instance_type          = var.instance_type
  region                 = var.region
  subnet_id              = module.vpc.public_subnet_ids[0] # Using first public subnet
  vpc_security_group_ids = [module.ec2_security_group.security_group_id]
  key_name               = var.key_name
  user_data_script       = var.user_data_script
}

module "eks" {
  source                    = "./modules/eks"
  cluster_name              = var.cluster_name
  cluster_version           = var.cluster_version
  node_group_name           = var.node_group_name
  node_group_instance_types = var.node_group_instance_types
  node_group_desired_size   = var.node_group_desired_size
  node_group_min_size       = var.node_group_min_size
  node_group_max_size       = var.node_group_max_size
  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.public_subnet_ids
  tags                      = var.tags
  aws_region                = var.region

  # Pod Identity Policy
  db_secret_name = var.secret_name
  sqs_queue_name = var.sqs_queue_name
  db_identifier  = var.mysql_db_identifier

  # Metrics Server
  deploy_metrics_server = var.deploy_metrics_server

  # ArgoCD
  deploy_argocd = var.deploy_argocd
}

# MySQL RDS Module
module "mysql_rds" {
  source                  = "./modules/rds"
  db_identifier           = var.mysql_db_identifier
  allocated_storage       = var.mysql_allocated_storage
  storage_type            = var.storage_type
  engine                  = var.mysql_engine
  engine_version          = var.mysql_engine_version
  instance_class          = var.mysql_instance_class
  db_name                 = var.mysql_db_name
  username                = var.mysql_username
  password                = random_password.mysql_password.result
  port                    = var.mysql_port
  db_subnet_group_name    = module.vpc.db_subnet_group_name
  vpc_id                  = module.vpc.vpc_id
  skip_final_snapshot     = var.skip_final_snapshot
  publicly_accessible     = var.publicly_accessible
  backup_retention_period = var.backup_retention_period
  tags                    = var.tags
}

# SQS Module
module "sqs" {
  source      = "./modules/sqs"
  queue_name  = var.sqs_queue_name
  fifo_queue  = var.sqs_fifo_queue
  tags        = var.tags
}
