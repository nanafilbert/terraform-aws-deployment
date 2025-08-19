module "vpc" {
  source = "C:/Users/filbe/terraform_aws_modules_repo/terraform_aws_module/modules/vpc"
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
  source = "C:/Users/filbe/terraform_aws_modules_repo/terraform_aws_module/modules/security_grps"
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
  source = "C:/Users/filbe/terraform_aws_modules_repo/terraform_aws_module/modules/ec2"
  name                       = var.name

  instances                  = var.instances
  key_name                   = var.key_name
  subnet_id                  = module.vpc.public_subnet_ids[0]  # pick one subnet
  security_group_ids         = [module.security_grps.app_sg_id] # must be list
  associate_public_ip_address = var.associate_public_ip_address
  user_data                  = var.user_data
  tags                       = var.tags
}




