output function_names {
  value = aws_lambda_function.transformers_function.function_name
}

output container_name {
  value = "${aws_ecr_repository.repo.repository_url}@${data.aws_ecr_image.lambda_image.id}"
}
