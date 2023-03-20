variable "resource_group_name" {
  type        = string
  description = "the resource group where the VMs will be created"
}
# variable "vnet_resource_group_name" {
#   type        = string
#   description = "the resource group where the VMs will be created"
# }
variable "location" {
  type        = string
  description = "the location where the resource group is present"
}


variable "name" {
  type        = string
  description = "The name of vnet"
}

variable "administrator_login" {
  type        = string
  description = "(optional) describe your variable"
}

variable "sku_name" {
  type        = string
  description = "(optional) describe your variable"
}

variable "storage_mb" {
  type        = number
  description = "(optional) describe your variable"
}

variable "mysql_version" {
  type        = string
  description = "(optional) describe your variable"
  default = "8.0"
}

variable "auto_grow_enabled" {
  type        = bool
  description = "Enable/Disable auto-growing of the storage. Storage auto-grow prevents your server from running out of storage and becoming read-only"
  default     = true
}

variable "backup_retention_days" {
  type        = number
  description = "Backup retention days for the server, supported values are between 7 and 35 days."
  default     = 7
}

variable "geo_redundant_backup_enabled" {
  type        = bool
  description = " Turn Geo-redundant server backups on/off. This allows you to choose between locally redundant or geo-redundant backup storage in the General Purpose and Memory Optimized tiers."
  default     = false
}

variable "infrastructure_encryption_enabled" {
  type        = bool
  description = "Whether or not infrastructure is encrypted for this server. Defaults to false"
  default     = false
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Whether or not public network access is allowed for this server. Defaults to true."
  default     = false
}

variable "ssl_enforcement_enabled" {
  type        = bool
  description = "Specifies if SSL should be enforced on connections. Possible values are true and false"
  default     = true
}

variable "ssl_minimal_tls_version_enforced" {
  type        = string
  description = "The minimum TLS version to support on the sever. Possible values are TLSEnforcementDisabled, TLS1_0, TLS1_1, and TLS1_2. Defaults to TLS1_2."
  default     = "TLS1_2"
}



