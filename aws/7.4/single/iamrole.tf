# Create an IAM Role to assign to the FortiGate VM instance
#
resource "aws_iam_role" "fortigate" {
  count = var.bucket ? 1 : 0
  name  = "fgtiamrole${random_string.random_name_post.result}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Sid = ""
      }
    ]
  })

  tags = {
    Name = "MLR-LAB"
  }
}

# IAM Policy for FortiGate to access the S3 Buckets
#
resource "aws_iam_role_policy" "fortigate-iam_role_policy" {
  count  = var.bucket ? 1 : 0
  name   = "fgtiamrolepolicy${random_string.random_name_post.result}"
  role   = aws_iam_role.fortigate[0].id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
   {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["arn:aws:s3:::${aws_s3_bucket.s3_bucket[0].id}"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": ["arn:aws:s3:::${aws_s3_bucket.s3_bucket[0].id}/*"]
    }
  ]
}
EOF
}

# Assign the IAM Profile to the FortiGate instance
#
resource "aws_iam_instance_profile" "fortigate" {
  count = var.bucket ? 1 : 0
  name  = "fgtiamprofile${random_string.random_name_post.result}"

  role = aws_iam_role.fortigate[0].name
}

# Create S3 bucket
#
resource "aws_s3_bucket" "s3_bucket" {
  count  = var.bucket ? 1 : 0
  bucket = "ftnts3boot${random_string.random_name_post.result}"

  tags = {
    Name = "MLR-LAB"
  }
}

# S3 Bucket license file for BYOL License
#
resource "aws_s3_object" "lic1" {
  count  = var.bucket ? 1 : 0
  bucket = aws_s3_bucket.s3_bucket[0].id
  key    = var.license
  source = var.license
  etag   = filemd5(var.license)

  tags = {
    Name = "MLR-LAB"
  }
}

# S3 Bucket config file for storing fgtvm config
#
resource "aws_s3_object" "conf" {
  count  = var.bucket ? 1 : 0
  bucket = aws_s3_bucket.s3_bucket[0].id
  key    = var.bootstrap_fgtvm
  content = templatefile(var.bootstrap_fgtvm, {
    adminsport = var.adminsport
  })

  tags = {
    Name = "MLR-LAB"
  }
}
