provider "aws" {
  region = var.aws_region
}

data "aws_vpc" "default" {
  default = true
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "random_id" "sufijo" {
  byte_length = 4
}

resource "aws_key_pair" "default" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_security_group" "devops_sg" {
  name        = "devops-sg"
  description = "Permitir SSH y HTTP y PostgreSQL"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    description = "PostgreSQL"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "devops" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.default.key_name
  vpc_security_group_ids      = [aws_security_group.devops_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "ec2-vod-devops"
  }
}

# S3 bucket
resource "aws_s3_bucket" "mi_bucket" {
  bucket        = "mi-bucket-vod-${random_id.sufijo.hex}"
  force_destroy = true
  tags = {
    Name = "s3-vod"
  }
}

# RDS (PostgreSQL)
resource "aws_db_instance" "mi_rds" {
  identifier              = "rds-vod-${random_id.sufijo.hex}"
  allocated_storage       = 20
  engine                  = "postgres"
  engine_version          = "17.5"
  instance_class          = "db.t4g.micro"
  username                = var.db_username
  password                = var.db_password
  db_name                 = "demodb"
  publicly_accessible     = true
  skip_final_snapshot     = true
  vpc_security_group_ids  = [aws_security_group.devops_sg.id]
  tags = {
    Name = "rds-vod"
  }
}

resource "local_file" "info_aws_demo" {
  filename = "${path.module}/info_aws_demo.txt"
  content  = <<EOT
S3 bucket: ${aws_s3_bucket.mi_bucket.bucket}
RDS endpoint: ${aws_db_instance.mi_rds.address}
Usuario RDS: ${var.db_username}
Base de datos: demodb
EOT
}