variable "uczestnik" {
  description = "Twój identyfikator — wchodzi w nazwy zasobów"
  type        = string
}

variable "region" {
  description = "Region AWS"
  type        = string
  default     = "eu-central-1"
}

variable "vpc_id" {
  description = "ID VPC, w której działa kolektor"
  type        = string
}
