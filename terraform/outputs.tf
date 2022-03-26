output function_names {
  description = "List of all generated lambda function names"
  value = [ for transformers_function in aws_lambda_function.transformers_function: transformers_function.function_name ]
}

output container_name {
  description = "Name of the container created on which the lambda runs"
  value = "${aws_ecr_repository.repo.repository_url}@${data.aws_ecr_image.lambda_image.id}"
}
