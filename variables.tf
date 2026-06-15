variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "environment_name" {
  description = "Name of the environment"
  type        = string
}

variable "subnet_newbits" {
  description = "Number of bits to add for subnetting"
  type        = number
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "Instance type for EC2 instances"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "key_name" {
  description = "Key pair name for EC2 instances"
  type        = string
}

variable "user_data_script" {
  description = "User data script for EC2 instances"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Version of the EKS cluster"
  type        = string
}

variable "node_group_name" {
  description = "Name of the EKS node group"
  type        = string
}

variable "node_group_instance_types" {
  description = "Instance types for EKS node group"
  type        = list(string)
}

variable "node_group_desired_size" {
  description = "Desired size of the EKS node group"
  type        = number
}

variable "node_group_min_size" {
  description = "Minimum size of the EKS node group"
  type        = number
}

variable "node_group_max_size" {
  description = "Maximum size of the EKS node group"
  type        = number
}

variable "allocated_storage" {
  description = "Allocated storage in GB for RDS instance"
  type        = number
}

variable "storage_type" {
  description = "Storage type for RDS instance"
  type        = string
}

# Secrets Manager Variables
variable "secret_name" {
  description = "Name of the secret in Secrets Manager"
  type        = string
}

variable "secret_description" {
  description = "Description of the secret"
  type        = string
  default     = "Managed by Terraform"
}

variable "recovery_window_in_days" {
  description = "Number of days to retain the secret before deletion (0-30)"
  type        = number
  default     = 30
}

variable "skip_final_snapshot" {
  description = "Whether to skip final snapshot when deleting RDS instance"
  type        = bool
}

variable "publicly_accessible" {
  description = "Whether RDS instance is publicly accessible"
  type        = bool
}

variable "backup_retention_period" {
  description = "Backup retention period for RDS instance"
  type        = number
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

variable "deploy_metrics_server" {
  description = "Whether to deploy metrics-server"
  type        = bool
  default     = true
}

# MySQL RDS Variables
variable "mysql_db_identifier" {
  description = "Identifier for the MySQL RDS instance"
  type        = string
  default     = "dev-mysql-db"
}

variable "mysql_allocated_storage" {
  description = "Allocated storage in GB for MySQL"
  type        = number
  default     = 20
}

variable "mysql_engine" {
  description = "Engine for MySQL RDS"
  type        = string
  default     = "mysql"
}

variable "mysql_engine_version" {
  description = "Engine version for MySQL"
  type        = string
  default     = "8.0"
}

variable "mysql_instance_class" {
  description = "Instance class for MySQL"
  type        = string
  default     = "db.t3.micro"
}

variable "mysql_db_name" {
  description = "Database name for MySQL"
  type        = string
  default     = "urlshortener"
}

variable "mysql_username" {
  description = "Username for MySQL"
  type        = string
  default     = "root"
}

variable "mysql_port" {
  description = "Port for MySQL"
  type        = number
  default     = 3306
}

# SQS Variables
variable "sqs_queue_name" {
  description = "Name of the SQS queue"
  type        = string
  default     = "dev-queue"
}

variable "sqs_fifo_queue" {
  description = "Whether to create a FIFO queue"
  type        = bool
  default     = false
}

# ArgoCD Variables
variable "deploy_argocd" {
  description = "Whether to deploy ArgoCD on the EKS cluster"
  type        = bool
  default     = false
}
