data aws_caller_identity "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

resource aws_ecr_repository repo {
  name = var.ecr_repository_name
}

resource null_resource ecr_image {
  triggers = {
    python_file = md5(file("${path.module}/../${var.lambda_dir}/sentiment.py"))
    docker_file = md5(file("${path.module}/../${var.lambda_dir}/Dockerfile"))
  }
  
  provisioner "local-exec" {
    command = <<Command
    aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${local.account_id}.dkr.ecr.${var.region}.amazonaws.com
    cd ${path.module}/../${var.lambda_dir}
    docker build -t ${aws_ecr_repository.repo.repository_url}:${var.ecr_image_tag} .
    docker push ${aws_ecr_repository.repo.repository_url}:${var.ecr_image_tag}
    Command
  }
}

data aws_ecr_image lambda_image {
  depends_on = [null_resource.ecr_image]
  repository_name = var.ecr_repository_name
  image_tag = var.ecr_image_tag
}


resource aws_lambda_function transformers_function {
  for_each         = fileset("${path.module}/../lambda", "*.py")
  depends_on       = [null_resource.ecr_image,
  aws_efs_mount_target.efs_mount]
  function_name = trimsuffix(each.value,".py")
  role = aws_iam_role.lambda_efs_transformers.arn
  memory_size = var.memory
  timeout = var.timeout
  image_uri = "${aws_ecr_repository.repo.repository_url}@${data.aws_ecr_image.lambda_image.id}"
  package_type = "Image"

  image_config {
    command = [ "${trimsuffix(each.value,".py")}.handler" ]
  }

  environment {
    variables = {
      TRANSFORMERS_CACHE: var.transformers_cache
    }
  } 

  file_system_config {
    arn = aws_efs_access_point.efs_access_point.arn
    local_mount_path = var.transformers_cache
  }

  vpc_config {
    subnet_ids = [aws_subnet.subnet_private.id]
    security_group_ids = [aws_default_security_group.default_security_group.id]
  }
}