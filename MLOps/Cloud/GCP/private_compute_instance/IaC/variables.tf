variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "Region for regional resources"
  type        = string
  default     = "us-central1"
}

variable "network_name" {
  description = "Name of the VPC"
  type        = string
  default     = "prod-vpc"
}

variable "subnet_public_cidr" {
  description = "CIDR for public subnet"
  type        = string
  default     = "10.10.0.0/24"
}

variable "subnet_private_cidr" {
  description = "CIDR for private subnet"
  type        = string
  default     = "10.10.1.0/24"
}

variable "public_subnet_name" {
  type    = string
  default = "subnet-public"
}

variable "private_subnet_name" {
  type    = string
  default = "subnet-private"
}

variable "instance_name" {
  type    = string
  default = "app-vm-1"
}

variable "instance_machine_type" {
  type    = string
  default = "e2-medium"
}

variable "instance_image_family" {
  type    = string
  default = "debian-12"
}

variable "instance_image_project" {
  type    = string
  default = "debian-cloud"
}

variable "enable_confidential_vm" {
  description = "Enable Confidential VM (requires supported machine types)"
  type        = bool
  default     = false
}

variable "labels" {
  description = "Common labels"
  type        = map(string)
  default = {
    env = "prod"
  }
}
