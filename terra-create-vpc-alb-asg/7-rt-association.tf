# 7. Association between RT and IG
resource "aws_route_table_association" "public_subnet_association" {
  route_table_id = aws_route_table.rt_public_subnet.id
  count          = length(var.vpc_az)
  subnet_id      = element(aws_subnet.public_subnet[*].id, count.index)
}

# 11. RT association
resource "aws_route_table_association" "private_subnet_association" {
  route_table_id = aws_route_table.rt_private_subnet.id
  count          = length(var.vpc_az)
  subnet_id      = element(aws_subnet.private_subnet[*].id, count.index)
}