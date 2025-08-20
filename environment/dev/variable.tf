variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "enable_dns_support" {
  description = "Enable DNS support for VPC"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames for VPC"
  type        = bool
  default     = true
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDRs"
  type        = list(string)
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "name" {
  description = "Name of the security group"
  type        = string
}

variable "eip_vpc" {
  description = "Whether to create an Elastic IP for NAT in a VPC"
  type        = bool
  default     = false
}




variable "protocol" {
  description = "Protocol for TCP-based services"
  type        = string
  default     = "tcp"
}

variable "protocol_2" {
  description = "Protocol for all traffic"
  type        = string
  default     = "-1"
}

variable "outbound_cidr_blocks" {
  description = "CIDR blocks for the Security Group"
  type        = list(string)

}


variable "http_port" {
  description = "Second port for the Application Load Balancer"
  type        = number
}

variable "https_port" {
  description = "Port for the Application"
  type        = number
  
}

variable "db_port" {
  description = "Port for the Database"
  type        = number
}



variable "ssh_port" {
  description = "Port for SSH access"
  type        = string
  
}


variable "Admin_CIDR" {
  description = "Public Ip of Admin CIDR"
  type        = string
  
}

variable "outbound_port" {
  description = "Egress port for the Security Group"
  type        = number
  
}



variable "key_name" {
  description = "The name of the key pair to use for the instance"
  type        = string


}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address with the instance"
  type        = bool
  default     = true
  
}



variable "instances" {
  description = "Map of instance types for each role (e.g., web, app, db)"
  type        = map(string)

  
}

variable "user_data" {
  description = "User data script to run on instance launch"
  type        = string
  
  
}


variable "db_password" {
  description = "Database password for the application"
  type        = string
  sensitive   = true

}


variable "db_username" {
  description = "Database username for the application"
  type        = string
   
}
  
variable "group_members" {
  description = "List of group members"
  type        = list(string)
  default     = [
          "Emmanuel Buatsie-Detse",
          "James Agbenu",
          "Suzzette Naomi Sappor",
          "Godfred Boateng",
          "Emmanuel Atwam",
          "Maxwell Tyron",
          "Filbert Nana Blessing",
  ]
  
  
}