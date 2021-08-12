provider "aws"{}

# variable "subnet-cidr-block-1a"{
#     description = "Adding Subnet CIDR using variable."
#     default = "" # this default value of variable will work if you don't pass anything with command line
#     # or if you don't pass the value of the variable from .tfvars file

# }

# creating a variable of definite type
variable "variable-subnets"{
    description = "List with Objects used to create multiple subnet with CIDR and Name."
    type = list(object({
        cidr_block = string
        name = string
    }))
}



resource "aws_vpc" "development-VPC" {
  cidr_block = "192.168.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
      Name = "development-VPC"
  }
}



resource "aws_subnet" "subnet1A-development-VPC" {
    vpc_id = aws_vpc.development-VPC.id
    cidr_block = var.variable-subnets[0].cidr_block
    availability_zone = "ap-south-1a"
    tags={
        Name = var.variable-subnets[0].name
    }
}

resource "aws_subnet" "subnet1B-development-VPC" {
    vpc_id = aws_vpc.development-VPC.id
    cidr_block = var.variable-subnets[1].cidr_block
    availability_zone = "ap-south-1b"
    tags={
        Name = var.variable-subnets[1].name
    }
}

data "aws_vpc" "query_vpc"{
    id = aws_vpc.development-VPC.id
}

resource "aws_subnet" "subnet1C-development-VPC" {
    vpc_id = data.aws_vpc.query_vpc.id
    cidr_block = var.variable-subnets[2].cidr_block
    availability_zone = "ap-south-1c"
    tags={
        Name = var.variable-subnets[2].name
    }
}

# printing the output value

output "printing-VPC-id" {
  value = aws_vpc.development-VPC.id
}

output "printing-subnets-id" {
  value = aws_subnet.subnet1A-development-VPC.id
}

