output "fqdns" {
  value = {
    for k, v in azurerm_mysql_server.mysql_server : k => v.fqdn
  }
}

output "mysql_server_suffix" {
  value = {
    for k, v in random_string.mysql_server_suffix : k => v.result
  }
}

output "mysql_passwords" {
  value = {
    for k, v in random_password.mysql_password : k => v.result
  }
}

output "password_keys" {
  value = [
    for v in var.mysql_servers_configuration : "${v.name}-${random_string.mysql_server_suffix[v.name].id}"
  ]
}
