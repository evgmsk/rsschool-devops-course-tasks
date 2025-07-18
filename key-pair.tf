# Generate SSH key pair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Create AWS Key Pair
resource "aws_key_pair" "main" {
  key_name   = "terraform-key"
  public_key = tls_private_key.ssh_key.public_key_openssh

  tags = {
    Name = "terraform-key-pair"
  }
}

