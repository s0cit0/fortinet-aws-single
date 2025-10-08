# Deployment of a FortiGate-VM (BYOL/PAYG) on AWS
## Introduction
A Terraform configuration to deploy a FortiGate-VM on AWS with only the essential networking components.

## Requirements
* [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html) >= 1.0.0
* Terraform Provider AWS >= 5.0.0

## Deployment overview
Terraform deploys the following components:
   - AWS VPC with 2 subnets
   - One FortiGate-VM instance with 2 NICs
   - Two Security Groups: one for external, one for internal traffic
   - Two Route tables: one for internal subnet and one for external subnet

![single-architecture](./aws-topology-single.png?raw=true "Single FortiGate-VM Architecture")

## Deployment
To deploy the FortiGate-VM to AWS:
1. Clone the repository.
2. Customize variables in the `terraform.tfvars.example` and `variables.tf` file as needed.  Rename `terraform.tfvars.example` to `terraform.tfvars` once updated.
3. Ensure your AWS credentials are available to Terraform (for example via environment variables or AWS profiles).
4. Initialize the providers and modules:
   ```sh
   $ cd aws/7.4/single
   $ terraform init
    ```
5. Submit the Terraform plan:
   ```sh
   $ terraform plan
   ```
6. Confirm and apply the plan:
   ```sh
   $ terraform apply
   ```
7. If output is satisfactory, type `yes`.

Output will include the information necessary to log in to the FortiGate-VM instance:
```sh
FGTPublicIP = <FGT Public IP>
Password = <FGT Password>
Username = <FGT Username>
```

After deployment, apply your FortiGate license and configuration manually using the exposed management interfaces.

## Destroy the instance
To destroy the instance, use the command:
```sh
$ terraform destroy
```

# Support
Fortinet-provided scripts in this and other GitHub projects do not fall under the regular Fortinet technical support scope and are not supported by FortiCare Support Services.
For direct issues, please refer to the [Issues](https://github.com/fortinet/fortigate-terraform-deploy/issues) tab of this GitHub project.
For other questions related to this project, contact [github@fortinet.com](mailto:github@fortinet.com).

## License
[License](https://github.com/fortinet/fortigate-terraform-deploy/blob/master/LICENSE) © Fortinet Technologies. All rights reserved.
