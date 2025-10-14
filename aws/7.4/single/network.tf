// Creating Internet Gateway
resource "aws_internet_gateway" "fgtvmigw" {
  vpc_id = aws_vpc.fgtvm-vpc.id
  tags = {
    Name    = "fgtvmigw"
    Project = "MLR-LAB"
  }
}

// Route Table
resource "aws_route_table" "fgtvmpublicrt" {
  vpc_id = aws_vpc.fgtvm-vpc.id

  tags = {
    Name    = "fgtvmpublicrt"
    Project = "MLR-LAB"
  }
}

resource "aws_route_table" "fgtvmprivatert" {
  vpc_id = aws_vpc.fgtvm-vpc.id

  tags = {
    Name    = "fgtvmprivatert"
    Project = "MLR-LAB"
  }
}

resource "aws_route" "externalroute" {
  route_table_id         = aws_route_table.fgtvmpublicrt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.fgtvmigw.id
}

resource "aws_route" "internalroute" {
  #depends_on             = [aws_network_interface_attachment.port2]
  route_table_id         = aws_route_table.fgtvmprivatert.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_network_interface.eth1.id

}

resource "aws_route_table_association" "public1associate" {
  subnet_id      = aws_subnet.publicsubnetaz1.id
  route_table_id = aws_route_table.fgtvmpublicrt.id
}

resource "aws_route_table_association" "internalassociate" {
  subnet_id      = aws_subnet.privatesubnetaz1.id
  route_table_id = aws_route_table.fgtvmprivatert.id
}

resource "aws_eip" "FGTPublicIP" {
  depends_on        = [aws_instance.fgtvm]
  domain            = "vpc"
  network_interface = aws_instance.fgtvm.primary_network_interface_id

  tags = {
    Name    = "FGTPublicIP"
    Project = "MLR-LAB"
  }
}

// Security Group

resource "aws_security_group" "public_allow" {
  name        = "Public Allow"
  description = "Public Allow traffic"
  vpc_id      = aws_vpc.fgtvm-vpc.id

  # Allow all traffic from 10.200.0.0/16 (APP02)
  ingress {
    description = "Allow all from APP02"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.200.0.0/16"]
  }

  # SSH (port 22) from trusted IPs
  ingress {
    description = "SSH from CQ jumpbox"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["107.20.72.204/32"]
  }

  ingress {
    description = "SSH from Davids house"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["47.198.67.186/32"]
  }

  # HTTPS (443) from trusted IPs
  ingress {
    description = "HTTPS from CQ jumpbox"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["107.20.72.204/32"]
  }

  ingress {
    description = "HTTPS from Davids house"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["47.198.67.186/32"]
  }

  # TCP 8443 from trusted IPs
  ingress {
    description = "8443 from CQ jumpbox"
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["107.20.72.204/32"]
  }

  ingress {
    description = "8443 from Davids house"
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["47.198.67.186/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "Public Allow"
    Project = "MLR-LAB"
  }
}

resource "aws_security_group" "allow_all" {
  name        = "Allow All"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.fgtvm-vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "Allow All"
    Project = "MLR-LAB"
  }
}
