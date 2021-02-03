output "ssh_connection_string" {
  value = "ssh -i \"${var.ssh_private_key_file}\" ubuntu@${aws_instance.ec2_instance.public_dns}"
}
output "instance_public_ip" {
  value       = aws_instance.ec2_instance.public_ip
  description = "The public IP of the web server"
}