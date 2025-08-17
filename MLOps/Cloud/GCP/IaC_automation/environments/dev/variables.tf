variable "gcp" {
  type = object({
    project_id = string
    region  = string
  })
}

variable "environment" {
  type      = string
}

variable "GCP_CREDENTIALS" {
  type      = string
  sensitive = true
}