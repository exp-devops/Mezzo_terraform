/*locals {
  common_tags             = var.tags
}

resource "azurerm_cdn_frontdoor_profile" "frontdoor-profile-admin" {
  name                = "${var.project_name}-${var.project_environment}-admin--frontdoor-profile"
  resource_group_name = var.rg_mezzo
  sku_name            = "Standard_AzureFrontDoor"
  tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-admin--frontdoor-profile"}
  )
}

resource "azurerm_cdn_frontdoor_endpoint" "frontdoor-endpoint-admin" {
  name                     = "${var.project_name}-${var.project_environment}-frontdoor-endpoint"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor-profile-admin.id
}


resource "azurerm_cdn_frontdoor_origin_group" "frontdoor-origin-group-admin" {
  name                     = "${var.project_name}-${var.project_environment}-admin-frontdoor-origin-group"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor-profile-admin.id

  health_probe {
    protocol            = "Https"
    path                = "/"
    request_type        = "GET"
    interval_in_seconds = 30
  }
  load_balancing {
    sample_size                        = 4    # Number of samples for latency measurement
    successful_samples_required         = 3    # Required successful samples for an origin to be considered healthy
    additional_latency_in_milliseconds  = 50   # Extra latency to add for load balancing decisions
  }
}

# 5️⃣ Front Door Origin
resource "azurerm_cdn_frontdoor_origin" "frontdoor-origin-admin" {
  name                           = "${var.project_name}-${var.project_environment}-admin-frontdoor-origin"
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.frontdoor-origin-group-admin.id
  certificate_name_check_enabled = false

  host_name  = "green-flower-0f13ef40f.6.azurestaticapps.net"
  http_port  = 80
  https_port = 443
  priority   = 1
  weight     = 1
}

# 6️⃣ Front Door Route (Traffic Rules)
resource "azurerm_cdn_frontdoor_route" "cdn-frontdoor-route" {
  name                      = "${var.project_name}-${var.project_environment}-admin-frontdoor-route"
  cdn_frontdoor_endpoint_id = azurerm_cdn_frontdoor_endpoint.frontdoor-endpoint-admin.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.frontdoor-origin-group-admin.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.frontdoor-origin-admin.id]

  forwarding_protocol    = "MatchRequest"
  https_redirect_enabled = true
  patterns_to_match      = ["/*"]
  supported_protocols    = ["Http", "Https"]
  link_to_default_domain = true
}

resource "azurerm_cdn_frontdoor_firewall_policy" "frontdoor-firewall-policy" {
  name                              = "${var.project_name}-${var.project_environment}-waf"
  resource_group_name               = var.rg_mezzo
  sku_name                          = azurerm_cdn_frontdoor_profile.frontdoor-profile-admin.sku_name
  enabled                           = true
  mode                              = "Prevention"
  #redirect_url                      = ""
  custom_block_response_status_code = 403
  #custom_block_response_body        = "PGh0bWw+CjxoZWFkZXI+PHRpdGxlPkhlbGxvPC90aXRsZT48L2hlYWRlcj4KPGJvZHk+CkhlbGxvIHdvcmxkCjwvYm9keT4KPC9odG1sPg=="
/*
  custom_rule {
    name                           = "Rule1"
    enabled                        = true
    priority                       = 1
    rate_limit_duration_in_minutes = 1
    rate_limit_threshold           = 10
    type                           = "MatchRule"
    action                         = "Block"

    match_condition {
      match_variable     = "RemoteAddr"
      operator           = "IPMatch"
      negation_condition = false
      match_values       = ["192.168.1.0/24", "10.0.1.0/24"]
    }
  }
}

resource "azurerm_cdn_frontdoor_security_policy" "example" {
  name                     = "${var.project_name}-${var.project_environment}-frontdoor-security-policy"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor-profile-admin.id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.frontdoor-firewall-policy.id

      association {
        domain {
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_custom_domain.
        }
        patterns_to_match = ["/*"]
      }
    }
  }
}

resource "azurerm_dns_zone" "dns-zone" {
  name                = "mezzo.com"
  resource_group_name = var.rg_mezzo
}*/