#CREATE INSTANCES IN PUBLIC AND PRIVATE SUBNETS
#CREATE BASTION HOST TO ACCESS IN INNER NETWORK
resource "aws_instance" "terra-bastion" {
  count                  = 1
  ami                    = "ami-087855b6c8b59a9e4"
  instance_type          = "t2.micro"
  key_name               = "terra-key"
  vpc_security_group_ids = [aws_security_group.terra-bastion-access.id]
  subnet_id              = "${aws_subnet.terra-subnet-public.id}"
  tags = {
    Name = "terraform-bastion"
  }
}

#CREATE APP SERVER
resource "aws_instance" "terra-app" {
  count                  = 1
  ami                    = "ami-087855b6c8b59a9e4"
  instance_type          = "t2.micro"
  key_name               = "terra-key"
  vpc_security_group_ids = [aws_security_group.terra-private-access.id]
  subnet_id              = "${aws_subnet.terra-subnet-private.id}"
  tags = {
    Name = "terraform-app-server"
  }
}

#CREATE DATABASE SERVER
resource "aws_instance" "terra-db" {
  count                  = 1
  ami                    = "ami-087855b6c8b59a9e4"
  instance_type          = "t2.micro"
  key_name               = "terra-key"
  vpc_security_group_ids = [aws_security_group.terra-private-access.id]
  subnet_id              = "${aws_subnet.terra-subnet-db.id}"
  tags = {
    Name = "terraform-db-server"
  }
}
#TEST PASSED
#SOME NEW CODE1
#SOME NEW CODE
#DEV FIX
