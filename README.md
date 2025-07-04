# AWS Infrastructure with Terraform

This Terraform configuration creates a complete AWS VPC infrastructure with public and private subnets, bastion host, and NAT instance.

## Architecture Overview

### Network Components
- **VPC**: 10.0.0.0/16 CIDR block
- **Public Subnets**: 
  - public-subnet-1: 10.0.1.0/24 (eu-west-1a)
  - public-subnet-2: 10.0.2.0/24 (eu-west-1b)
- **Private Subnets**:
  - private-subnet-1: 10.0.3.0/24 (eu-west-1a)
  - private-subnet-2: 10.0.4.0/24 (eu-west-1b)
- **Internet Gateway**: Provides internet access to public subnets
- **NAT Instance**: Cost-effective solution for outbound internet access for private subnets

### Security Components
- **Bastion Security Group**: Allows SSH (port 22) from anywhere
- **Private Security Group**: Allows SSH only from bastion host

### Compute Resources
- **NAT Gateway**: Managed AWS service in public subnet for outbound internet access
- **Bastion Host**: Ubuntu 24.04 LTS t2.nano in public subnet
- **k3s Master**: Ubuntu 24.04 LTS t2.small in private subnet (Kubernetes control plane)

## Deployment

### Prerequisites
- AWS CLI configured with appropriate credentials
- Terraform installed (version 1.0+)

### Steps
1. Clone the repository
2. Initialize Terraform:
   ```bash
   terraform init
   ```
3. Plan the deployment:
   ```bash
   terraform plan
   ```
4. Apply the configuration:
   ```bash
   terraform apply
   ```

## Usage

### SSH Key Generation
Terraform automatically generates an SSH key pair:
- Extract private key: `terraform output -raw ssh_private_key > terraform-key.pem`
- Set permissions: `icacls terraform-key.pem /inheritance:r /remove "BUILTIN\Users" /grant:r "YourUsername:R"`
- Public key uploaded to AWS as "terraform-key"

### Accessing k3s Master
1. SSH to the bastion host using its public IP:
   ```bash
   ssh -i terraform-key.pem ubuntu@<bastion-public-ip>
   ```

2. Copy the private key and k3s-workload to bastion host:
   ```bash
   scp -i terraform-key.pem terraform-key.pem ubuntu@<bastion-public-ip>:~/
   scp -i terraform-key.pem k3s-workload.yaml ubuntu@<bastion-public-ip>:~/
   ```

3. From the bastion host, SSH to k3s master:
   ```bash
   ssh -i terraform-key.pem ubuntu@<k3s-master-ip>
   ```

### SSH Key Management
- The `terraform-key.pem` file is automatically created in your project directory
- Keep this file secure and don't commit it to version control
- Use SSH agent forwarding for seamless access

## k3s Kubernetes Cluster

### Cluster Access
1. SSH to bastion host:
   ```bash
   ssh -i terraform-key.pem ubuntu@<bastion-public-ip>
   ```

2. From bastion, access k3s master:
   ```bash
   ssh -i terraform-key.pem ubuntu@<k3s-master-ip>
   ```

3. Check cluster status:
   ```bash
   sudo k3s kubectl get nodes
   sudo k3s kubectl get pods -A
   ```

### Deploy Sample Workload
1. Copy the workload file from local machine to bastion host:
   ```bash
   scp -i terraform-key.pem terraform-key.pem ubuntu@<bastion-public-ip>:~/
   scp -i terraform-key.pem k3s-workload.yaml ubuntu@<bastion-public-ip>:~/
   ```

2. SSH to bastion host and copy to k3s master:
   ```bash
   ssh -i terraform-key.pem ubuntu@<bastion-public-ip>
   scp -i terraform-key.pem k3s-workload.yaml ubuntu@<k3s-master-ip>:~/
   ```

3. Set proper permissions on the key:
   ```bash
   chmod 600 terraform-key.pem
   ```

4. SSH to k3s master and deploy:
   ```bash
   ssh -i terraform-key.pem ubuntu@<k3s-master-ip>
   sudo k3s kubectl apply -f k3s-workload.yaml
   ```

5. Verify deployment:
   ```bash
   sudo k3s kubectl get deployments
   sudo k3s kubectl get pods
   sudo k3s kubectl get services
   ```

### k3s Installation
- k3s is automatically installed during instance boot via user-data
- Uses t2.small instance type (2GB RAM) for proper k3s operation
- Accessible only through bastion host for security

### k3s Cluster Features
- **Single Node**: Runs k3s server with API server, scheduler, and controller
- **Automatic Setup**: k3s is installed automatically via user-data
- **Private Network**: Cluster runs in private subnet with NAT internet access
- **Secure Access**: Only accessible through bastion host

## Cost Optimization

### Current Setup
- Uses NAT Gateway (~$45/month plus data processing charges)
- Fully managed service with high availability
- No maintenance required

### NAT Gateway Benefits
- Automatic scaling to handle traffic spikes
- Managed by AWS with high availability
- No maintenance or configuration required

## Security Best Practices
- Bastion host only allows SSH access
- Private instances only accept connections from bastion
- All outbound traffic allowed for updates and package installation
- Consider implementing additional security measures for production use

## Cleanup
To destroy the infrastructure:
```bash
terraform destroy
```

## CI/CD Pipeline

### GitHub Actions Workflow
The project includes automated CI/CD pipeline with:
- **Terraform Format Check**: Validates code formatting
- **Terraform Plan**: Shows planned changes on PRs
- **Terraform Apply**: Automatically applies changes on main branch

### OIDC Authentication
- Uses GitHub Actions OIDC provider for secure AWS authentication
- No long-lived AWS credentials stored in GitHub
- IAM role `TerraformRole` with necessary permissions

### Workflow Triggers
- Format check runs on all pushes to `task_1` branch
- Plan runs on pull requests and main branch pushes
- Apply runs only on main branch pushes

## State Management

### S3 Backend
- Terraform state stored in S3 bucket `rs-terraform-c`
- Versioning enabled for state file history
- Server-side encryption with AES256
- Remote state allows team collaboration

## Files Structure
- `vpc.tf` - VPC, subnets, gateways, and routing
- `instance.tf` - EC2 instances and security groups
- `iam.tf` - IAM roles and policies
- `oidc.tf` - OIDC provider configuration
- `s3-bucket.tf` - S3 bucket for Terraform state
- `key-pair.tf` - SSH key pair generation
- `provider.tf` - AWS provider configuration
- `terraform.tf` - Backend configuration
- `.github/workflows/terraform.yml` - CI/CD pipeline
