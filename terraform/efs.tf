resource "aws_efs_file_system" "efs_example" {
  creation_token = "tf-huggingface-efs-example"
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"
  encrypted = true

  tags = {
    Name = "tf-huggingface-efs-example"
  }
}

resource "aws_efs_mount_target" "efs_mount" {
  file_system_id = aws_efs_file_system.efs_example.id
  subnet_id      = aws_subnet.subnet_private.id
  security_groups = [aws_default_security_group.default.id]
}

resource "aws_efs_access_point" "efs_access_point" {
  file_system_id = aws_efs_file_system.efs_example.id
  posix_user     = {
    uid = 1000
    gid = 1000
  }
  root_directory {
    path = "/access"

    creation_info {
      owner_gid = 1000
      owner_uid = 1000
      permissions = "777"
    }
  }

}


resource "aws_efs_file_system_policy" "policy" {
  file_system_id = aws_efs_file_system.efs_example.id

  bypass_policy_lockout_safety_check = true
  
  policy = <<POLICY
  {
   Version = "2012-10-17",
   Id = "EFS_Policy_HuggingFace",
   Statement = [
     {
       Sid = "Allow_Access_To_EFS",
       Effect = "Allow",
       Principal = {
         AWS = "*"
       },
       Action = "elasticfilesystem:*",
       Resource = "${aws_efs_file_system.efs_example.arn}",
       Condition = {
          Bool = {
            "aws:SecureTransport" : "true"
          }
        }
     }
   ] 
  }
  POLICY
}
