# Spring Boot Application with CI/CD

A containerized Spring Boot application with automated deployment to AWS EC2 using GitHub Actions and Terraform.

## 🚀 Features

- Spring Boot REST API
- Docker containerization
- Terraform infrastructure as code
- GitHub Actions CI/CD pipeline
- AWS EC2 deployment

## 📋 Prerequisites

- Java 17
- Docker
- AWS Account
- GitHub Account
- Terraform

## 🏗️ Architecture

- **Application**: Spring Boot running on port 8484
- **Infrastructure**: AWS EC2 t2.micro with Amazon Linux 2
- **CI/CD**: GitHub Actions for build and deployment
- **Container Registry**: Docker Hub

## 🛠️ Local Development

```bash
# Build and run locally
java -jar target/springboot-demo-0.0.1-SNAPSHOT.jar --server.port=8484

# Build Docker image
docker build -t springboot-app .

# Run container
docker run -p 8484:8484 springboot-app
```

## 🌐 API Endpoints

- `GET /hello` - Returns greeting message
- `GET /status` - Returns server status (staging only)
- Application runs on port 8484

## 🔧 Deployment

1. **Set GitHub Secrets**:
   - `DOCKER_USERNAME` - Docker Hub username
   - `DOCKER_PASSWORD` - Docker Hub password
   - `EC2_HOST` - EC2 public IP
   - `EC2_PRIVATE_KEY` - SSH private key
   - `AWS_ACCESS_KEY_ID` - AWS access key
   - `AWS_SECRET_ACCESS_KEY` - AWS secret key

2. **Deploy Infrastructure**:
   ```bash
   cd terraform/dev
   terraform init
   terraform apply
   ```

3. **Push to GitHub** - Triggers automatic deployment

## 📁 Project Structure

```
├── src/main/java/com/example/demo/
│   ├── DemoApplication.java
│   └── controller/HelloController.java
├── terraform/dev/
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars
├── .github/workflows/deploy.yml
├── Dockerfile
└── pom.xml
```

## 🔒 Security

- SSH keys are not committed to repository
- Terraform state contains sensitive information
- Use GitHub Secrets for credentials