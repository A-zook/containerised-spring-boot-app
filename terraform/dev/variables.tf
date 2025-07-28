variable "aws_region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {} # Your EC2 keypair name

variable "public_key_path" {} # Path to your public key

variable "app_port" {
  default = 8484
}

variable "docker_image" {
  description = "Docker image for the application"
  type        = string
  default     = "springboot-app"
}
