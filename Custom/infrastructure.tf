provider "aws"{
    region = "ap-south-1"
}

variable "cidr_block_range_vpc"{
    default = "192.168.0.0/16"
    description = "Assigning some default VPC Cidr value"
    type = string
}

variable "cidr_block_range_subnets" {
  description = "Assigning the names, AG and cidr value for each subnets using List(object) model"
  type = list(object({cidr_block = string, name = string, region = string}))
}

variable "Internet-gateway-terraform" {
  description = "Created this variable to associate the name for Internet Gateway."
  default = "terraform-igw"
}


variable "ipv4-local-ingress" {}
resource "aws_vpc" "vpc-variable"{
    cidr_block = var.cidr_block_range_vpc
    tags = {
      Name = "VPC-terraform"
    }
    enable_dns_hostnames = true
    enable_dns_support = true
    
}

resource "aws_subnet" "subnet-variable-0" {
    vpc_id = aws_vpc.vpc-variable.id
    cidr_block = var.cidr_block_range_subnets[0].cidr_block
    tags = {
      Name = var.cidr_block_range_subnets[0].name
    }
    availability_zone = var.cidr_block_range_subnets[0].region
}

resource "aws_subnet" "subnet-variable-1" {
    vpc_id = aws_vpc.vpc-variable.id
    cidr_block = var.cidr_block_range_subnets[1].cidr_block
    tags = {
      Name = var.cidr_block_range_subnets[1].name
    }
  availability_zone = var.cidr_block_range_subnets[1].region
}
resource "aws_subnet" "subnet-variable-2" {
    vpc_id = aws_vpc.vpc-variable.id
    cidr_block = var.cidr_block_range_subnets[2].cidr_block
    tags = {
      Name = var.cidr_block_range_subnets[2].name
    }
  availability_zone = var.cidr_block_range_subnets[2].region
 
}

# Creating Internet Gateway

resource "aws_internet_gateway" "variable-internet-gateway" {
  vpc_id = aws_vpc.vpc-variable.id
  tags = {
    "Name" = "${var.Internet-gateway-terraform}"
  }
}



# output "aws_interne" {
#   value = aws_internet_gateway.variable-internet-gateway.id
# }

# attaching routing policy in vpc

resource "aws_route_table" "routing-table-terraform" {
  vpc_id = aws_vpc.vpc-variable.id
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.variable-internet-gateway.id
    }
  tags = {
    "Name" = "terraform-routing-policy"
  }
}


# now adding new routing policy to subnet

resource "aws_route_table_association" "internet-gateway-subnet" {
  # assigning new routeing policy to subnet in order to allow Internet Gateway.
  subnet_id = aws_subnet.subnet-variable-0.id
  route_table_id = aws_route_table.routing-table-terraform.id
}



# creating security group

resource "aws_security_group" "variable-sg" {
 vpc_id = aws_vpc.vpc-variable.id
 name = "Security-Group-terraform"
ingress   {
  cidr_blocks = [ var.ipv4-local-ingress ]
  description = "This is the local IP for configuring SG"
  from_port = 22
  to_port = 22
  protocol = "tcp"
} 
ingress  {
  cidr_blocks = [ "0.0.0.0/0" ]
  from_port = 8080
  to_port = 8080
  protocol = "tcp"
} 
 egress  {
   cidr_blocks = [ "0.0.0.0/0" ]
   description = "Every IP will be send outside"
   from_port = 0 
   prefix_list_ids = [  ]
   protocol = "-1"
   to_port = 0
 } 
 tags = {
   "Name" = "sg-terraform"
 }
}