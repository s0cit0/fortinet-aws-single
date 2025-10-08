// FGTVM instance

resource "aws_network_interface" "eth1" {
  description       = "fgtvm-port2"
  subnet_id         = aws_subnet.privatesubnetaz1.id
  source_dest_check = false

  tags = {
    Name    = "fgtvm-port2"
    Project = "MLR-LAB"
  }
}

resource "aws_network_interface_sg_attachment" "internalattachment" {
  security_group_id    = aws_security_group.allow_all.id
  network_interface_id = aws_network_interface.eth1.id
}

resource "aws_network_interface_attachment" "port2" {
  depends_on           = [aws_network_interface_sg_attachment.internalattachment]
  instance_id          = aws_instance.fgtvm.id
  network_interface_id = aws_network_interface.eth1.id
  device_index         = 1
}

resource "aws_instance" "fgtvm" {
  //it will use region, architect, and license type to decide which ami to use for deployment
  ami               = var.fgtami[var.region][var.arch][var.license_type]
  instance_type     = var.size
  availability_zone = var.az1
  key_name          = var.keyname
  subnet_id         = aws_subnet.publicsubnetaz1.id
  vpc_security_group_ids = [aws_security_group.public_allow.id]

  root_block_device {
    volume_type = "gp2"
    volume_size = 2
  }

  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = 30
    volume_type = "gp2"
  }

  tags = {
    Name    = "fgtvm"
    Project = "MLR-LAB"
  }
}
