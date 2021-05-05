variable "subscription_id" {
  description = "Suscription ID"
  type        = string
  default     = "Change Me" // cambiar valor por el suscription id
  sensitive   = true
}

variable "tag" {
  description = "tag"
  type        = string
  default     = "Grupo DevOps" // cambiar valor por un tag único ejemplo Grupo DevOps C
}

variable "rsgroup" {
  description = "Resource Group"
  type        = string
  default     = "DevOps" // cambiar valor por un grupo de recursos único ejemplo DevOps C
}
