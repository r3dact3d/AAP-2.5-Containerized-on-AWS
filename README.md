# Ansible Automation Platform 2.5 (Containerized)

## Terraform Infrastructure

### Summary

This project leverages Terraform to provision infrastructure and integrates GitHub Actions for streamlined automation. Key features include:

- A publicly accessible RHEL 9 EC2 instance running on AWS.
- AWS infrastructure and instance configuration automated with Terraform.
- GitHub Actions workflows for:
  - Automatically creating a Terraform plan on a pull request.
  - Applying infrastructure changes upon pull request merge.

> **Note:** Familiarize yourself with all resources in the `terraform` directory, particularly `main.tf`.

---

### Architecture Diagram

![Architecture Diagram](images/simple.png)

   > **Note:**  
   - The ec2 details are out of date, see `terraform` code in `main.tf`.  
---

### Implementation

#### Procedure

1. **Gather Requirements**
   - Clone the GitHub repository.

2. **Configure Repository Secrets**  
   Add the following secrets in the GitHub repository settings:  

   - `AWS_ACCESS_KEY`  
   - `AWS_SECRET_ACCESS_KEY`  
   - `ORG_ID` (Profile in [cluod.redhat.com](https://cloud.redhat.com))  
   - `ACTIVATION_KEY` (Created in **Inventory > System Configuration > Activation Keys** [console.redhat.com](https://console.redhat.com/insights/connector/activation-keys#SIDs=&tags=))  
   - `RHN_USER` (Red Hat Network username)  
   - `RHN_PASS` (Red Hat Network password)  
   - `AAP_PASS` (Default password for the initial inventory file)  

 
  ![Actions Secrets](images/github_secrets.png)  


3. **Validate Terraform Manifests**  
   Review and update files in the `terraform` directory as necessary:  
   - `main.tf`  
   - `output.tf`  
   - `user_data.txt`  

   > **Note:**  
   - Ensure your SSH public key is added to `user_data.txt`.  *This is the public key from your laptop or bastion server so you can ssh in for maintenance and run installer.*
   - Create an S3 bucket referenced in the backend configuration of `main.tf` (e.g., `tfstate-bucket-blinker19`).  *If you use a different name look and update the code.*
   - Review `remote-exec` custom code for specifics to configure ec2 instance in `main.tf`.
   - AAP Bundle referenced in `remote-exec` can be downloaded from [access.redhat.com/downloads](https://access.redhat.com/downloads/content/480/ver=2.5/rhel---9/2.5/x86_64/product-software) and placed in `post-data` directory. *Then, look and update the code to reflect updated version.*

![Custom remote-exec](images/remote-exec-img.png)

#### Pull Request Validation

4. **Automated Validation with GitHub Actions**  
   GitHub Actions will validate pull requests with the following Terraform steps before allowing a merge:  
   - `terraform fmt`  
   - `terraform init`  
   - `terraform validate`  
   - `terraform plan`  

   > **Note:**  
   - DO NOT MERGE until you are happy with the terraform plan if you update anything in `terraform` directory the GitHub Actions Workflow will kick off.
---

### Post-Infrastructure: Installing AAP 2.5

5. **Review Terraform Outputs**  
   After the GitHub Actions workflow completes, retrieve instance details from the output.  
   - Use the public IP to SSH into the instance (`ec2-user`).

   Validate:  
   - Expected results from `user_data.txt`.  
   - Expected results from the provisioner in `main.tf`.  
   - Contents of the `ansible` directory and inventory details.

   ![Terraform Output](images/tf_output.png)

6. **Install Ansible Automation Platform 2.5 (Containerized)**  

   From the machine with the corresponding SSH keys that were added to the `user_data.txt` :  

   ```bash
   ssh ec2-user@<public IP>

   cd ansible-automation-platform-containerized-setup-2.5-6

   nohup ansible-playbook -i inventory-growth ansible.containerized_installer.install -e ansible_connection=local &>/dev/null &
---

   > **Note:**  
   - Capture the PID of the ansible process started by nohup and run the `top` process to monitor the status.
   - Also, creates a log in the working directory for review, but top will keep the session from timing out.  
