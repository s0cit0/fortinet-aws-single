
output "FGTPublicIP" {
  value = aws_eip.FGTPublicIP.public_ip
}

output "Username" {
  value = "admin"
}

output "Password" {
  value = aws_instance.fgtvm.id
}

output "ami_test" {
  value = var.fgtami[var.region][var.arch][var.license_type]
}

output "subnet_test" {
  value = aws_subnet.publicsubnetaz1.id
}

output "iam_profile_test" {
  value = var.bucket ? aws_iam_instance_profile.fortigate[0].id : "not used"
}
