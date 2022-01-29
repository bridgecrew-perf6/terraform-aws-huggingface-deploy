# General Configuration

variable "region" {
  type = string
  description = "AWS region"
  default = "us-east-1"
}

variable "runtime" {
  type = string
  description = "Runtime for the Lambda function"
  default = "python3.8"
}

variable "project" {
  type = string
  description = "Name of the project"
  default = "terraform-huggingface-lambda"
  }

# AWS Lambda Function Configuration

variable "memory" {
  type = string
  description = "Memory size for the Lambda function"
  default = "4096"
}

variable "timeout" {
  type = string
  description = "Timeout for the Lambda function"
  default = "300"
}

variable "lambda_mount_path" {
  type = string
  description = "Timeout for the Lambda function"
  default = "/mnt"
}

variable "lambda_transformers_cache" {
  type = string
  description = "Transformers cache directory for the Lambda function"
  default = "/mnt/hf_models_cache"
}


# AWS VPC Configuration

variable "subnet_public_cidr_block" {
  type = string
  description = "CIDR block for the public subnet"
  default = "10.0.0.0/21"
  }

variable "subnet_private_cidr_block" {
  type = string
  description = "CIDR block for the private subnet"
  default = "10.0.8.0/21"
}

variable "vpc_cidr_block" {
  type = string
  description = "VPC CIDR block"
  default = "10.0.0.0/16"
}

# AWS EFS Configuration

variable "efs_permissions" {
  type = string
  description = "VPC CIDR block"
  default = "777"
}

variable "efs_root_directory" {
  type = string
  description = "VPC CIDR block"
  default = "/mnt"
}