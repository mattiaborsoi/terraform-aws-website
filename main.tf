terraform {
  required_version = ">= 0.13"
}
provider "aws" {
  region = var.region
}
terraform {
  backend "s3" {
    bucket = "terraform-website-state" #change this to your bucket name if different
    key = "terraform/terraform.tfstate"
    region  = "eu-west-2" #change this to your region. we can't use variables here so it needs to be manually changed to your region if different
    dynamodb_table = "terraform-website-state-lock-dynamo"
    encrypt = true
  }
}
resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name = "terraform-website-state-lock-dynamo"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20
  attribute {
    name = "LockID"
    type = "S"
  }
}

locals {
  my_public_ip = "data.external.myipaddr.result.ip"
}

resource  "random_integer" "az_id" {
  min = 0
  max = length(var.allowed_availability_zone_id)
}
locals {
  availability_zone = "${var.region}${element(var.allowed_availability_zone_id, random_integer.az_id.result)}"
}

resource "aws_spot_instance_request" "ec2_instance" {
  ami                    = var.ec2_ami
  instance_type          = var.ec2_instance_type
  availability_zone = local.availability_zone
  security_groups = [aws_security_group.default.name]
  user_data     = templatefile("user-data.sh", {
    cloudflareZone = var.cloudflareZone
    cloudflareDNSRecord = var.cloudflareDNSRecord
    X-Auth-Email = var.X-Auth-Email
    X-Auth-Key = var.X-Auth-Key
    CloudFlareDNSDomain = var.CloudFlareDNSDomain
  })
  key_name      = "terraform"

  # Spot configuration
    spot_type = "one-time"
    wait_for_fulfillment = true
  
  tags = {
    Name = "terraform-web-server"
  }
}

resource "aws_security_group" "default" {
  name = "terraform-security"

  tags = {
    App = "aws-terraform"
  }
}
# resource "aws_security_group_rule" "http_ingress" {
#   # Inbound HTTP from anywhere
#   type = "ingress"
#   description = "Allow HTTP connections from anywhere"
#   from_port   = 80
#   to_port     = 80
#   protocol    = "tcp"
#   cidr_blocks = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.default.id
# }

resource "aws_security_group_rule" "https_ingress" {
  # Inbound HTTPS from anywhere
  type = "ingress"
  description = "Allow HTTPS connections from anywhere"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.default.id
}

# Allow SSH connections from everywhere
# enable this if you want to be able to SSH in the server
resource "aws_security_group_rule" "ssh_ingress" {
  type = "ingress"
  description = "Allow ssh connections (port 22)"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  #cidr_blocks = ["${var.my_public_ip}/32"]
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.default.id
}

# Allow outbound connection to everywhere
resource "aws_security_group_rule" "default" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.default.id
}
