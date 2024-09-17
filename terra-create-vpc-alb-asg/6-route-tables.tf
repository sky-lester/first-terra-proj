
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