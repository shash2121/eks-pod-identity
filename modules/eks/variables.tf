variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "my-eks-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.28"
}

variable "cluster_endpoint_private_access" {
  description = "Whether the Amazon EKS private API server endpoint is enabled"
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access" {
  description = "Whether the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "node_group_name" {
  description = "Name of the node group"
  type        = string
  default     = "node-group"
}

variable "node_group_instance_types" {
  description = "List of instance types for the node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_group_desired_size" {
  description = "Desired number of nodes in the node group"
  type        = number
  default     = 2
}

variable "node_group_min_size" {
  description = "Minimum number of nodes in the node group"
  type        = number
  default     = 1
}

variable "node_group_max_size" {
  description = "Maximum number of nodes in the node group"
  type        = number
  default     = 3
}

variable "vpc_id" {
  description = "VPC ID where the EKS cluster will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where the EKS cluster will be deployed"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Terraform = "true"
  }
}

# Ingress Controller Variables
variable "deploy_ingress_controller" {
  description = "Whether to deploy NGINX Ingress Controller"
  type        = bool
  default     = false
}

# Metrics Server Variables
variable "deploy_metrics_server" {
  description = "Whether to deploy metrics-server"
  type        = bool
  default     = true
}

variable "aws_region" {
  description = "AWS region where the EKS cluster is deployed"
  type        = string
}

# Pod Identity Policy Variables
variable "db_secret_name" {
  description = "Name of the Secrets Manager secret for DB credentials"
  type        = string
  default     = "dev-rds-credentials"
}

variable "sqs_queue_name" {
  description = "Name of the SQS queue for visit events"
  type        = string
  default     = "dev-orders-queue"
}

variable "db_identifier" {
  description = "Identifier of the RDS database instance"
  type        = string
  default     = "dev-mysql-db"
}

# ArgoCD Variables
variable "deploy_argocd" {
  description = "Whether to deploy ArgoCD on the EKS cluster"
  type        = bool
  default     = false
}
