<!-- BEGIN_TF_DOCS -->
## Requirements

Terraform, Docker, AWS CI, AWS account

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.72.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_default_network_acl.default_network_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl) | resource |
| [aws_default_security_group.default_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_ecr_repository.repo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_efs_access_point.efs_access_point](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_access_point) | resource |
| [aws_efs_file_system.efs_example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) | resource |
| [aws_efs_file_system_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system_policy) | resource |
| [aws_efs_mount_target.efs_mount](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource |
| [aws_eip.eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_iam_role.lambda_efs_transformers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.lambda_efs_full_access_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lambda_execute_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lambda_vpc_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_internet_gateway.internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_lambda_function.transformers_function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_nat_gateway.nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route_table.private_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private_route_table_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public_route_table_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.subnet_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.subnet_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [null_resource.ecr_image](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_availability_zones.azs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ecr_image.lambda_image](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecr_image) | data source |
| [aws_iam_policy.lambda_efs_full_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy.lambda_execute](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy.lambda_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_efs_permissions"></a> [efs\_permissions](#input\_efs\_permissions) | VPC CIDR block | `string` | `"777"` | no |
| <a name="input_efs_root_directory"></a> [efs\_root\_directory](#input\_efs\_root\_directory) | VPC CIDR block | `string` | `"/mnt"` | no |
| <a name="input_lambda_mount_path"></a> [lambda\_mount\_path](#input\_lambda\_mount\_path) | Timeout for the Lambda function | `string` | `"/mnt"` | no |
| <a name="input_lambda_transformers_cache"></a> [lambda\_transformers\_cache](#input\_lambda\_transformers\_cache) | Transformers cache directory for the Lambda function | `string` | `"/mnt/hf_models_cache"` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Memory size for the Lambda function | `string` | `"4096"` | no |
| <a name="input_project"></a> [project](#input\_project) | Name of the project | `string` | `"terraform-huggingface-lambda"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-1"` | no |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | Runtime for the Lambda function | `string` | `"python3.8"` | no |
| <a name="input_subnet_private_cidr_block"></a> [subnet\_private\_cidr\_block](#input\_subnet\_private\_cidr\_block) | CIDR block for the private subnet | `string` | `"10.0.8.0/21"` | no |
| <a name="input_subnet_public_cidr_block"></a> [subnet\_public\_cidr\_block](#input\_subnet\_public\_cidr\_block) | CIDR block for the public subnet | `string` | `"10.0.0.0/21"` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Timeout for the Lambda function | `string` | `"300"` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | VPC CIDR block | `string` | `"10.0.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_name"></a> [container\_name](#output\_container\_name) | n/a |
| <a name="output_function_names"></a> [function\_names](#output\_function\_names) | n/a |
<!-- END_TF_DOCS -->