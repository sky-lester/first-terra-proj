provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_instance" "test-instance" {
  ami           = "ami-01811d4912b4ccb26" # ubuntu ami
  instance_type = "t2.micro"
  tags = {
    Name = "EdgeInstance-terra"
  }
}