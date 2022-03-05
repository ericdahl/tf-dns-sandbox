resource "aws_eip" "nat_gw" {
  vpc        = true
  depends_on = [aws_internet_gateway.default]
}

resource "aws_nat_gateway" "default" {
  allocation_id = aws_eip.nat_gw.id
  subnet_id = aws_subnet.public["us-east-1a"].id
}