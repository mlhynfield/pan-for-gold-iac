provider "aws" {
  region = local.region
}

locals {
  name       = var.name
  region     = var.region
  public_key = var.public_key
}

module "vpc" {
  source = "./modules/vpc"

  name   = local.name
  region = local.region
}

module "security_group" {
  source = "./modules/security_group"

  name   = local.name
  region = local.region
}

module "key_pair" {
  source = "./modules/key_pair"

  name       = local.name
  region     = local.region
  public_key = local.public_key
}

module "nodepool" {
  source = "./modules/nodepool"

  name   = local.name
  region = local.region
}
