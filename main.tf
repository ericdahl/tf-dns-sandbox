provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Name = "tf-dns-sandbox"
    }
  }
}


data "aws_ssm_parameter" "amazon_linux_2" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_key_pair" "default" {
  public_key = var.public_key
}

module "vpc_dns" {
  source = "./modules/vpc/workload"

  cidr_block = "10.1.0.0/16"

  admin_ip_cidr = var.admin_ip_cidr
  public_key    = var.public_key
}

module "vpc_workload" {
  source = "./modules/vpc/workload"

  for_each = toset([
    "10.2.0.0/16",
  ])
  cidr_block = each.value

  admin_ip_cidr = var.admin_ip_cidr
  public_key    = var.public_key
}