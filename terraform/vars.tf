# General Configuration

variable "region" {
  type = string
  description = "AWS region"
  default = "us-east-2"
}

variable "runtime" {
  type = string
  description = "Runtime for the Lambda function"
  default = "python3.8"
}

# VPC Configuration

variable "subnet_public_cidr_block" {
  type = string
  description = "CIDR block for the public subnet"
  default = "10.0.8.0/21"
  }

variable "project" {
  type = string
  description = "Name of the project"
  default = "terraform-huggingface-lambda"
  }

variable "subnet_private_cidr_block" {
  type = string
  description = "CIDR block for the private subnet"
  default = "10.0.8.0/21"
}

variable "vpc_cidr_block" {
  type = string
  description = "VPC CIDR block"
  default = ""
}