# Flux7
## Trial Project

## Summary

- Linux EC2 instance is running on AWS and is publicly accessible.
- Instance is configured with an Terraform script.
- The playbook installs a PHP web server and a landing page that says "Welcome to Flux7!"
- The playbook code is stored in a publicly accessible Git repository.
- Submit your repo link the day before the interview/meeting

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
4. Access landing page http://<public_ip>/flux7.php
5. Tear down procedure
  `terraform destroy -auto-approve`
