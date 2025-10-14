# This file creates the FortiManager instance and its associated security group and elastic IP.

resource "aws_security_group" "fmg_sg" {
  name        = "Fortinet-FortiManager-BYOL"
  description = "Fortinet FortiManager Centralized Security Management"
  vpc_id      = aws_vpc.fgtvm-vpc.id

  lifecycle {
    create_before_destroy = true
  }

  # Allow all protocols from 10.200.0.0/16
  ingress {
    description = "Allow all from APP02"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.200.0.0/16"]
  }

  # Existing public access rules
  # Allow SSH from trusted public IP
  ingress {
    description = "SSH from CQ jumpbox (107.20.72.204/32)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["107.20.72.204/32"]
  }

  # Allow HTTPS from trusted public IP
  ingress {
    description = "HTTPS from CQ jumpbox (107.20.72.204/32)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["107.20.72.204/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "FortiManager-SG"
    Project = "MLR-LAB"
  }
}

resource "aws_instance" "fmgvm" {
  ami                    = "ami-01b63991330f887b1"
  instance_type          = "m5.xlarge"
  availability_zone      = var.az1
  subnet_id              = aws_subnet.publicsubnetaz1.id
  key_name               = var.keyname
  vpc_security_group_ids = [aws_security_group.fmg_sg.id]

  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp2"
    volume_size = 20
  }

  tags = {
    Name    = "fmgvm"
    Project = "MLR-LAB"
  }

  depends_on = [aws_security_group.fmg_sg]
}

resource "aws_eip" "fmg_public_ip" {
  domain            = "vpc"
  network_interface = aws_instance.fmgvm.primary_network_interface_id

  tags = {
    Name    = "FMGPublicIP"
    Project = "MLR-LAB"
  }

  depends_on = [aws_instance.fmgvm]
}