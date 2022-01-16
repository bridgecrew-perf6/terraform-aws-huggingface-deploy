data aws_caller_identity {}

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
    python_file = md5(file("${local.app_dir}/*.py"))
    docker_file = md5(file("${local.app_dir}/Dockerfile"))
  }
  
  provisioner "local-exec" {
    command = <<Command
    aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${local.account_id}.dkr.ecr.${var.region}.amazonaws.com
    cd ${path.module}/../${local.app_dir}
    docker build -t ${aws_ecr_repository.repo.repository_url}:${local.ecr-image_tag} .
    docker push ${aws_ecr_repository.repo.repository_url}:${local.ecr-image_tag}
    Command
    interpreter = ["bash", "-Command"]
  }
}

data aws_ecr_image lambda_image {
  depends_on = [null_resource.ecr_image]
  repositorty_name = local.ecr_repository_name
  image_tag = local.ecr_image_tag
}

resource aws_lambda_function transformers_function {
  depends_on = [null_resource.ecr_image,
  aws_efs_mount_target.transformers_efs_mount_target]
  function_name = "${local.prefix}-demo-transformers-function"
  role = aws_iam_role.lambda_efs.arn
  memory_size = 4096
  timeout = 300
  image_uri = "${aws_ecr_repository.repo.repository_url}@${data.aws_ecr_image.lambda_image.id}"
  package_type = "Image"

  file_system_config {
    arn = aws_efs_mount_target.transformers_efs_mount_target.arn
    local_mount_path = "/mnt/access"
  }

  vpc_config {
    subnet_ids = [aws_subnet.subnet_private.ids]
    security_group_ids = [aws_security_group.default_security_group.id]
  }
}