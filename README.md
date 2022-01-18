# Deploying HuggingFace Transformers Models with Terraform:

This repo can be forked to deploy your HuggingFace models to AWS using Terraform. It is inspired by Chris Munns's blog post on deploying zero administration inference of HuggingFace Models using the AWS CDK. If you already have the rest of your stack deployed using Terraform, this solution may be more helpful to keep your IaC code consolidated. 

The template is dynamic and will deploy as many lambda functions as there are .py files in your `lambda` directory.

## Pre-requisites:

- [**git**](https://github.com/): To clone the code and make any PRs to this repo
- [**AWS CLI**](https://aws.amazon.com/cli/): We will be using the AWS CLI to authenticate and push resource to AWS
- [**Docker**](https://www.docker.com/): Docker will help us containerise the images and deploy the to AWS ECR so they can be picked up deployed to our Lambda function
- [**Terraform**](https://www.terraform.io/): We will be using Terraform to deploy the full stack as well as destroying it at the end

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

```Terraform
terraform init

terraform plan

terraform apply
```

## Walkthrough

### Models

- Sentiment / Summarization

We are using the boilerplate code from the transformers library to keep the example as simple as possible. Note a few important details: the *nlp* model object is defined outside of the handler, this means that if the model is already loaded in the lambda it can be used straight away for inference. Additionally, the model is cached to the EFS filesystem under `/mnt/hf_models_cache` so we only need to make a call to download the model once. We define this cache location as an environment variable for the lambda as part of the Terraform script. 

```python
from transformers import pipeline

nlp = pipeline("sentiment-analysis")

def handler(event, context):
    response = {
        "statusCode": 200,
        "body": nlp(event['text'])[0]
    }
    return response
```

## Dockerfile

This is taken from the original AWS example, we use the `transformers-ptorch-cpu` base image as it already has torch optimised for cpu inference, lambda build dependencies are added to the image as well as some of the pre-requisite transformers libraries which are not held in the original image, [lambdaric](https://pypi.org/project/awslambdaric/) provides a runtime interface client to lambda and is used as the `ENTRYPOINT` for docker. the `CMD` is dynamically adjusted using Terraform.

```Dockerfile
ARG FUNCTION_DIR="/function/"

FROM huggingface/transformers-pytorch-cpu as build-image


# Include global arg in this stage of the build
ARG FUNCTION_DIR

# Install aws-lambda-cpp build dependencies
RUN apt-get update && \
  apt-get install -y \
  g++ \
  make \
  cmake \
  unzip \
  libcurl4-openssl-dev


# Create function directory
RUN mkdir -p ${FUNCTION_DIR}

# Copy handler function
COPY *.py ${FUNCTION_DIR}

# Install the function's dependencies
RUN pip uninstall --yes jupyter
RUN pip install --target ${FUNCTION_DIR} awslambdaric
RUN pip install --target ${FUNCTION_DIR} sentencepiece protobuf

FROM huggingface/transformers-pytorch-cpu

# Include global arg in this stage of the build
ARG FUNCTION_DIR
# Set working directory to function root directory
WORKDIR ${FUNCTION_DIR}

# Copy in the built dependencies
COPY --from=build-image ${FUNCTION_DIR} ${FUNCTION_DIR}

ENTRYPOINT [ "python3", "-m", "awslambdaric" ]

# This will get replaced by the proper handler by the Terraform script
CMD [ "sentiment.handler" ]
```


## Terraform

The IaC code is split into logical parts to make it easier to extend and maintain.

.
├── efs.tf
├── iam.tf
├── lambda.tf
├── main.tf
├── vars.tf
├── vpc.tf

### lamda.tf

The script looks for changes in the Dockerfile and/or any of the python scripts to trigger a local provisionner which runs aws login, and builds and push the image to ECR.

```terraform
resource aws_ecr_repository repo {
  name = local.ecr_repository_name
}

resource null_resource ecr_image {
  triggers = {
    python_file = md5(join("", [for f in fileset("${path.module}/../${local.app_dir}", "*.py"): filesha1(f)]))
    docker_file = md5(file("${path.module}/../${local.app_dir}/Dockerfile"))
  }
  
  provisioner "local-exec" {
    command = <<Command
    aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${local.account_id}.dkr.ecr.${var.region}.amazonaws.com
    cd ${path.module}/../${local.app_dir}
    docker build -t ${aws_ecr_repository.repo.repository_url}:${local.ecr-image_tag} .
    docker push ${aws_ecr_repository.repo.repository_url}:${local.ecr-image_tag}
    Command
  }
}

data aws_ecr_image lambda_image {
  depends_on = [null_resource.ecr_image]
  repository_name = local.ecr_repository_name
  image_tag = local.ecr-image_tag
}
```

The lambda provisionning script is dynamic, looking at the full folder of .py scripts. It uses a `for_each` argumnent to generate one lambda function for each .py file in the lambda folder. As we want to use a local cache on EFS to store the downloaded models, we pass through the environment variable as part of the lambda configuration. Each lambda function is mounted to a single shared EFS via a VPC.   

Finally, we overwrite the `CMD` using the name of each python file + '.handler' to provide the entrypoint for the lambda. 

```Terraform
resource aws_lambda_function transformers_function {
  for_each         = fileset("${path.module}/../lambda", "*.py")
  depends_on       = [null_resource.ecr_image,
                      aws_efs_mount_target.efs_mount]
  function_name    = trimsuffix(each.value,".py")
  role             = aws_iam_role.lambda_efs_transformers.arn
  memory_size      = 4096
  timeout          = 300
  image_uri        = "${aws_ecr_repository.repo.repository_url}@${data.aws_ecr_image.lambda_image.id}"
  package_type     = "Image"

  image_config {
    command = [ "${trimsuffix(each.value,".py")}.handler" ]
  }

  environment {
    variables = {
      TRANSFORMERS_CACHE: "/mnt/hf_models_cache"
    }
  } 

  file_system_config {
    arn = aws_efs_access_point.efs_access_point.arn
    local_mount_path = "/mnt/hf_models_cache"
  }

  vpc_config {
    subnet_ids = [aws_subnet.subnet_private.id]
    security_group_ids = [aws_default_security_group.default_security_group.id]
  }
}
```

We also have a *NAT Gateway* in place to allow for internet access to fetch the models when the function is first called.

## Cleaning up
After you are finished experimenting with this project, run `terraform destroy` to remove all of the associated infrastructure.

## License
This library is licensed under the MIT No Attribution License. See the LICENSE file. Disclaimer: Deploying the demo applications contained in this repository will potentially cause your AWS Account to be billed for services.