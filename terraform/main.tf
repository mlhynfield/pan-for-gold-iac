provider "aws" {
  region = local.region
}

locals {
  name   = var.name
  region = var.region

  public_key = var.public_key

  node_list = [
    "node01"
  ]

  user_data = templatefile(
    "user_data.tftpl",
    {
      name     = "${var.name}",
      repo_url = "${var.repo_url}"
    }
  )

  tags = {
    app = "${var.name}"
  }
}

# EC2 nodepool
module "nodepool" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 4.3"

  for_each = toset(local.node_list)

  name = "${local.name}-${each.key}"

  ami                         = "ami-0f254a6bcc5bdad58"
  ami_ssm_parameter           = "/aws/service/ami-amazon-linux-latest/amzn2-ami-kernel-5.10-hvm-arm64-gp2"
  instance_type               = "t4g.small"
  key_name                    = module.key_pair.key_pair_name
  vpc_security_group_ids      = [module.security_group.security_group_id]
  associate_public_ip_address = true
  subnet_id                   = module.vpc.public_subnets[index(local.node_list, "${each.value}") % length(module.vpc.public_subnets)]

  user_data_base64            = base64encode(local.user_data)
  user_data_replace_on_change = true

  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp2"
      volume_size = 50
    },
  ]

  tags = local.tags
}

# SSH key pair
module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name   = "${local.name}-key"
  public_key = var.public_key

  tags = local.tags
}

# VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${local.name}-vpc"
  cidr = "10.0.0.0/16"

  azs            = ["${local.region}a", "${local.region}b", "${local.region}c"]
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  tags = local.tags

  vpc_tags = {
    Name = "${local.name}"
  }
}

# Security group
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name   = "${local.name}-sg"
  vpc_id = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  egress_rules        = ["all-all"]

  ingress_with_cidr_blocks = [
    {
      from_port   = 2379
      to_port     = 2380
      protocol    = "tcp"
      description = "Required only for HA with embedded etcd"
      cidr_blocks = "10.0.0.0/16"
    },
    {
      from_port   = 6443
      to_port     = 6443
      protocol    = "tcp"
      description = "K3s supervisor and Kubernetes API Server"
      cidr_blocks = "10.0.0.0/16"
    },
    {
      from_port   = 8472
      to_port     = 8472
      protocol    = "udp"
      description = "Flannel VXLAN"
      cidr_blocks = "10.0.0.0/16"
    },
    {
      from_port   = 10250
      to_port     = 10250
      protocol    = "tcp"
      description = "Kubelet metrics"
      cidr_blocks = "10.0.0.0/16"
    },
    {
      from_port   = 51820
      to_port     = 51821
      protocol    = "tcp"
      description = "Flannel Wireguard"
      cidr_blocks = "10.0.0.0/16"
    },
    {
      from_port   = 15000
      to_port     = 15090
      protocol    = "tcp"
      description = "Istio"
      cidr_blocks = "10.0.0.0/16"
    }
  ]

  tags = local.tags
}
