terraform {
  experiments = [module_variable_optional_attrs]
}

resource "random_string" "mysql_server_suffix" {
  for_each = { for server in var.mysql_servers_configuration : server.name => server }
  length   = 8
  special  = false
  upper    = false
  lower    = true
  number   = true
}

resource "random_password" "mysql_password" {
  for_each         = { for server in var.mysql_servers_configuration : server.name => server }
  length           = 16
  special          = true
  upper            = true
  lower            = true
  number           = true
  override_special = "-_!#^~%@"
}

resource "azurerm_mysql_server" "mysql_server" {
  for_each            = { for server in var.mysql_servers_configuration : server.name => server }
  name                = "${each.key}-${random_string.mysql_server_suffix[each.key].id}"
  location            = var.location
  resource_group_name = var.resource_group_name

  administrator_login          = each.value.administrator_login
  administrator_login_password = random_password.mysql_password[each.key].result

  sku_name   = each.value.sku_name
  storage_mb = each.value.storage_mb
  version    = each.value.version

  auto_grow_enabled                 = each.value.auto_grow_enabled
  backup_retention_days             = each.value.backup_retention_days
  geo_redundant_backup_enabled      = each.value.geo_redundant_backup_enabled
  infrastructure_encryption_enabled = each.value.infrastructure_encryption_enabled
  public_network_access_enabled     = each.value.public_network_access_enabled
  ssl_enforcement_enabled           = true
  ssl_minimal_tls_version_enforced  = each.value.ssl_minimal_tls_version_enforced

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }
}

resource "azurerm_private_dns_zone" "mysql_dns_zone" {
  count               = length(var.mysql_servers_configuration) > 0 ? 1 : 0
  name                = "privatelink.mysql.database.azure.com"
  resource_group_name = var.resource_group_name

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }
}

data "azurerm_virtual_network" "vnet_data" {
  for_each            = toset(var.mysql_servers_configuration[*].vnet_name)
  name                = each.key
  resource_group_name = var.vnet_resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "mysql_vnet_link" {
  for_each              = toset(var.mysql_servers_configuration[*].vnet_name)
  name                  = "${each.key}-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.mysql_dns_zone[0].name
  virtual_network_id    = data.azurerm_virtual_network.vnet_data[each.key].id

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }
}

resource "azurerm_private_endpoint" "mysql_endpoint" {
  for_each            = { for server in var.mysql_servers_configuration : server.name => server }
  name                = "${each.key}-${random_string.mysql_server_suffix[each.key].id}-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = each.value.subnet_id

  private_service_connection {
    name                           = "${each.key}-${random_string.mysql_server_suffix[each.key].id}-privateserviceconnection"
    private_connection_resource_id = azurerm_mysql_server.mysql_server[each.key].id
    is_manual_connection           = false
    subresource_names              = ["mysqlServer"]
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }
}

resource "azurerm_private_dns_a_record" "mysql_record" {
  for_each            = { for server in var.mysql_servers_configuration : server.name => server }
  name                = "${each.key}-${random_string.mysql_server_suffix[each.key].id}"
  zone_name           = azurerm_private_dns_zone.mysql_dns_zone[0].name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.mysql_endpoint[each.key].private_service_connection[0].private_ip_address]
}