# GitHub Repository Setup

## 1. Create GitHub Repository

1. Go to https://github.com/new
2. Repository name: `springboot-aws-deployment`
3. Description: `Spring Boot application with AWS EC2 deployment`
4. Set to Public or Private
5. **DO NOT** initialize with README (we already have one)
6. Click "Create repository"

## 2. Add Remote and Push

```bash
# Add GitHub remote (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/springboot-aws-deployment.git

# Push to GitHub
git branch -M main
git push -u origin main
```

## 3. Add GitHub Secrets

Go to your repository → Settings → Secrets and variables → Actions

Add these secrets:

### Docker Hub
- `DOCKER_USERNAME` = your-dockerhub-username
- `DOCKER_PASSWORD` = your-dockerhub-password

### AWS EC2
- `EC2_HOST` = `50.17.33.176`
- `EC2_PRIVATE_KEY` = (paste the private key content from earlier)

### AWS Credentials
- `AWS_ACCESS_KEY_ID` = your-aws-access-key
- `AWS_SECRET_ACCESS_KEY` = your-aws-secret-key

## 4. Test Deployment

After pushing, the GitHub Actions workflow will automatically:
1. Build the Spring Boot application
2. Create Docker image
3. Push to Docker Hub
4. Deploy to EC2 instance

Check the Actions tab to monitor deployment progress.