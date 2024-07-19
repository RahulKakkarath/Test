resource "aws_vpc" "my-vpc" {

    
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    tags = {
      name = "My-VPC"
    }
  
}

resource "aws_subnet" "pub-sn" {

    
    vpc_id = aws_vpc.my-vpc.id
    cidr_block = "10.0.0.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-1a"
    tags = {
      name = "Pub-SN-1"
    }
  
}

resource "aws_subnet" "pvt-sn" {
    
    vpc_id = aws_vpc.my-vpc.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = "false"
    availability_zone = "us-east-1a"
    tags = {
      name = "Pvt-SN"
    }

}

resource "aws_internet_gateway" "my-igw" {
    
    vpc_id = aws_vpc.my-vpc.id
    tags = {
      name = "My-IGW"
    }
  
}

resource "aws_route_table" "rt-pub" {
    
    vpc_id = aws_vpc.my-vpc.id
    route  {
        cidr_block = "0.0.0.0/0"
        gateway_id = awaws_internet_gateway.my-igw.id
    }
    tags = {
      name = "Pub-Rt"
    }
  
}

resource "aws_route_table_association" "pub" {
    subnet_id = aws_subnet.pub-sn.id
    route_table_id = aws_route_table.rt-pub.id
  
}

resource "aws_eip" "my-eip" {
    vpc = true
  
}

resource "aws_nat_gateway" "my-nat" {
    
    allocation_id = aws_eip.my-eip.id
    subnet_id = aws_subnet.pub-sn.id
    depends_on = [ aws_internet_gateway.my-igw ]
  
}

resource "aws_route_table" "rt-pvt" {
  
  vpc_id = aws_vpc.my-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.my-nat.id
  }
  tags = {
    name = "Rt-Pvt"
  }
}

resource "aws_route_table_association" "pvt" {
    subnet_id = aws_subnet.pvt-sn.id
    route_table_id = aws_route_table.rt-pvt.id
  
}
