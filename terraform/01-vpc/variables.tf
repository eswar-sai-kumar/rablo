variable "project_name" {
    default = "rablo"
}

variable "environment" {
  default = "dev"
}

variable "common_tags" {
    default = {
        Project = "rablo"
        Environment = "dev"
        Terraform = "true"
    }
}

variable "public_subnet_cidrs" {
    default = ["10.0.1.0/24","10.0.2.0/24"]
}

variable "is_peering_required" {
  default = true
}