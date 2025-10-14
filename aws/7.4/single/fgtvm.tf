locals {
  bootstrap_configuration = templatefile(var.bootstrap_fgtvm, {
    adminsport = var.adminsport
  })

  license_file_content = file(var.license)

  license_payload = (
    var.license_format == "token" ?
    "LICENSE-TOKEN:${chomp(local.license_file_content)} INTERVAL:4 COUNT:4" :
    local.license_file_content
  )
  s3_bucket_id = var.bucket ? aws_s3_bucket.s3_bucket[0].id : null

  s3_user_data_file = var.bucket ? jsonencode({
    bucket  = local.s3_bucket_id
    region  = var.region
    license = var.license
    config  = var.bootstrap_fgtvm
  }) : null

  s3_user_data_token = var.bucket ? jsonencode({
    bucket          = local.s3_bucket_id
    region          = var.region
    "license-token" = local.license_file_content
    config          = var.bootstrap_fgtvm
  }) : null
}

resource "aws_network_interface" "eth0" {
  subnet_id         = aws_subnet.publicsubnetaz1.id
  source_dest_check = false

  tags = {
    Name    = "fgtvm-port1"
    Project = "MLR-LAB"
  }
}

resource "aws_network_interface_sg_attachment" "eth0_sg" {
  security_group_id    = aws_security_group.public_allow.id
  network_interface_id = aws_network_interface.eth0.id
}

resource "aws_network_interface" "eth1" {
  subnet_id         = aws_subnet.privatesubnetaz1.id
  source_dest_check = false

  tags = {
    Name    = "fgtvm-port2"
    Project = "MLR-LAB"
  }
}

resource "aws_network_interface_sg_attachment" "eth1_sg" {
  security_group_id    = aws_security_group.allow_all.id
  network_interface_id = aws_network_interface.eth1.id
}

resource "aws_network_interface_attachment" "eth1_attach" {
  depends_on           = [aws_instance.fgtvm, aws_network_interface_sg_attachment.eth1_sg]
  instance_id          = aws_instance.fgtvm.id
  network_interface_id = aws_network_interface.eth1.id
  device_index         = 1
}

data "cloudinit_config" "config" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "config"
    content_type = "text/x-shellscript"
    content      = local.bootstrap_configuration
  }

  part {
    filename     = "license"
    content_type = "text/plain"
    content      = local.license_payload
  }
}

resource "aws_instance" "fgtvm" {
  ami                         = var.fgtami[var.region][var.arch][var.license_type]
  instance_type               = var.size
  availability_zone           = var.az1
  key_name                    = var.keyname
  subnet_id                   = aws_subnet.publicsubnetaz1.id
  source_dest_check           = false
  vpc_security_group_ids      = [aws_security_group.public_allow.id]
  associate_public_ip_address = true

  user_data = var.bucket ? (
    var.license_format == "file" ? local.s3_user_data_file : local.s3_user_data_token
  ) : data.cloudinit_config.config.rendered

  iam_instance_profile = var.bucket ? aws_iam_instance_profile.fortigate[0].id : null

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

  depends_on = [aws_network_interface_sg_attachment.eth0_sg]
}
