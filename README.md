# Terraform & Ansible
## Trial Project

## Summary

- RHEL EC2 instance is running on AWS and is publicly accessible.
- AWS infra and instance is configured with an Terraform.
- GitHub Actions workflow with automatically create a Plan on a Pull Request
- GitHub Actions workflow will automatically apply infra changes on a Pull Request Merge


## Architecture Diagram

![Architecture Diagram](images/simple.png)

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


### Pull-Request Validation

- Github actions performs terraform steps to validate PR, before it is eligible for merge to master.
  - terraform fmt
  - terraform init
  - terraform validate
  - terraform plan

### Post Infra AAP Install

1. Copy installer files to new ec2 instance
scp ansible-platform-containerized-setup-2.5-3.tar.gz ec2-user@pubIP:/home/ec2-user/

2. Login to ec2 instance - todo with user-data
sudo hostnamectl <HOSTNAME>
sudo echo "127.0.0.2    <HOSTNAME> localhost" >> /etc/hosts
sudo subscription-manager register
sudo dnf repolist
sudo dnf config-manager --disable rhui-client-config-server-9
sudo dnf install -y ansible-core
sudo dnf install -y wget git-core rsync vim
sed -i 's/default-passwords/new-install-password/g' inventory-growth 
sed -i 's/aap.example.org/New-fqdn-FOR-GATEWAY/g' inventory-growth 
ansible-playbook -i inventory-growth ansible.containerized_installer.install -e ansible_connection=local
