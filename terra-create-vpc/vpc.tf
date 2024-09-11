# 1. Create VPC
resource "aws_vpc" "custom_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "custom_vpc"
  }
}

# 2. Create Availability Zone
variable "vpc_az" {
  type        = list(string)
  description = "Availability Zones"
  default     = ["ap-southeast-1a", "ap-southeast-1b"]
}

# 3. Create Public subnets
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.custom_vpc.id
  count             = length(var.vpc_az)
  cidr_block        = cidrsubnet(aws_vpc.custom_vpc.cidr_block, 8, count.index + 1)
  availability_zone = element(var.vpc_az, count.index)
  tags = {
    Name = "public_subnet_${count.index + 1}"
  }
}

# 4. Create Private subnets
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.custom_vpc.id
  count             = length(var.vpc_az)
  cidr_block        = cidrsubnet(aws_vpc.custom_vpc.cidr_block, 8, count.index + 3)
  availability_zone = element(var.vpc_az, count.index)
  tags = {
    Name = "private_subnet_${count.index + 1}"
  }
}

# 5. Create Internet Gateway
resource "aws_internet_gateway" "igw_vpc" {
  vpc_id = aws_vpc.custom_vpc.id
  tags = {
    Name = "internet_gateway"
  }
}

# 6. Route table for the public subnet
resource "aws_route_table" "rt_public_subnet" {
  vpc_id = aws_vpc.custom_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_vpc.id
  }
  tags = {
    Name = "public_subnet_route_table"
  }
}

# 7. Association between RT and IG
resource "aws_route_table_association" "public_subnet_association" {
  route_table_id = aws_route_table.rt_public_subnet.id
  count          = length(var.vpc_az)
  subnet_id      = element(aws_subnet.public_subnet[*].id, count.index)
}

# 8. Elastic IP
resource "aws_eip" "eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw_vpc]
}

# 9. NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  subnet_id     = element(aws_subnet.private_subnet[*].id, 0)
  allocation_id = aws_eip.eip.id
  depends_on    = [aws_internet_gateway.igw_vpc]
  tags = {
    Name = "Nat Gateway"
  }
}

# 10. Route table for the private subnet
resource "aws_route_table" "rt_private_subnet" {
  vpc_id = aws_vpc.custom_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name = "private_subnet_route_table"
  }
}

# 11. RT association
resource "aws_route_table_association" "private_subnet_association" {
  route_table_id = aws_route_table.rt_private_subnet.id
  count          = length(var.vpc_az)
  subnet_id      = element(aws_subnet.private_subnet[*].id, count.index)
}