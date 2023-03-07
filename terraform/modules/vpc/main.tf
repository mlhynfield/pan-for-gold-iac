provider "aws" {
  region = local.region
}

locals {
  name   = "${var.name}-vpc"
  region = var.region

  tags = {
    app = "${var.name}"
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.name
  cidr = "10.0.0.0/16"

  azs            = ["${local.region}a", "${local.region}b", "${local.region}c"]
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  tags = local.tags

  vpc_tags = {
    Name = "${local.name}"
  }
}
