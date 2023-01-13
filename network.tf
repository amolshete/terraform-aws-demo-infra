
# creating VPC for webapp creator : amol
resource "aws_vpc" "webapp-vpc" {
  cidr_block = "10.10.0.0/16"

  tags = {
    Name = "Webapp-VPC"
  }
}

resource "aws_subnet" "mysubnet-1a" {
  vpc_id     = aws_vpc.webapp-vpc.id
  cidr_block = "10.10.0.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "Mysubnet-1a"
  }
}


resource "aws_subnet" "mysubnet-1b" {
  vpc_id     = aws_vpc.webapp-vpc.id
  cidr_block = "10.10.1.0/24"
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "Mysubnet-1b"
  }
}


resource "aws_subnet" "mysubnet-1c" {
  vpc_id     = aws_vpc.webapp-vpc.id
  cidr_block = "10.10.2.0/24"
  availability_zone = "ap-south-1c"

  tags = {
    Name = "Mysubnet-1c"
  }
}

resource "aws_security_group" "allow_80" {
  name        = "allow_port-80"
  description = "Allow http inbound traffic"
  vpc_id      = aws_vpc.webapp-vpc.id

  ingress {
    description      = "http traffic"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_http"
  }
}


resource "aws_security_group" "allow_22" {
  name        = "allow_port-22"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.webapp-vpc.id

  ingress {
    description      = "ssh traffic"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

# creating the IG for VPC

resource "aws_internet_gateway" "webapp-VPC-IG" {
  vpc_id = aws_vpc.webapp-vpc.id

  tags = {
    Name = "webapp-VPC-IG"
  }
}




resource "aws_route_table" "webapp-public-RT" {
  
  vpc_id = aws_vpc.webapp-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.webapp-VPC-IG.id
  }
  tags = {
    Name = "webapp-public-RT"
  }
}

resource "aws_route_table_association" "webapp-public-RT-association-subnet-1a" {
  subnet_id      = aws_subnet.mysubnet-1a.id
  route_table_id = aws_route_table.webapp-public-RT.id
}


resource "aws_route_table_association" "webapp-public-RT-association-subnet-1b" {
  subnet_id      = aws_subnet.mysubnet-1b.id
  route_table_id = aws_route_table.webapp-public-RT.id
}