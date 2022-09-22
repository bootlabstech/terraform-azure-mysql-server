terraform {
  experiments = [module_variable_optional_attrs]
}

resource "random_string" "mysql_server_suffix" {
  length   = 8
  special  = false
  upper    = false
  lower    = true
  number   = true
}
resource "random_password" "mysql_password" {
  length           = 16
  special          = true
  upper            = true
  lower            = true
  number           = true
  override_special = "-_!#^~%@"
}

resource "azurerm_mysql_server" "mysql_server" {
  name                              = "${var.mysql_server_name}-${random_string.mysql_server_suffix.id}"
  location                          = var.location
  resource_group_name               = var.resource_group_name
  administrator_login               = var.administrator_login
  administrator_login_password      = random_password.mysql_password.result
  sku_name                          = var.sku_name
  storage_mb                        = var.storage_mb
  version                           = var.mysql_version
  auto_grow_enabled                 = var.auto_grow_enabled
  backup_retention_days             = var.backup_retention_days
  geo_redundant_backup_enabled      = var.geo_redundant_backup_enabled
  infrastructure_encryption_enabled = var.infrastructure_encryption_enabled
  public_network_access_enabled     = var.public_network_access_enabled
  ssl_enforcement_enabled           = var.ssl_enforcement_enabled
  ssl_minimal_tls_version_enforced  = var.ssl_minimal_tls_version_enforced
  threat_detection_policy {
    enabled = true
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "azurerm_private_dns_zone" "mysql_dns_zone" {
  count               = length(var.mysql_server_name) > 0 ? 1 : 0
  name                = "privatelink.mysql.database.azure.com"
  resource_group_name = var.resource_group_name

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

data "azurerm_virtual_network" "vnet_data" {
  name                = var.vnet_name
  resource_group_name = var.vnet_resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "mysql_vnet_link" {
  name                  = "${var.mysql_server_name}-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.mysql_dns_zone[0].name
  virtual_network_id    = data.azurerm_virtual_network.vnet_data.id

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "azurerm_private_endpoint" "mysql_endpoint" {
  name                = "${var.mysql_server_name}-${random_string.mysql_server_suffix.id}-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.mysql_server_name}-${random_string.mysql_server_suffix.id}-privateserviceconnection"
    private_connection_resource_id = azurerm_mysql_server.mysql_server.id
    is_manual_connection           = false
    subresource_names              = ["mysqlServer"]
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "azurerm_private_dns_a_record" "mysql_record" {
  name                = "${var.mysql_server_name}-${random_string.mysql_server_suffix.id}"
  zone_name           = azurerm_private_dns_zone.mysql_dns_zone[0].name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.mysql_endpoint.private_service_connection[0].private_ip_address]
}
