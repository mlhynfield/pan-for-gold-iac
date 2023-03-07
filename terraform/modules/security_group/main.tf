provider "aws" {
  region = local.region
}

locals {
  name   = "${var.name}-sg"
  region = var.region

  tags = {
    app = "${var.name}"
  }
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name   = local.name
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
