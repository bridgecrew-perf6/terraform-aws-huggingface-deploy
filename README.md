# Deploying HuggingFace Transformers Models with Terraform:

This repo can be forked to deploy your HuggingFace models to AWS using Terraform. It is inspired by Philip Schmidt's blog post on deploying a set of HuggingFace Models using the AWS CDK. If you already have the rest of your stack deployed using Terraform, this solution may be more helpful to keep your IaC code consolidatd.

## Pre-requisites:
[**GIT**](https://github.com/): To clone the code and make any PRs to this repo
[**AWS CLI**](https://aws.amazon.com/cli/): We will be using the AWS CLI to authenticate and push resource to AWS
[**Docker**](https://www.docker.com/): Docker will help us containerise the images and deploy the to AWS ECR so they can be picked up deployed to our Lambda function
[**Terraform**](https://www.terraform.io/): We will be using Terraform to deploy the full stack as well as destroying it at the end

## AWS Components:

**Lambda**: We're going to be deploying the code to a Lambda function for Serverless Inference, this should in most circumstances reduce the costs and overheads of model serving, although some use cases may benefit from a deployment to Kubernetes.

**ECR**: As we are deploying a docker Image, we will need to store and version our container in the Amazon Elastic Container Registry

**EFS**: In order to reduce the number of times we need to download the model, we will be mounting an Elastic File Store to our Lambda, this means we can cache the model to reduce our overall latency of inference

**VPC** : As we will be mounting an EFS we will need to set-up a VPC to enable the EFS to be mounted to the Lambda

## Python Libraries

[**Transformers**](https://github.com/huggingface/transformers): We will be deploying a sentiment analysis model using the *pipelines* module in the Transformers package

## Set-Up

Clone the repository

```git
git clone https://github.com/kayvane1/terraform-huggingface-deploy.git
```

Intialise your AWS CLI to ensure you are authenticated

```bash
 aws configure
```

Ensure Docker is up and running using docker desktop, you should be able to run a docker command without any error messages

```Docker 
docker ps
```

Clone the repo and navigate to the terraform directory to run the terraform steps

``` Terraform
terraform init

terraform plan

terraform apply
```

## Walkthrough

