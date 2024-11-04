# Terraform & Ansible
## Trial Project

## Summary

- Linux EC2 instance is running on AWS and is publicly accessible.
- AWS infra and instance is configured with an Terraform.
- The playbook installs a PHP web server and a landing page that says "Welcome to Blinker19!"
- The playbook code is stored in a publicly accessible Git repository.


## Architecture Diagram

![Architecture Diagram](imags/simple.png)

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
2. Create or update Repository secrets 
  - AWS_ACCESS_KEY
  - AWS_SECRET_ACCESS_KEY

![Actions Secrets](images/github_secrets.png)


### Pull-Request Validation

- Github actions performs terraform steps to validate PR, before it is eligible for merge to master.
  - terraform fmt
  - terraform init
  - terraform validate
  - terraform plan

### Update


https://github.com/ansible-collections/cloud.terraform/tree/main


https://developer.hashicorp.com/terraform/tutorials/automation/github-actions
