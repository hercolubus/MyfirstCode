variable "subscription_id" {
  description = "Suscription ID"
  type        = string
  default     = "Change Me"
  sensitive   = true
}

variable "tag" {
  description = "tag"
  type        = string
  default     = "Grupo DevOps"
}

variable "rsgroup" {
  description = "Resource Group"
  type        = string
  default     = "DevOps"
}
