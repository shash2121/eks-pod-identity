# EKS Pod Identity Infrastructure

Terraform infrastructure for deploying a URL Shortener (LinkShrink) application on AWS EKS with Pod Identity.

## Architecture

- **VPC** with public/private subnets, NAT Gateway, Internet Gateway
- **EKS** cluster with managed node groups and EKS Pod Identity Agent
- **RDS** (MySQL + PostgreSQL) for application data
- **ElastiCache Redis** for caching
- **SQS** for visit event processing
- **Secrets Manager** for credential storage
- **EC2** bastion host with Docker
- **AWS Load Balancer Controller** with Pod Identity
- **ArgoCD** for GitOps deployment

## Prerequisites

- Terraform >= 1.0.0
- AWS CLI configured with appropriate credentials
- `terraform.tfvars` configured with your environment values

## Required Variables

The following variables must be provided in `terraform.tfvars` or via CLI:

- `vpc_cidr`
- `environment_name`
- `region`
- `cluster_name`
- `db_password` (sensitive)
- `postgres_password` (sensitive)
- `secret_string` (sensitive)

## Deployment

```bash
terraform init
terraform plan
terraform apply
```

## File Structure

```
.
├── terraform.tf          # Terraform version and required providers
├── providers.tf          # Provider configurations
├── backend.tf            # Remote state backend (S3)
├── variables.tf          # Input variable definitions
├── terraform.tfvars      # Concrete variable values
├── locals.tf             # Local computed values
├── main.tf               # Module composition
├── outputs.tf            # Output definitions
├── modules/
│   ├── vpc/              # Networking
│   ├── ec2/              # Bastion host
│   ├── eks/              # EKS cluster + addons
│   ├── rds/              # MySQL/PostgreSQL
│   ├── redis/            # ElastiCache
│   ├── sqs/              # Message queue
│   ├── secrets-manager/  # AWS Secrets Manager
│   ├── security-group/   # Reusable SG module
│   └── aws-policies/     # IAM policy documents
└── url-shortener-k8s/    # Kubernetes manifests
```

## Security Notes

- Database passwords are marked as `sensitive` and have no defaults.
- Secrets are stored in AWS Secrets Manager and synced to Kubernetes via CSI driver.
- Pod Identity is used instead of IRSA for IAM role association.