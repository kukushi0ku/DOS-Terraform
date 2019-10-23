#CREATE VPC
resource "aws_vpc" "terra-vpc" {
  cidr_block       = "10.80.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "terra-vpc"
  }
}

#CREATE SUBNETS
resource "aws_subnet" "terra-subnet-public" {
  vpc_id                  = "${aws_vpc.terra-vpc.id}"
  cidr_block              = "10.80.1.0/24"
  availability_zone       = "eu-west-3c"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "terra-subnet-public"
  }
}
resource "aws_subnet" "terra-subnet-private" {
  vpc_id                  = "${aws_vpc.terra-vpc.id}"
  cidr_block              = "10.80.2.0/24"
  availability_zone       = "eu-west-3c"
  map_public_ip_on_launch = "false"
  tags = {
    Name = "terra-subnet-private"
  }
}
resource "aws_subnet" "terra-subnet-db" {
  vpc_id                  = "${aws_vpc.terra-vpc.id}"
  cidr_block              = "10.80.3.0/24"
  availability_zone       = "eu-west-3c"
  map_public_ip_on_launch = "false"
  tags = {
    Name = "terra-subnet-db"
  }
}

#ELASTIC IP ALLOCATION
resource "aws_eip" "terra-eip-nat" {
  tags = {
    Name = "terra-eip-nat"
  }
}

#CREATE GATEWAYS
resource "aws_internet_gateway" "terra-igw" {
  vpc_id = "${aws_vpc.terra-vpc.id}"
  tags = {
    Name = "terra-igw"
  }
}
resource "aws_nat_gateway" "terra-nat" {
  allocation_id = "${aws_eip.terra-eip-nat.id}"
  subnet_id     = "${aws_subnet.terra-subnet-public.id}"
  depends_on    = ["aws_internet_gateway.terra-igw"]
  tags = {
    Name = "terra-nat"
  }
}

#CREATE ROUTING
resource "aws_route_table" "terra-routetb-public" {
  vpc_id = "${aws_vpc.terra-vpc.id}"
  tags = {
    Name = "terra-public-route-table"
  }
}
resource "aws_route_table" "terra-routetb-private" {
  vpc_id = "${aws_vpc.terra-vpc.id}"
  tags = {
    Name = "terra-private-route-table"
  }
}
resource "aws_route_table" "terra-routetb-db" {
  vpc_id = "${aws_vpc.terra-vpc.id}"
  tags = {
    Name = "terra-database-route-table"
  }
}
resource "aws_route" "terra-public-route" {
  route_table_id         = "${aws_route_table.terra-routetb-public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.terra-igw.id}"
}
resource "aws_route" "terra-private-route" {
  route_table_id         = "${aws_route_table.terra-routetb-private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.terra-nat.id}"
}
resource "aws_route_table_association" "public-subnet-association" {
  subnet_id      = "${aws_subnet.terra-subnet-public.id}"
  route_table_id = "${aws_route_table.terra-routetb-public.id}"
}
resource "aws_route_table_association" "private-subnet-association" {
  subnet_id      = "${aws_subnet.terra-subnet-private.id}"
  route_table_id = "${aws_route_table.terra-routetb-private.id}"
}
resource "aws_route_table_association" "db-subnet-association" {
  subnet_id      = "${aws_subnet.terra-subnet-db.id}"
  route_table_id = "${aws_route_table.terra-routetb-db.id}"
}
resource "aws_main_route_table_association" "set-main-routetb" {
  vpc_id         = "${aws_vpc.terra-vpc.id}"
  route_table_id = "${aws_route_table.terra-routetb-public.id}"
}
