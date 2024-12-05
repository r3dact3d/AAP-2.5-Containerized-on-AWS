# Ansible Automation Platform 2.5 Containerized

## Terraform Infrastructure 

## Summary

- RHEL9 EC2 instance is running on AWS and is publicly accessible.
- AWS infra and instance is configured with Terraform.
- GitHub Actions workflow with automatically create a Plan on a Pull Request
- GitHub Actions workflow will automatically apply infra changes on a Pull Request Merge

NOTE: you should understand all the things in the terraform directory, especially the main.tf resources

## Architecture Diagram

![Architecture Diagram](images/simple.png)

## Implementation
### Procedure
1. Gather requirements
  - Clone GitHub repository
2. Create or update Repository secrets 

![Actions Secrets](images/github_secrets.png)

  - AWS_ACCESS_KEY
  - AWS_SECRET_ACCESS_KEY
  - ORG_ID          *Profile in cloud.redhat.com
  - ACTIVATION_KEY  *Create in cloud.redhat.com Inventory > System Configuration > Activation Keys
  - RHN_USER        *Redhat Network username to access.redhat.com 
  - RHN_PASS        *Redhat Network password to access.redhat.com
  - AAP_PASS        *this is the defaults for all passwords in the initial inventory file

![Activation Key](images/activation_key.png)

3. Validte the TF manifests in the terraform directory
  - main.tf
  - output.tf
  - user_data.txt

NOTE: you will need to put your ssh pub key in the user_data.txt file

NOTE: you will need to create an S3 bucket that is referenced in main.tf backend config ie. tfstate-bucket-blinker19

### Pull-Request Validation

4. Github actions performs terraform steps to validate PR, before it is eligible for merge to master.
  - terraform fmt
  - terraform init
  - terraform validate
  - terraform plan

### Post Infra AAP Install

5. Once the GitHub Actions Workflow completes - you can find the details to continue like shown below!  Ignoring any errors

![Terraform Output](images/tf_output.png)

NOTE: you can ssh to the instance as ec2-user and using the public IP from the output

  - validate expected results from user_data.txt
  - validate expected results from provisioner in main.tf
  - validate the ansible directory and inventory details

6. Install AAP 2.5 Containerized

nohup ansible-playbook -i inventory-growth ansible.containerized_installer.install -e ansible_connection=local & 2>/dev/null
```