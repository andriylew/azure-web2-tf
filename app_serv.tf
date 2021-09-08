provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "tf-rg-group" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

resource "azurerm_app_service_plan" "tf-service-plan" {
  name                = var.app_service_plan_name
  location            = azurerm_resource_group.tf-rg-group.location
  resource_group_name = azurerm_resource_group.tf-rg-group.name
  kind                = "Linux"
  reserved            = true
  sku {
    tier = "Standard"
    size = "S1"
  }
  tags = {
    environment = "dev"
  }

}

resource "azurerm_app_service" "tf-app-service" {
  name                = var.app_service_name
  location            = azurerm_resource_group.tf-rg-group.location
  resource_group_name = azurerm_resource_group.tf-rg-group.name
  app_service_plan_id = azurerm_app_service_plan.tf-service-plan.id

  site_config {
    linux_fx_version = "PHP|7.4"
    scm_type         = "LocalGit"
  }

  tags = {
    environment = "dev"
  }

}


resource "azurerm_mysql_server" "tf-mysql-serv" {
  name                = var.sql_server_name
  location            = azurerm_resource_group.tf-rg-group.location
  resource_group_name = azurerm_resource_group.tf-rg-group.name

  administrator_login               = var.sql_admin_login
  administrator_login_password      = var.sql_admin_password
  sku_name                          = "B_Gen5_2"
  storage_mb                        = 5120
  version                           = "5.7"
  auto_grow_enabled                 = false
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = false
  infrastructure_encryption_enabled = false
  public_network_access_enabled     = true
  ssl_enforcement_enabled           = false
}

resource "azurerm_mysql_database" "tf-mysql-db" {
  name                = "tf-web2-mysql-db"
  resource_group_name = azurerm_resource_group.tf-rg-group.name
  server_name         = azurerm_mysql_server.tf-mysql-serv.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

resource "azurerm_mysql_firewall_rule" "allow_azure_services" {
  name                = "office"
  resource_group_name = azurerm_resource_group.tf-rg-group.name
  server_name         = azurerm_mysql_server.tf-mysql-serv.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}



output "mysql_host" {
  value = azurerm_mysql_server.tf-mysql-serv.fqdn

}


