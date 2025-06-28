# Output the public IP addresses
output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = aws_instance.bastion.public_ip
}

output "nat_gateway_ip" {
  description = "Public IP of the NAT Gateway"
  value       = aws_eip.nat.public_ip
}

output "k3s_master_private_ip" {
  description = "Private IP of the k3s master instance"
  value       = aws_instance.k3s_master.private_ip
}

output "ssh_command_bastion" {
  description = "SSH command to connect to bastion host"
  value       = "ssh -i terraform-key.pem ubuntu@${aws_instance.bastion.public_ip}"
}

output "k3s_master_ip" {
  description = "Private IP of k3s master node"
  value       = aws_instance.k3s_master.private_ip
}

output "k3s_worker_ip" {
  description = "Private IP of k3s worker node"
  value       = aws_instance.k3s_worker.private_ip
}

output "k3s_access_command" {
  description = "Command to access k3s cluster from bastion"
  value       = "ssh -i terraform-key.pem ubuntu@${aws_instance.k3s_master.private_ip}"
}

output "ssh_private_key" {
  description = "Private SSH key for accessing instances"
  value       = tls_private_key.ssh_key.private_key_pem
  sensitive   = true
}