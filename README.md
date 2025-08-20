# terraform-aws-deployment


# Terraform AWS Deployment

## Overview

This repository contains infrastructure-as-code (IaC) for deploying AWS resources using **Terraform modules**. The project follows a **modular design** with separate repositories for reusable modules and deployment configuration, supporting multiple environments (dev and prod). GitHub Actions is used for **automated deployment** with OIDC authentication.

The deployment includes:

- VPC with public and private subnets
- EC2 instances in public subnets
- RDS MySQL database in private subnets
- Application Load Balancer (ALB)
- Security groups with least privilege
- S3 backend for Terraform state management

---

## Repository Structure

```text
terraform-aws-deployment/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   └── outputs.tf
│   └── prod/
│       ├── main.tf
│       ├── variables.tf
│       ├── terraform.tfvars
│       └── outputs.tf
├── .github/
│   └── workflows/
│       └── deploy_infra.yml
├── README.md
└── .terraform-version
environments/: Contains environment-specific Terraform configuration (dev and prod).

.github/workflows/: Contains GitHub Actions workflow for deployment.

.terraform-version: Specifies the Terraform version used.

Prerequisites
Before running Terraform, ensure you have:

An AWS account with necessary IAM permissions.

Terraform >= 1.12.2 installed.

GitHub repository secrets configured:

AWS_ACCOUNT: Your AWS account ID

DB_PASSWORD: RDS database password

ADMIN_CIDR: Your administrative IP for SSH/HTTPS access

OIDC trust relationship set up between GitHub Actions and AWS IAM role.

Terraform Modules
This project uses reusable modules stored in a separate repository:

Module	Description
vpc	Creates VPC, public/private subnets, Internet Gateway, NAT Gateway, route tables, and associations.
ec2	Launches EC2 instances with configurable instance type, security groups, user data, and public IP assignment.
security_grps	Creates security groups for application, database, and ALB with least privilege ingress/egress rules.

Modules are referenced using Git source with version tags:


module "vpc" {
  source = "git::https://github.com/nanafilbert/terraform_aws_modules_repo.git//modules/vpc?ref=v1.1.0"
  ...
}
Deployment
GitHub Actions Workflow
The workflow supports manual triggering and automated runs on push to main. You can select Terraform actions (apply or destroy) via the workflow_dispatch input.

Key steps in the workflow:

Checkout repository.

Configure AWS credentials using OIDC.

Setup Terraform.

Validate Terraform configuration.

Initialize Terraform with S3 backend.

Plan and apply or destroy infrastructure.

Example workflow trigger:


on:
  workflow_dispatch:
    inputs:
      terraform_action:
        description: "Select Terraform action"
        required: true
        default: "apply"
        type: choice
        options:
          - apply
          - destroy
Manual Terraform Commands (Local)
You can also run Terraform manually:


# Initialize backend
terraform init -reconfigure

# Plan changes
terraform plan -out=tfplan

# Apply changes
terraform apply tfplan

# Destroy infrastructure
terraform destroy -auto-approve
Environments
dev: For testing and development. Uses smaller instance types and limited resources.

prod: For production. Uses higher-capacity instances and separate S3 backend keys.

Each environment has:

terraform.tfvars for environment-specific variables.

Isolated VPC, subnets, and security groups.

Separate Terraform state in S3.

Security & Best Practices
IAM least privilege: GitHub Actions uses OIDC with an assumed role that has only necessary permissions.

SSM Parameters: Sensitive data (like DB passwords) stored in AWS Systems Manager Parameter Store as SecureString.

Encrypted S3 backend: Terraform state is stored securely in S3 with versioning and encryption enabled.

Subnet isolation: Public and private subnets used for security separation.

Resource tagging: All resources are tagged with environment and project name for traceability.

Validation and formatting: Terraform validate and fmt are included in CI workflow.

Architecture Diagram

+----------------+
|   Internet     |
+----------------+
         |
         v
+--------------------+
| Application LB     |
+--------------------+
         |
         v
+----------------+
| EC2 Instances  |
| (Public Subnet)|
+----------------+
         |
         v
+----------------+
| RDS MySQL DB   |
| (Private Subnet)|
+----------------+

Public Subnets host ALB and EC2 instances accessible from the internet.

Private Subnets host RDS DB, inaccessible directly from the internet.

Versioning
Module repository: Version tags (v1.0.0, v1.1.0, etc.) are used to maintain module stability.

Deployment repository: References specific module versions to ensure reproducible infrastructure.

Troubleshooting
If GitHub Actions fails due to permission errors, check the IAM role policy for missing actions (e.g., rds:CreateDBSubnetGroup).

For S3 backend lock issues, unlock state manually:


terraform force-unlock <LOCK_ID>
Ensure all environment variables and secrets are correctly configured in GitHub Actions.

License
This project is for educational purposes and follows best practices for Terraform, AWS, and DevSecOps.


