variable "app_name" {
  description = "Name of the app"
  default     = "aurora"
}

variable "namespace" {
  description = "Namespace"
  default     = "safari"
}

variable "stage" {
  description = "Environment stage. E.g. dev, qa, prod"
  default     = "dev"
}

variable "image_version" {
  description = "api gateway image version"
  default     = "latest"
}
