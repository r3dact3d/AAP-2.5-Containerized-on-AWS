# Terraform & Ansible
## Trial Project

## Summary

- RHEL EC2 instance is running on AWS and is publicly accessible.
- AWS infra and instance is configured with an Terraform.
- GitHub Actions workflow with automatically create a Plan on a Pull Request
- GitHub Actions workflow will automatically apply infra changes on a Pull Request Merge


## Architecture Diagram

![Architecture Diagram](imags/simple.png)

## Implementation
### Procedure
1. Gather requirements
  - Clone GitHub repository
  - AWS Access keys
2. Create or update Repository secrets 
  - AWS_ACCESS_KEY
  - AWS_SECRET_ACCESS_KEY

![Actions Secrets](images/github_secrets.png)

3. Validte the TF manifests in the terraform directory
  - main.tf
  - output.tf
  - user_data.txt
4. 

Login to ec2 instance
  - ansible-playbook -i inventory-growth ansible.containerized_installer.install -eansible_connection=local

### Pull-Request Validation

- Github actions performs terraform steps to validate PR, before it is eligible for merge to master.
  - terraform fmt
  - terraform init
  - terraform validate
  - terraform plan

### Update


https://github.com/ansible-collections/cloud.terraform/tree/main


https://developer.hashicorp.com/terraform/tutorials/automation/github-actions
