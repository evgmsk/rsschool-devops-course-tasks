# Output the public IP addresses
output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = aws_instance.bastion.public_ip
}

output "nat_instance_public_ip" {
  description = "Public IP of the NAT instance"
  value       = aws_instance.nat.public_ip
}

output "private_instance_ip" {
  description = "Private IP of the private instance"
  value       = aws_instance.private.private_ip
}

output "ssh_command_bastion" {
  description = "SSH command to connect to bastion host"
  value       = "ssh -i terraform-key.pem ubuntu@${aws_instance.bastion.public_ip}"
}