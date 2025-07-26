# GitHub Secrets Configuration

## Required Secrets for CI/CD Pipeline

Add these secrets in your GitHub repository settings (Settings > Secrets and variables > Actions):

### Docker Hub Secrets
- `DOCKER_USERNAME` - Your Docker Hub username
- `DOCKER_PASSWORD` - Your Docker Hub password or access token

### AWS EC2 Secrets
- `EC2_HOST` - Public IP address of your EC2 instance (from Terraform output)
- `EC2_PRIVATE_KEY` - Private SSH key content (corresponding to the public key in terraform.tfvars)

### AWS Credentials (for Terraform)
- `AWS_ACCESS_KEY_ID` - Your AWS access key
- `AWS_SECRET_ACCESS_KEY` - Your AWS secret key

## Setup Steps

1. **Generate SSH Key Pair:**
   ```bash
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/aws-key
   ```

2. **Update terraform.tfvars:**
   ```hcl
   public_key_path = "~/.ssh/aws-key.pub"
   ```

3. **Deploy Infrastructure:**
   ```bash
   cd terraform/dev
   terraform init
   terraform plan
   terraform apply
   ```

4. **Add EC2_HOST secret:**
   - Copy the `instance_public_ip` from Terraform output
   - Add as `EC2_HOST` secret in GitHub

5. **Add EC2_PRIVATE_KEY secret:**
   - Copy content of `~/.ssh/aws-key` (private key)
   - Add as `EC2_PRIVATE_KEY` secret in GitHub