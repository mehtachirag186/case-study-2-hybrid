variable "location" {
  description = "Azure region"
  type        = string
}

variable "hub_vnet_cidr" {
  description = "CIDR for hub VNet"
  type        = string
}

variable "gateway_subnet_cidr" {
  description = "CIDR for gateway subnet"
  type        = string
}

variable "vm_size" {
  description = "Size of WireGuard VM"
  type        = string
}
