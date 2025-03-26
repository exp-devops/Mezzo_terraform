resource "azurerm_public_ip" "appgw_pip" {
  name                = "${var.project_name}-${var.project_environment}-appgw-public-ip"
  resource_group_name = var.rg_mezzo
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "appgw" {
  name                = "${var.project_name}-${var.project_environment}-app-gateway"
  resource_group_name = var.rg_mezzo
  location            = var.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "${var.project_name}-${var.project_environment}-appgw-ip-config"
    subnet_id = var.publicsubet1_id
  }

  frontend_ip_configuration {
    name                 = "${var.project_name}-${var.project_environment}-appgw-frontend-ip"
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  frontend_port {
    name = "${var.project_name}-${var.project_environment}-appgw-frontend-port"
    port = 80
  }
  # 🔹 Add a Backend Target (Example: Web App or VM IP)
  backend_address_pool {
    name = "${var.project_name}-${var.project_environment}-appgw-backend-pool"
    fqdns = ["mybackendapp.azurewebsites.net"]  # Add your backend web app or VM
  }

  backend_http_settings {
    name                  = "${var.project_name}-${var.project_environment}-appgw-http-setting"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
  }

  http_listener {
    name                           = "${var.project_name}-${var.project_environment}-appgw-http-listener"
    frontend_ip_configuration_name = "${var.project_name}-${var.project_environment}-appgw-frontend-ip"
    frontend_port_name             = "${var.project_name}-${var.project_environment}-appgw-frontend-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "${var.project_name}-${var.project_environment}-appgw-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "${var.project_name}-${var.project_environment}-appgw-http-listener"
    backend_address_pool_name  = "${var.project_name}-${var.project_environment}-appgw-backend-pool"
    backend_http_settings_name = "${var.project_name}-${var.project_environment}-appgw-http-setting"
    priority                   = 100  
  }
}
