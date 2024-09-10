provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_instance" "test-instance" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  tags = {
    Name = "EdgeInstance-terra"
  }
}