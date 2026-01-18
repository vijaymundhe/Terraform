provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "my_vpc" {
    cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "my_public_subnet" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true
    availability_zone = "us-east-1a"
}

resource "aws_subnet" "my_private_subnet" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1a"
}

resource "aws_internet_gateway" "my_IGW" {
    vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route_table" "my_rt" {
    vpc_id = aws_vpc.my_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_IGW.id
    }
}

resource "aws_route_table_association" "my_rta" {
    subnet_id = aws_subnet.my_public_subnet.id
    route_table_id = aws_route_table.my_rt.id
}

resource "aws_instance" "name" {
    ami = var.ami
    instance_type = var.instance_type
    subnet_id = aws_subnet.my_public_subnet.id
    security_groups = [aws_security_group.my_sg.id]
    tags = locals.common_tags
}

resource "aws_security_group" "my_sg" {
    vpc_id = aws_vpc.my_vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "my_sg1" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
