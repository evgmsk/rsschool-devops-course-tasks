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
- **NAT Instance**: Ubuntu 24.04 LTS t2.nano in public subnet (configured for NAT)
- **Bastion Host**: Ubuntu 24.04 LTS t2.nano in public subnet
- **Private Instance**: Ubuntu 24.04 LTS t2.nano in private subnet

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
- Private key saved as `terraform-key.pem` in your project directory
- Public key uploaded to AWS as "terraform-key"

### Accessing Private Instances
1. SSH to the bastion host using its public IP:
   ```bash
   ssh -i terraform-key.pem ubuntu@<bastion-public-ip>
   ```

2. Copy the private key to bastion host:
   ```bash
   scp -i terraform-key.pem terraform-key.pem ubuntu@<bastion-public-ip>:~/
   ```

3. From the bastion host, SSH to private instances:
   ```bash
   ssh -i terraform-key.pem ubuntu@<private-instance-ip>
   ```

### SSH Key Management
- The `terraform-key.pem` file is automatically created in your project directory
- Keep this file secure and don't commit it to version control
- Use SSH agent forwarding for seamless access

## Cost Optimization

### Current Setup (Cost-Effective)
- Uses NAT Instance (~$5/month for t2.nano)
- Requires manual configuration but significant cost savings
- Estimated savings: ~$40/month compared to NAT Gateway

### NAT Instance Configuration
The NAT instance is automatically configured with:
- IP forwarding enabled
- iptables rules for NAT functionality
- Source/destination check disabled

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

## Files Structure
- `vpc.tf` - VPC, subnets, gateways, and routing
- `instance.tf` - EC2 instances and security groups
- `iam.tf` - IAM roles and policies
- `oidc.tf` - OIDC provider configuration
- `provider.tf` - AWS provider configuration
- `terraform.tf` - Backend configuration