data aws_caller_identity "current" {}

locals {
  prefix = "transformers"
  app_dir = "lambda"
  account_id = data.aws_caller_identity.current.account_id
  ecr_repository_name = "${local.prefix}-demo-lambda-container"
  ecr-image_tag = "latest"
}

resource aws_ecr_repository repo {
  name = local.ecr_repository_name
}

resource null_resource ecr_image {
  triggers = {
    python_file = md5(file("${path.module}/../${local.app_dir}/sentiment.py"))
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

resource aws_lambda_function transformers_function {
  depends_on = [null_resource.ecr_image,
  aws_efs_mount_target.efs_mount]
  function_name = "${local.prefix}-demo-transformers-function"
  role = aws_iam_role.lambda_efs_transformers.arn
  memory_size = 4096
  timeout = 300
  image_uri = "${aws_ecr_repository.repo.repository_url}@${data.aws_ecr_image.lambda_image.id}"
  package_type = "Image"

  file_system_config {
    arn = aws_efs_access_point.efs_access_point.arn
    local_mount_path = "/mnt/access"
  }

  vpc_config {
    subnet_ids = [aws_subnet.subnet_private.id]
    security_group_ids = [aws_default_security_group.default_security_group.id]
  }
}