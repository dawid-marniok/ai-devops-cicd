variable "uczestnik" {
  description = "Identyfikator uczestnika szkolenia, używany w nazwach zasobów i tagach"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]{0,18}[a-z0-9])?$", var.uczestnik))
    error_message = "Dozwolone są małe litery, cyfry i myślniki (2-20 znaków, bez myślnika na początku/końcu) — nazwa wchodzi w skład nazwy bucketu S3."
  }
}

variable "blok" {
  description = "Identyfikator bloku szkoleniowego, używany w nazwach zasobów i tagach"
  type        = string
  default     = "b1"
}

variable "cidr_vpc" {
  description = "Zakres adresów CIDR dla VPC szkoleniowej"
  type        = string
  default     = "10.20.0.0/16"
}

variable "cidr_subnet_publiczna" {
  description = "Zakres adresów CIDR dla podsieci publicznej"
  type        = string
  default     = "10.20.1.0/24"
}

variable "cidr_subnet_prywatna" {
  description = "Zakres adresów CIDR dla podsieci prywatnej"
  type        = string
  default     = "10.20.2.0/24"
}
