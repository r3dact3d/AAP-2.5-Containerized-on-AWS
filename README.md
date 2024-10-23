# Terraform & Ansible
## Trial Project

## Summary

- Linux EC2 instance is running on AWS and is publicly accessible.
- AWS infra and instance is configured with an Terraform.
- The playbook installs a PHP web server and a landing page that says "Welcome to Blinker19!"
- The playbook code is stored in a publicly accessible Git repository.


## Architecture Diagram

![Architecture Diagram](simple.png)

## Implementation
### Assumptions
- AWS Account
  - Programmatic Access Keys
- Tools installed
  - Git
  - terraform

### Procedure
1. Gather requirements
  - Clone GitHub repository
  - AWS Access keys
2. Deploy
  - Change to the working directory
    `cd Trial-Project/`
  - Initialize with AWS Provider
    `terraform init`
  - Edit variables.tf and update variables with access keys
  - Create and review plan
    `terraform plan`
  - Apply plan
    `terraform apply -auto-approve`
3. **Output** will give you public IP address to access landing page
4. Access landing page http://<public_ip>/blinker19.php
5. Tear down procedure
  `terraform destroy -auto-approve`

### Pull-Request Validation

- Github actions performs terraform steps to validate PR, before it is eligible for merge to master.
  - terraform fmt
  - terraform init
  - terraform validate
  - terraform plan
