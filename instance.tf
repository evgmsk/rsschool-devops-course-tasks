# Security Group for NAT Instance
resource "aws_security_group" "nat_sg" {
  name_prefix = "nat-sg-"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nat-security-group"
  }
}

# Security Group for Bastion Host
resource "aws_security_group" "bastion_sg" {
  name_prefix = "bastion-sg-"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-security-group"
  }
}

# Security Group for Private Instances
resource "aws_security_group" "private_sg" {
  name_prefix = "private-sg-"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private-security-group"
  }
}

# NAT Instance in public subnet
resource "aws_instance" "nat" {
  ami               = "ami-0c38b837cd80f13bb" # Ubuntu 24.04 LTS
  instance_type     = "t2.nano"
  subnet_id         = aws_subnet.public_2.id
  source_dest_check = false
  key_name          = aws_key_pair.main.key_name

  vpc_security_group_ids = [aws_security_group.nat_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
    sysctl -p
    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    iptables -A FORWARD -i eth0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -A FORWARD -i eth0 -o eth0 -j ACCEPT
    iptables-save > /etc/iptables/rules.v4
    apt-get install -y iptables-persistent
  EOF

  tags = {
    Name = "nat-instance"
  }
}

# Bastion Host in public subnet
resource "aws_instance" "bastion" {
  ami           = "ami-0c38b837cd80f13bb" # Ubuntu 24.04 LTS
  instance_type = "t2.nano"
  subnet_id     = aws_subnet.public_1.id
  key_name      = aws_key_pair.main.key_name

  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "bastion-host"
  }
}

# Private Instance for testing
resource "aws_instance" "private" {
  ami           = "ami-0c38b837cd80f13bb" # Ubuntu 24.04 LTS
  instance_type = "t2.nano"
  subnet_id     = aws_subnet.private_1.id
  key_name      = aws_key_pair.main.key_name

  vpc_security_group_ids = [aws_security_group.private_sg.id]

  tags = {
    Name = "private-server"
  }
}
