variable "enabled" {
  description = "Set to false to prevent the module from creating any resources"
  default     = true
}

variable "max_image_age" {
  description = "Max container image age"
  default     = "0"
}

variable "max_image_age_tag_prefix" {
  description = "Tag prefix list for max image age rule"
  type        = "list"
  default     = []
}

variable "max_image_count" {
  description = "Max container images to keep"
  default     = "500"
}

variable "accounts_rw" {
  description = "AWS accounts to provide with full access to the ECR"
  type        = "list"
  default     = []
}

variable "accounts_ro" {
  description = "AWS accounts to provide with readonly access to the ECR"
  type        = "list"
  default     = []
}

variable "use_fullname" {
  description = ""
  default     = "true"
}
