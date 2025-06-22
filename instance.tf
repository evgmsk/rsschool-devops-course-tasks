# Security Group for EC2 instance
resource "aws_security_group" "web_sg" {
  name_prefix = "web-sg-"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "web-security-group"
  }
}

# EC2 Instance in first public subnet
resource "aws_instance" "web" {
  ami           = "ami-0c38b837cd80f13bb" # Ubuntu 24.04 LTS
  instance_type = "t2.nano"
  subnet_id     = aws_subnet.public_1.id
  
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  
  tags = {
    Name = "web-server"
  }
}
