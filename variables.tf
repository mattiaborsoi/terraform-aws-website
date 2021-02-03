variable "region" {
  description = "The aws region. Choose the one closest to you: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-available-regions"
  type = string
}

variable "allowed_availability_zone_id" {
  description = "The allowed availability zone identify (the letter suffixing the region). Choose ones that allows you to request the desired instance as spot instance in your region. An availability zone will be selected at random and the instance will be booted in it."
  type = list(string)
  default = ["a", "b","c"]
}

data "external" "myipaddr" {
program = ["bash", "-c", "curl -s 'https://api.ipify.org?format=json'"]
}

variable "ssh_private_key_file" {
  description = "The private SSH key used to connect to the EC2 instance"
  type = string
  default     = "~/.aws/terraform.pem"
}

variable "ec2_ami" {
  description = "Which AMI should we launch?"
  type = string
  default     = "ami-0287acb18b6d8efff" #ubuntu
}


variable "ec2_instance_type" {
  description = "EC2 instante size"
  type = string
  default     = "t3.micro"
}

variable "cloudflareZone" {
  description = "The ID of your zone. Check Cloudflare API for help"
  type = string
}

variable "cloudflareDNSRecord" {
  description = "The ID of your DNS record. Check Cloudflare API for help"
  type = string
}

variable "X-Auth-Email" {
  description = "Your Cloudflare account email"
  type = string
}

variable "X-Auth-Key" {
  description = "Your Cloudflare API access key. Check Cloudflare API for help"
  type = string
}

variable "CloudFlareDNSDomain" {
  description = "Your Cloudflare domain. In my case, borsoi.co.uk. Check Cloudflare API for help"
  type = string
}