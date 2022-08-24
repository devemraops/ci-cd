data "aws_eip" "nat-gate-eip" {
  tags = {
    Name = "qa"
  }
}

data "aws_nat_gateway" "nat-gate" {
  tags = {
    Name = "qa"
  }
}

