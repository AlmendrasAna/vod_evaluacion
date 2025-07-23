variable "aws_region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "key_name" {
  default = "id_rsa"
}


variable "public_key_path" {
  default = "~/.ssh/id_rsa.pub"
}

variable "my_ip" {
  description = "Tu IP pública con /32"
  type        = string
  sensitive   = true
}

variable "db_username" {
  description = "Usuario admin del RDS"
  type        = string
  default     = "devops_admin"
}

variable "db_password" {
  description = "Contraseña del RDS"
  type        = string
  sensitive   = true
}