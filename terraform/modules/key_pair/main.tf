provider "aws" {
  region = local.region
}

locals {
  name   = "${var.name}-key"
  region = var.region

  tags = {
    app = "${var.name}"
  }
}

module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name   = local.name
  public_key = var.public_key

  tags = local.tags
}
