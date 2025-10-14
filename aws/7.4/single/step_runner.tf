# This file creates the Step Runner instance and its associated security group.

# Lookup latest Ubuntu Server 22.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "step_runner_sg" {
  name        = "step_runner_sg"
  description = "Allow SSH from trusted sources, allow all outbound"
  vpc_id      = aws_vpc.fgtvm-vpc.id

  # SSH from trusted external IPs
  # SSH from CQ jumpbox
  ingress {
    description = "SSH from CQ jumpbox (107.20.72.204/32)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["107.20.72.204/32"]
  }

  # SSH from Davids house
  ingress {
    description = "SSH from Davids house (47.198.67.186/32)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["47.198.67.186/32"]
  }

  # SSH from internal 10.200.0.0/16
  ingress {
    description = "SSH from APP02"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.200.0.0/16"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "step_runner.sg"
    Project = "MLR-LAB"
  }
}

resource "aws_instance" "step_runner" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  availability_zone           = var.az1
  subnet_id                   = aws_subnet.publicsubnetaz1.id
  key_name                    = var.keyname
  vpc_security_group_ids      = [aws_security_group.step_runner_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get upgrade -y
              apt-get install -y \
                ca-certificates \
                curl \
                gnupg \
                lsb-release

              mkdir -p /etc/apt/keyrings
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

              echo \
                "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
                $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

              apt-get update -y
              apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

              systemctl enable docker
              systemctl start docker
              usermod -aG docker ubuntu
              EOF

  tags = {
    Name    = "step_runner"
    Project = "MLR-LAB"
  }

  depends_on = [aws_security_group.step_runner_sg]
}