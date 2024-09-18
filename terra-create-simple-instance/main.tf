provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_security_group" "terra_sg" {
  name        = "terra_sg"
  description = "Terraform Security group for EC2 Instances"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terra-sg"
  }
}

resource "aws_instance" "test_instance" {
  ami             = "ami-01811d4912b4ccb26" # ubuntu ami
  instance_type   = "t2.micro"
  key_name        = "llr-keypair"
  depends_on      = [aws_security_group.terra_sg]
  vpc_security_group_ids = [aws_security_group.terra_sg.id]
  # security_groups = [aws_security_group.terra_sg.name]
  tags = {
    Name = "terra-instance"
  }
}

