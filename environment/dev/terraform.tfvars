name                     = "filbert"
eip_vpc            = true
enable_dns_support = true
enable_dns_hostnames = true
vpc_cidr                 = "10.0.0.0/16"
azs                      = ["us-east-2a", "us-east-2b"]
public_subnet_cidrs      = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs     = ["10.0.3.0/24", "10.0.4.0/24"]
db_port = 3306
http_port      = 80
https_port          = 443
protocol            = "tcp"
protocol_2          = "-1"
ssh_port            = 22
outbound_port = 0
outbound_cidr_blocks = ["0.0.0.0/0"]
key_name = "one"
instances = {
  webserver = "t2.micro"
  appserver = "t2.small"
}
user_data = <<-EOT
#!/bin/bash
apt-get update -y
apt-get upgrade -y
apt-get install -y nginx
systemctl enable nginx
systemctl start nginx
echo "<h1>Hello from NGINX on $(hostname -f)</h1>" > /var/www/html/index.nginx-debian.html
EOT

db_username = "admin"

tags = {
  environment = "development"
  project     = "terraform_aws_module_vpc"
  owner       = "filbert"
}


#