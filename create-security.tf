#MY IP ADDRESS LOCATION
data "http" "my-ipaddress" {
  url = "http://ipv4.icanhazip.com"
}

#CREATE SECURITY GROUPS WITH RULES
resource "aws_security_group" "terra-bastion-access" {
  name        = "terra-bastion-access"
  description = "Allow access to bastion host"
  vpc_id      = "${aws_vpc.terra-vpc.id}"
  tags = {
    Name = "terra-bastion-access"
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my-ipaddress.body)}/32"]
    description = "Allow SSH connection to bastion host"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "terra-private-access" {
  name        = "terra-private-access"
  description = "Allow access to to private network hosts"
  vpc_id      = "${aws_vpc.terra-vpc.id}"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "terra-private-access"
  }
}
resource "aws_security_group_rule" "terra-private-access-ingress" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.terra-private-access.id}"
  source_security_group_id = "${aws_security_group.terra-bastion-access.id}"
}

#CREATE KEY PAIR
resource "aws_key_pair" "terra-key" {
  key_name   = "terra-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCY+aNIFY4crzYD5u55xzimEBvnIhYhg8HjpO6OudHyyNN9jRIc8JyzhnW/y/BjqORRIi8PzpLDhWHDCYP4KNekgNu630mEcG3ov/tLVzEuByzssKCvL8mCXt9bmTZz6Xb8sHUZEF4FraFCjN09O8sadOXRwanyt1/o+sG5kAhr3QaPu784De1k7mwy3tzaVL7xZvUVPeffublOI2IwVHDs9J4SXTCQa/zAnJIQFmS838Y6qzxByxrE31AmkmOpon/ubDC3nYtgoUemsX+5XjGwD6O2XfN6w3r8QQ+xqMrJKMSnER1FVcG9jBEe4bB8srmISCs0Y2alu/GxQiNvZJfP kukushioku@DESKTOP-85ERL4C"
}
