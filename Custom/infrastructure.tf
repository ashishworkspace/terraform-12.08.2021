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

variable "public_key_location" {}

variable "exec-script-location" {
  description = "Passing the exec bash file to run command inside the ec2 instance"  
}

variable "location-of-script-to-exec" {
  description = "Copy the script from local machine to aws."
}

variable "private_key_location" {
  description = "To login inside the EC2 instance we need private key"
  # in this case terraform will login inorder to run scripts
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

# fetching the ami information 

data "aws_ami" "getting-ami-id" {
  most_recent = true
  owners = ["amazon"]
  filter  {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# output "get_ami-id" {
#   value = data.aws_ami.getting-ami-id.id
# }

#ssh-key

resource "aws_key_pair" "public-key" {
  key_name = "awspasswd"
  public_key = "${file(var.public_key_location)}"
}

resource "aws_instance" "aws-ec2-instance" {
  ami = data.aws_ami.getting-ami-id.id
  
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subnet-variable-0.id
  availability_zone = var.cidr_block_range_subnets[0].region
  associate_public_ip_address = true
  count = 1
  vpc_security_group_ids = [aws_security_group.variable-sg.id]
  key_name = aws_key_pair.public-key.key_name
  tags ={
    "Name" = "terraform-instance"
  }
  
  # user_data will run only one time i.e. during launching of an instance
  # user_data = "${file(var.exec-script-location)}"
  


  # to provisioner a script we first need to connect to the remote machine



  # not recommended
  # provisioner is used to exec command remotely as well as locally. 
  # to exec any code in remote 
  # we need push the script first to the cloud than we can execute that script
  # provider has one more feature called file
  # i.e. used to push the script file from local to remote instance
  # connection {
  #     host = self.public_ip
  #     user = "ec2-user"
  #     type = "ssh"
  #     private_key = file(var.private_key_location)
  # }
  # provisioner "file" {
  #   source = "local.sh"
  #   destination = "/home/ec2-user/local.sh"
  # }

  # provisioner "remote-exec" {
  #   inline = [
  #     "sudo yum update -y"
  #   ]
    
  #   # script = file("local.sh")   # this will run the script on AWS
  # }
}