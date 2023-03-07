provider "aws" {
  region = local.region
}

locals {
  name   = var.name
  region = var.region

  user_data = <<-EOT
  #!/bin/bash
  echo "Panning for gold!"
  EOT

  tags = {
    app = "${var.name}"
  }
}

module "nodepool" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  for_each = toset(["node01"])

  name = "${local.name}-${each.key}"

  ami                         = "ami-0f254a6bcc5bdad58"
  instance_type               = "t4g.micro"
  key_name                    = local.name
  vpc_security_group_ids      = ["sg-12345678"]
  associate_public_ip_address = true
  subnet_id                   = module.vpc.public_subnets[index(each.key, each.value) % length(module.vpc.public_subnets)]

  create_iam_instance_profile = true
  iam_role_description        = "IAM role for EC2 instance"
  iam_role_policies = {
    AdministratorAccess = "arn:aws:iam::aws:policy/AdministratorAccess"
  }

  user_data_base64            = base64encode(local.user_data)
  user_data_replace_on_change = true

  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      throughput  = 200
      volume_size = 50
      tags = {
        app = "pan-for-gold"
      }
    },
  ]

  tags = local.tags
}