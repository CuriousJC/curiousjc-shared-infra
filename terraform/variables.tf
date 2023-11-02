variable "rds_admin" {
  type        = string
  description = "admin for rds instance"
}

variable "rds_admin_password" {
  type        = string
  description = "admin for rds instance"
  #sensitive = true
}
