//AWS Configuration
#variable "access_key" {}
#variable "secret_key" {}

variable "region" {
  default = "us-east-1"
}

// Availability zones for the region
variable "az1" {
  default = "us-east-1a"
}

variable "vpccidr" {
  default = "10.200.0.0/16"
}

variable "publiccidraz1" {
  default = "10.200.1.0/24"
}

variable "privatecidraz1" {
  default = "10.200.2.0/24"
}


// License Type to create FortiGate-VM
// Provide the license type for FortiGate-VM Instances, either byol or payg.
variable "license_type" {
  default = "payg"
}

// BYOL License format to create FortiGate-VM
// Provide the license type for FortiGate-VM Instances, either token or file.
variable "license_format" {
  default = "file"
}

// instance architect
// Either arm or x86
variable "arch" {
  default = "x86"
}

// use s3 bucket for bootstrap
// Either true or false
//
variable "bucket" {
  type    = bool
  default = false
}

// instance type needs to match the architect
// c5.xlarge is x86_64
// c6g.xlarge is arm
// For detail, refer to https://aws.amazon.com/ec2/instance-types/
variable "size" {
  default = "c5.xlarge"
}

// AMIs for FGTVM-7.4.8
variable "fgtami" {
  description = "FortiGate AMI mapping by region, architecture, and license type"
  type        = map(map(map(string)))

  default = {
    us-east-1 = {
      x86 = {
        payg = "ami-0d8ab3309f7946a19"
        byol = "ami-0d8ab3309f7946a19"
      }
    }
  }
}

//  Existing SSH Key on the AWS 
variable "keyname" {
  default = "MLR-LAB-KEY"
}

variable "adminsport" {
  default = "8443"
}

variable "bootstrap_fgtvm" {
  // Change to your own path
  type    = string
  default = "fgtvm.conf"
}


// license file for the active fgt
variable "license" {
  // Change to your own byol license file, license.lic
  type    = string
  default = "license.lic"
}
