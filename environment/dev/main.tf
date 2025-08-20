module "vpc" {
  source = "git::https://github.com/nanafilbert/terraform_aws_modules_repo.git//terraform_aws_module/modules/vpc?ref=v1.1.0" 
  name                   = var.name
 vpc_cidr                = var.vpc_cidr
  public_subnet_cidrs    = var.public_subnet_cidrs
  private_subnet_cidrs   = var.private_subnet_cidrs
  azs                    = var.azs
  eip_vpc                = var.eip_vpc
  tags                   = var.tags
  enable_dns_support     = var.enable_dns_support
  enable_dns_hostnames   = var.enable_dns_hostnames
}

module "security_grps" {
  source = "git::https://github.com/nanafilbert/terraform_aws_modules_repo.git//terraform_aws_module/modules/security_grps?ref=v1.1.0"
   vpc_id        = module.vpc.vpc_id
  https_port    = var.https_port
  protocol      = var.protocol
  db_port       = var.db_port
  Admin_CIDR    = var.Admin_CIDR
  http_port     = var.http_port
  ssh_port      = var.ssh_port
  protocol_2    = var.protocol_2
  outbound_port = var.outbound_port
  tags          = var.tags
  name = var.name


  
}



module "ec2" {
  source = "git::https://github.com/nanafilbert/terraform_aws_modules_repo.git//terraform_aws_module/modules/ec2?ref=v1.1.0"
  name                       = var.name
  instances                  = var.instances
  key_name                   = var.key_name
  subnet_id                  = module.vpc.public_subnet_ids[0]  # pick one subnet
  security_group_ids         = [module.security_grps.app_sg_id] # must be list
  associate_public_ip_address = var.associate_public_ip_address
  user_data                  = var.user_data
  tags                       = var.tags
}


resource "aws_ssm_parameter" "db_password" {
  name        = "/${var.name}/app/db_password"
  description = "Database password for the application"
  type        = "SecureString"
  value       = var.db_password
  
}
resource "aws_ssm_parameter" "db_username" {
  name        = "/${var.name}/app/db_username"
  description = "Database username for the application"
  type        = "String"
  value       = var.db_username
  
}

resource "aws_db_subnet_group" "db_subnets" {
  name       = "${var.name}-app-db-subnet-group"
  subnet_ids = module.vpc.private_subnet_ids
  tags       = merge(var.tags, { Name = "${var.name}-db-subnet-group" })
  
}

resource "aws_db_instance" "default" {
  identifier          = "${var.name}-db"
  allocated_storage    = 10

  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = var.db_username
  password             = aws_ssm_parameter.db_password.value
  db_subnet_group_name = aws_db_subnet_group.db_subnets.name
  vpc_security_group_ids = [module.security_grps.db_sg_id]
  publicly_accessible  = false
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
}



# Application Load Balancer
resource "aws_lb" "app_alb" {
  name               = "${var.name}-app-alb"
  load_balancer_type = "application"
  security_groups    = [module.security_grps.alb_sg_id]
  subnets            = module.vpc.public_subnet_ids  

  tags = {
    Environment = var.name
  }
}


# Target Group
resource "aws_lb_target_group" "app_tg" {
  name     = "${var.name}-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

# Listener (route HTTP → Target Group)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# Attach EC2 Instances to Target Group
resource "aws_lb_target_group_attachment" "app_instances" {
  for_each =  module.ec2.filbert_output 

  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = each.value
  port             =80
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "filber-tf-state-bucket"

    tags = merge(
    { 
      Name = "${var.name}-vpc"
   },
    var.tags
  )
}


terraform {
  backend "s3" {
    bucket = "filbert-tf-state-bucket"
    key = "devops/infrastructure/s3.tfstate"
    region = "us-east-2"
     use_lockfile = true
     encrypt      = true
   
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.8.0"
    }
  }
  required_version = ">= 1.12.2"
}



#