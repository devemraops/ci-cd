resource "aws_vpc" "qa" {
  cidr_block = "10.0.0.0/16"

  # makes your instances shared on the host.data
  instance_tenancy = "default"

  # Required for qa. Enables/disable DNS support in the VPC.
  enable_dns_support = true

  # Required for qa. Enable/disable DNS hostnames in the VPC.
  enable_dns_hostnames = true

  tags = {
    Name = "qa"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.qa.id

  tags = {
    Name = "qa"
  }
}

resource "aws_subnet" "qa-public1" {
  vpc_id            = aws_vpc.qa.id
  cidr_block        = "10.0.101.0/24"
  availability_zone = "us-east-2a"
  # Required for qa. Intances launched into the subnet should be assigned public IP.
  #   map_public_ip_on_launch = true
  tags = {
    Name = "public-us-east-2a"
    #     # Required for qa 
    #     "kubernetes.io/cluster/prime-qa" = "shared" # it will allow qa cluster to discover this particular subnets
    #     "kubernetes.io/role/elb"          = 1        # it will allow qa to discover subnets and place in LB.
  }
}


resource "aws_subnet" "qa-public2" {
  vpc_id            = aws_vpc.qa.id
  cidr_block        = "10.0.102.0/24"
  availability_zone = "us-east-2b"
  # Required for qa. Intances launched into the subnet should be assigned public IP.
  #   map_public_ip_on_launch = true
  tags = {
    Name = "public-us-east-2b"
    # # Required for qa 
    # "kubernetes.io/cluster/prime-qa" = "shared" # it will allow qa cluster to discover this particular subnets
    # "kubernetes.io/role/elb"          = 1        # it will allow qa to discover subnets and place in LB.
  }
}

resource "aws_subnet" "qa-private1" {
  vpc_id            = aws_vpc.qa.id
  cidr_block        = "10.0.103.0/24"
  availability_zone = "us-east-2a"
  #   # Required for qa. Intances launched into the subnet should be assigned public IP.
  #   map_public_ip_on_launch = true
  tags = {
    Name = "private-us-east-2a"
    # Required for qa 
    # "kubernetes.io/cluster/prime-qa" = "shared" # it will allow qa cluster to discover this particular subnets
    # "kubernetes.io/role/internal-elb" = 1        # it will allow qa to discover subnets and place in LB.
  }
}

resource "aws_subnet" "qa-private2" {
  vpc_id            = aws_vpc.qa.id
  cidr_block        = "10.0.104.0/24"
  availability_zone = "us-east-2b"
  # Required for qa. Intances launched into the subnet should be assigned public IP.
  #   map_public_ip_on_launch = true
  tags = {
    Name = "private-us-east-2b"
    # # Required for qa 
    # "kubernetes.io/cluster/prime-qa" = "shared" # it will allow qa cluster to discover this particular subnets
    # "kubernetes.io/role/internal-elb" = 1        # it will allow qa to discover subnets and place in LB.
  }
}

resource "aws_subnet" "qa-private3" {
  vpc_id            = aws_vpc.qa.id
  cidr_block        = "10.0.105.0/24"
  availability_zone = "us-east-2c"
  # Required for qa. Intances launched into the subnet should be assigned public IP.
  #   map_public_ip_on_launch = true
  tags = {
    Name = "private-us-east-2c"
    # # Required for qa 
    # "kubernetes.io/cluster/prime-qa" = "shared" # it will allow qa cluster to discover this particular subnets
    # "kubernetes.io/role/internal-elb" = 1        # it will allow qa to discover subnets and place in LB.
  }
}

resource "aws_subnet" "qa-public3" {
  vpc_id            = aws_vpc.qa.id
  cidr_block        = "10.0.106.0/24"
  availability_zone = "us-east-2c"
  # Required for qa. Intances launched into the subnet should be assigned public IP.
  #   map_public_ip_on_launch = true
  tags = {
    Name = "public-us-east-2c"
    # # Required for qa 
    # "kubernetes.io/cluster/prime-qa" = "shared" # it will allow qa cluster to discover this particular subnets
    # "kubernetes.io/role/internal-elb" = 1        # it will allow qa to discover subnets and place in LB.
  }
}

# Route tables

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.qa.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public"
  }
}

resource "aws_route_table" "private1" {
  vpc_id = aws_vpc.qa.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-gate.id
  }

  tags = {
    Name = "private1"
  }
}

# route tables associations

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.qa-public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.qa-public2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.qa-private1.id
  route_table_id = aws_route_table.private1.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.qa-private2.id
  route_table_id = aws_route_table.private1.id
}

resource "aws_route_table_association" "public3" {
  subnet_id      = aws_subnet.qa-public3.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private3" {
  subnet_id      = aws_subnet.qa-private3.id
  route_table_id = aws_route_table.private1.id
}

resource "aws_eip" "nat-gate-eip" {
  # EIP may require IGW to exist prior to association.
  # Use depends_on to set an explicit dependency on the IGW.
  tags = {
    Name = "qa"
  }
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_nat_gateway" "nat-gate" {
  allocation_id = aws_eip.nat-gate-eip.id # for the gateway
  # The subnet ID of the subnet in which to place the gateway.connection 
    tags = {
    Name = "qa"
  }
  subnet_id = aws_subnet.qa-public1.id
}