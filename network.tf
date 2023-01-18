resource "aws_vpc" "dev-vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "${var.server_name}-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.dev-vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "${var.server_name}-subnet"
  }
}

resource "aws_network_interface" "server_nic" {
  subnet_id   = aws_subnet.public_subnet.id
  private_ips = ["172.16.10.100"]

  tags = {
    Name = "primary_network_interface"
  }
}
resource "aws_eip" "lb" {
  count = var.count_num
  instance    = aws_instance.web[count.index].id
  vpc         = true
  depends_on  = [aws_internet_gateway.gw]
  tags = {
    "Name" = "eip${count.index}"
  }

}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.dev-vpc.id
}
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.dev-vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

  }
  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

  }   
    ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = {
    Name = "allow_tls"
  }
}
resource "aws_route_table" "server_rt" {
  vpc_id = aws_vpc.dev-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "route-table"
  }
}
resource "aws_route_table_association" "server_rt_associate" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.server_rt.id
}