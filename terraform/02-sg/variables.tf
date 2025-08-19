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
