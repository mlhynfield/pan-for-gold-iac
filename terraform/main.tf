provider "aws" {
  region = local.region
}

locals {
  name   = var.name
  region = var.region
}

module "vpc" {
  source = "modules/vpc"

  name   = local.name
  region = local.region
}

module "security_group" {
  name = local.name
}

module "nodepool" {
  name   = local.name
  region = local.region
}