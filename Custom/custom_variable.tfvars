cidr_block_range_subnets = [
    {cidr_block = "192.168.1.0/24", name = "terraform-subnet-1A", region="ap-south-1a"},
    {cidr_block = "192.168.2.0/24", name = "terraform-subnet-1B", region="ap-south-1b"},
    {cidr_block = "192.168.3.0/24", name = "terraform-subnet-1C", region="ap-south-1c"}
]

ipv4-local-ingress = "49.37.77.158/32"
public_key_location = "./aws_ssh.pub"
exec-script-location = "./exec-bash.sh"
location-of-script-to-exec = "local.sh"
private_key_location = "aws_ssh"