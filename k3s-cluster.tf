# Security Group for k3s cluster
resource "aws_security_group" "k3s_sg" {
  name_prefix = "k3s-sg-"
  vpc_id      = aws_vpc.main.id

  # SSH from bastion
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  # k3s API server
  ingress {
    from_port       = 6443
    to_port         = 6443
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  # k3s node communication
  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "udp"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k3s-security-group"
  }
}



# k3s Worker Node
resource "aws_instance" "k3s_worker" {
  ami           = "ami-0c38b837cd80f13bb" # Ubuntu 24.04 LTS
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_2.id
  key_name      = aws_key_pair.main.key_name

  vpc_security_group_ids = [aws_security_group.k3s_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    
    # Wait for master to be ready
    sleep 60
    
    # Get master IP and token (simplified - in production use proper service discovery)
    MASTER_IP="${aws_instance.k3s_master.private_ip}"
    
    # Install k3s agent
    curl -sfL https://get.k3s.io | K3S_URL=https://$MASTER_IP:6443 sh -
  EOF

  depends_on = [aws_instance.k3s_master]

  tags = {
    Name = "k3s-worker"
    Role = "worker"
  }
}