# SSH Key Setup

## 1. Generate SSH Key Pair:
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/aws-springboot-key
```

## 2. Update terraform.tfvars:
```hcl
key_name        = "springboot-key"
public_key_path = "~/.ssh/aws-springboot-key.pub"
```

## 3. Deploy Infrastructure:
```bash
terraform init
terraform plan
terraform apply
```

## 4. Get Outputs:
```bash
terraform output instance_public_ip
terraform output application_url
```

## 5. GitHub Secrets:
- `EC2_HOST` = Output from `terraform output instance_public_ip`
- `EC2_PRIVATE_KEY` = Content of `~/.ssh/aws-springboot-key` (private key file)