variable "resource_group_name" {
  type        = string
  description = "the resource group where the VMs will be created"
}
variable "vnet_resource_group_name" {
  type        = string
  description = "the resource group where the VMs will be created"
}
variable "location" {
  type        = string
  description = "the location where the resource group is present"
}

variable "mysql_servers_configuration" {
  description = "the main input variable which has all the configuration regarding the mysql server to be created"
  type = list(object({
    name                              = string,
    administrator_login               = string,
    sku_name                          = string,
    storage_mb                        = number,
    version                           = string,
    auto_grow_enabled                 = bool,
    backup_retention_days             = number,
    geo_redundant_backup_enabled      = bool,
    infrastructure_encryption_enabled = bool,
    public_network_access_enabled     = bool,
    ssl_enforcement_enabled           = bool,
    ssl_minimal_tls_version_enforced  = string,
    vnet_name                         = string,
    subnet_id                         = string,
  }))
}

