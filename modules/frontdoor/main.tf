# Common tags to apply to all resources
locals {
  common_tags             = var.tags
}



resource "azurerm_cdn_frontdoor_firewall_policy" "waf_policy" {
name                      = "${var.project_name}${var.project_environment}wafpolicy"
resource_group_name       = var.rg_mezzo
sku_name                  = "Standard_AzureFrontDoor"
mode                      = "Prevention"
/* managed_rule {
    type    = "DefaultRuleSet"
    version = "1.0"
    action = "Block"
}*/
custom_rule {
    name                           = "Rule1"
    enabled                        = true
    priority                       = 1
    rate_limit_duration_in_minutes = 1
    rate_limit_threshold           = 10
    type                           = "MatchRule"
    action                         = "Block"

    match_condition {
      match_variable               = "RemoteAddr"
      operator                     = "IPMatch"
      negation_condition           = false
      match_values                 = ["192.168.1.0/24", "10.0.1.0/24"]
    }
  }
  tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-waf-policy"}
  )
}

resource "azurerm_cdn_frontdoor_profile" "frontdoor-profile"{
name                                  = "${var.project_name}-${var.project_environment}-front-door-profile"
resource_group_name                   = var.rg_mezzo
sku_name                              = "Standard_AzureFrontDoor"
tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-front-door-profile"}
  )
}
# ------ Admin----------
resource "azurerm_cdn_frontdoor_endpoint" "frontdoor-endpoint-admin-portal" {
name                                  = "${var.project_name}-${var.project_environment}-admin-portal-endpoint"
cdn_frontdoor_profile_id              = azurerm_cdn_frontdoor_profile.frontdoor-profile.id
tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-admin-endpoint"}
  )
}
 
# Origin Group for Admin portal

resource "azurerm_cdn_frontdoor_origin_group" "origin-group-admin-portal" {
  name                                = "${var.project_name}-${var.project_environment}-admin-origin-group"
  cdn_frontdoor_profile_id            = azurerm_cdn_frontdoor_profile.frontdoor-profile.id
  session_affinity_enabled            = false
  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = 10
  health_probe {
    interval_in_seconds                = 100
    protocol                           = "Https"
    path                               = "/"
    request_type                       = "GET"
  }
  load_balancing {
    sample_size                        = 4            # Number of samples for latency measurement
    successful_samples_required        = 3            # Required successful samples for an origin to be considered healthy
    additional_latency_in_milliseconds = 50           # Extra latency to add for load balancing decisions
  }
  
}
 
# Origin for Admin portal

resource "azurerm_cdn_frontdoor_origin" "origin-admin-portal" {
  name                                 = "${var.project_name}-${var.project_environment}-admin-origin"
  cdn_frontdoor_origin_group_id        = azurerm_cdn_frontdoor_origin_group.origin-group-admin-portal.id
  enabled                              = true
  host_name                            =  "${var.static_web_app_url_admin}" 
  priority                             = 1
  weight                               = 1
  certificate_name_check_enabled       = true
  origin_host_header                   = var.static_web_app_url_admin

}
 
# Front door route configuration for Admin portal

resource "azurerm_cdn_frontdoor_route" "route-admin-portal" {
  name                                 = "${var.project_name}-${var.project_environment}-admin-route"
  cdn_frontdoor_endpoint_id            = azurerm_cdn_frontdoor_endpoint.frontdoor-endpoint-admin-portal.id
  cdn_frontdoor_origin_group_id        = azurerm_cdn_frontdoor_origin_group.origin-group-admin-portal.id
  cdn_frontdoor_origin_ids             = [azurerm_cdn_frontdoor_origin.origin-admin-portal.id]
  supported_protocols                  = ["Http", "Https"]
  patterns_to_match                    = ["/*"]
  https_redirect_enabled               = true
  link_to_default_domain               = true
  forwarding_protocol                  = "HttpsOnly"
  cdn_frontdoor_custom_domain_ids      = [azurerm_cdn_frontdoor_custom_domain.admin_portal_custom_domain.id]

}

resource "azurerm_cdn_frontdoor_custom_domain" "admin_portal_custom_domain" {
  name                     = "${var.project_name}-${var.project_environment}-admin-custom-domains"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor-profile.id
  host_name                = var.host_name_admin#"mezzo-development-admin.experionglobal.dev"  #Replace with your subdomain

  tls {
    certificate_type = "ManagedCertificate"
  }
}

resource "azurerm_cdn_frontdoor_security_policy" "frontdoor-security-policy" {
  name                                 = "${var.project_name}-${var.project_environment}-frontdoor-security-policy"
  cdn_frontdoor_profile_id             = azurerm_cdn_frontdoor_profile.frontdoor-profile.id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.waf_policy.id

      association {
        domain {
      cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_endpoint.frontdoor-endpoint-admin-portal.id
    }

    domain {
      cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_endpoint.frontdoor-endpoint-borrower-portal.id
    }

    domain {
      cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_endpoint.frontdoor-endpoint-api.id
    }
        patterns_to_match              = ["/*"]
      }
    }
  }
 
}
# ------ borrower----------
resource "azurerm_cdn_frontdoor_endpoint" "frontdoor-endpoint-borrower-portal" {
name                                  = "${var.project_name}-${var.project_environment}-borrower-portal-endpoint"
cdn_frontdoor_profile_id              = azurerm_cdn_frontdoor_profile.frontdoor-profile.id
tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-borrower-endpoint"}
  )
}
 
# Origin Group for Borrower portal

resource "azurerm_cdn_frontdoor_origin_group" "origin-group-borrower-portal" {
  name                                = "${var.project_name}-${var.project_environment}-borrower-origin-group"
  cdn_frontdoor_profile_id            = azurerm_cdn_frontdoor_profile.frontdoor-profile.id
  session_affinity_enabled            = false
  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = 10
  health_probe {
    interval_in_seconds                = 100
    protocol                           = "Https"
    path                               = "/"
    request_type                       = "GET"
  }
  load_balancing {
    sample_size                        = 4            # Number of samples for latency measurement
    successful_samples_required        = 3            # Required successful samples for an origin to be considered healthy
    additional_latency_in_milliseconds = 50           # Extra latency to add for load balancing decisions
  }
  
}
 
# Origin for Borrower portal

resource "azurerm_cdn_frontdoor_origin" "origin-borrower-portal" {
  name                                 = "${var.project_name}-${var.project_environment}-borrower-origin"
  cdn_frontdoor_origin_group_id        = azurerm_cdn_frontdoor_origin_group.origin-group-borrower-portal.id
  enabled                              = true
  host_name                            =  "${var.static_web_app_url_borrower}" 
  priority                             = 1
  weight                               = 1
  certificate_name_check_enabled       = true
  origin_host_header                   = var.static_web_app_url_borrower

}
 
# Front door route configuration for Borrower portal

resource "azurerm_cdn_frontdoor_route" "route-borrower-portal" {
  name                                 = "${var.project_name}-${var.project_environment}-borrower-route"
  cdn_frontdoor_endpoint_id            = azurerm_cdn_frontdoor_endpoint.frontdoor-endpoint-borrower-portal.id
  cdn_frontdoor_origin_group_id        = azurerm_cdn_frontdoor_origin_group.origin-group-borrower-portal.id
  cdn_frontdoor_origin_ids             = [azurerm_cdn_frontdoor_origin.origin-borrower-portal.id]
  supported_protocols                  = ["Http", "Https"]
  patterns_to_match                    = ["/*"]
  https_redirect_enabled               = true
  link_to_default_domain               = true
  forwarding_protocol                  = "HttpsOnly"
  cdn_frontdoor_custom_domain_ids      = [azurerm_cdn_frontdoor_custom_domain.borrower_portal_custom_domain.id]

}

resource "azurerm_cdn_frontdoor_custom_domain" "borrower_portal_custom_domain" {
  name                     = "${var.project_name}-${var.project_environment}-borrower-custom-domains"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor-profile.id
  host_name                = var.host_name_borrower #"mezzo-development-borrower.experionglobal.dev"  #Replace with your subdomain

  tls {
    certificate_type = "ManagedCertificate"
  }
}



# ------Application Gateway----------

resource "azurerm_cdn_frontdoor_endpoint" "frontdoor-endpoint-api" {
name                                  = "${var.project_name}-${var.project_environment}-api-endpoint"
cdn_frontdoor_profile_id              = azurerm_cdn_frontdoor_profile.frontdoor-profile.id
tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-api-endpoint"}
  )
}
 
# Origin Group for Api

resource "azurerm_cdn_frontdoor_origin_group" "origin-group-api" {
  name                                = "${var.project_name}-${var.project_environment}-api-origin-group"
  cdn_frontdoor_profile_id            = azurerm_cdn_frontdoor_profile.frontdoor-profile.id
  session_affinity_enabled            = false
  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = 10
  
  health_probe {
    interval_in_seconds                = 100
    protocol                           = "Http"
    path                               = "/api/heartbeat"
    request_type                       = "GET"
  }
  load_balancing {
    sample_size                        = 4            # Number of samples for latency measurement
    successful_samples_required        = 3            # Required successful samples for an origin to be considered healthy
    additional_latency_in_milliseconds = 50           # Extra latency to add for load balancing decisions
  }
  
}
 
# Origin for Api

resource "azurerm_cdn_frontdoor_origin" "origin-api" {
  name                                 = "${var.project_name}-${var.project_environment}-api-origin"
  cdn_frontdoor_origin_group_id        = azurerm_cdn_frontdoor_origin_group.origin-group-api.id
  enabled                              = true
  host_name                            =  var.appgw_ip 
  priority                             = 1
  weight                               = 1
  certificate_name_check_enabled       = false
  #origin_host_header                   = var.appgw_ip

}
 
# Front door route configuration for Api

resource "azurerm_cdn_frontdoor_route" "route-api" {
  name                                 = "${var.project_name}-${var.project_environment}-api-route"
  cdn_frontdoor_endpoint_id            = azurerm_cdn_frontdoor_endpoint.frontdoor-endpoint-api.id
  cdn_frontdoor_origin_group_id        = azurerm_cdn_frontdoor_origin_group.origin-group-api.id
  cdn_frontdoor_origin_ids             = [azurerm_cdn_frontdoor_origin.origin-api.id]
  supported_protocols                  = ["Http", "Https"]
  patterns_to_match                    = ["/api/*"]
  https_redirect_enabled               = false
  link_to_default_domain               = true
  forwarding_protocol                  = "HttpOnly"
  cdn_frontdoor_custom_domain_ids      = [azurerm_cdn_frontdoor_custom_domain.api_aks_custom_domain.id]

}

resource "azurerm_cdn_frontdoor_custom_domain" "api_aks_custom_domain" {
  name                     = "${var.project_name}-${var.project_environment}-api-custom-domains"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor-profile.id
  host_name                = var.host_name_api #"mezzo-development-api.experionglobal.dev"  #Replace with your subdomain

  tls {
    certificate_type = "ManagedCertificate"
  }
}



#---------------------------with 3 front door--------------------------------------------------
# Azure frontdoor for Admin portal
/*resource "azurerm_cdn_frontdoor_profile" "frontdoor-profile-admin" {
name                                  = "${var.project_name}-${var.project_environment}-admin-front-door-profile"
resource_group_name                   = var.rg_mezzo
sku_name                              = "Standard_AzureFrontDoor"
tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-admin-front-door-profile"}
  )
}
 
# Azure frontdoor endpoint for Admin portal
resource "azurerm_cdn_frontdoor_endpoint" "frontdoor-endpoint-admin" {
name                                  = "${var.project_name}-${var.project_environment}-admin-endpoint"
cdn_frontdoor_profile_id              = azurerm_cdn_frontdoor_profile.frontdoor-profile-admin.id
tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-admin-endpoint"}
  )
}
 
# Origin Group for Admin portal

resource "azurerm_cdn_frontdoor_origin_group" "origin-group-admin" {
  name                                = "${var.project_name}-${var.project_environment}-admin-origin-group"
  cdn_frontdoor_profile_id            = azurerm_cdn_frontdoor_profile.frontdoor-profile-admin.id
  session_affinity_enabled            = false
  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = 10
  health_probe {
    interval_in_seconds                = 100
    protocol                           = "Https"
    path                               = "/"
    request_type                       = "GET"
  }
  load_balancing {
    sample_size                        = 4            # Number of samples for latency measurement
    successful_samples_required        = 3            # Required successful samples for an origin to be considered healthy
    additional_latency_in_milliseconds = 50           # Extra latency to add for load balancing decisions
  }
  
}
 
# Origin for Admin portal

resource "azurerm_cdn_frontdoor_origin" "origin-admin" {
  name                                 = "${var.project_name}-${var.project_environment}-admin-origin"
  cdn_frontdoor_origin_group_id        = azurerm_cdn_frontdoor_origin_group.origin-group-admin.id
  enabled                              = true
  host_name                            =  "${var.static_web_app_url_admin}" 
  priority                             = 1
  weight                               = 1
  certificate_name_check_enabled       = true
  origin_host_header                   = var.static_web_app_url_admin

}
 
# Front door route configuration for Admin portal

resource "azurerm_cdn_frontdoor_route" "route-admin" {
  name                                 = "${var.project_name}-${var.project_environment}-admin-route"
  cdn_frontdoor_endpoint_id            = azurerm_cdn_frontdoor_endpoint.frontdoor-endpoint-admin.id
  cdn_frontdoor_origin_group_id        = azurerm_cdn_frontdoor_origin_group.origin-group-admin.id
  cdn_frontdoor_origin_ids             = [azurerm_cdn_frontdoor_origin.origin-admin.id]
  supported_protocols                  = ["Http", "Https"]
  patterns_to_match                    = ["/*"]
  https_redirect_enabled               = true
  link_to_default_domain               = true
  forwarding_protocol                  = "HttpsOnly"
  cdn_frontdoor_custom_domain_ids      = [azurerm_cdn_frontdoor_custom_domain.admin_custom_domain.id]

}

resource "azurerm_cdn_frontdoor_custom_domain" "admin_custom_domain" {
  name                     = "${var.project_name}-${var.project_environment}-admin-custom-domains"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor-profile-admin.id
  host_name                = "cnb-dev-ap.dev.teammezzo.com"  #"mezzo-development-admin.experionglobal.dev"  Replace with your subdomain

  tls {
    certificate_type = "ManagedCertificate"
  }
}

resource "azurerm_cdn_frontdoor_profile" "frontdoor-profile-borrower" {
name                                  = "${var.project_name}-${var.project_environment}-borrower-front-door-profile"
resource_group_name                   = var.rg_mezzo
sku_name                              = "Standard_AzureFrontDoor"
tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-borrower-front-door-profile"}
  )
}
 
# Front door endpoint for borrower portal
resource "azurerm_cdn_frontdoor_endpoint" "frontdoor-endpoint-borrower" {
name                                  = "${var.project_name}-${var.project_environment}-borrower-endpoint"
cdn_frontdoor_profile_id              = azurerm_cdn_frontdoor_profile.frontdoor-profile-borrower.id
tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-borrower-endpoint"}
  )
}
 
# Origin Group for borrower portal

resource "azurerm_cdn_frontdoor_origin_group" "origin-group-borrower" {
  name                                = "${var.project_name}-${var.project_environment}-borrower-origin-group"
  cdn_frontdoor_profile_id            = azurerm_cdn_frontdoor_profile.frontdoor-profile-borrower.id
  session_affinity_enabled            = false
  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = 10
  health_probe {
    interval_in_seconds                = 100
    protocol                           = "Https"
    path                               = "/"
    request_type                       = "GET"
  }
  load_balancing {
    sample_size                        = 4             # Number of samples for latency measurement
    successful_samples_required        = 3             # Required successful samples for an origin to be considered healthy
    additional_latency_in_milliseconds = 50            # Extra latency to add for load balancing decisions
  }
  
}
 
#  Origin Group for Borrower portal

resource "azurerm_cdn_frontdoor_origin" "origin-borrower" {
  name                                 = "${var.project_name}-${var.project_environment}-borrower-origin"
  cdn_frontdoor_origin_group_id        = azurerm_cdn_frontdoor_origin_group.origin-group-borrower.id
  enabled                              = true
  host_name                            =  "${var.static_web_app_url_borrower}" # Replace with your backend
  priority                             = 1
  weight                               = 1
  certificate_name_check_enabled       = true
  origin_host_header                   = "${var.static_web_app_url_borrower}"    
  

}
resource "azurerm_cdn_frontdoor_custom_domain" "borrower_custom_domain" {
  name                     = "${var.project_name}-${var.project_environment}-borrower-custom-domains"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor-profile-borrower.id
  host_name                = "cnb-dev-bp.dev.teammezzo.com"  #"mezzo-development-borrower.experionglobal.dev"#cnb-dev-bp.dev.teammezzo.com"  Replace with your subdomain

  tls {
    certificate_type = "ManagedCertificate"
  }
}

 
# Front door configuration configuration for borrower portal

resource "azurerm_cdn_frontdoor_route" "route-borrower" {
  name                                 = "${var.project_name}-${var.project_environment}-borrower-route"
  cdn_frontdoor_endpoint_id            = azurerm_cdn_frontdoor_endpoint.frontdoor-endpoint-borrower.id
  cdn_frontdoor_origin_group_id        = azurerm_cdn_frontdoor_origin_group.origin-group-borrower.id
  cdn_frontdoor_origin_ids             = [azurerm_cdn_frontdoor_origin.origin-borrower.id]
  supported_protocols                  = ["Http", "Https"]
  patterns_to_match                    = ["/*"]
  https_redirect_enabled               = true
  link_to_default_domain               = true
  forwarding_protocol                  = "HttpsOnly"
  cdn_frontdoor_custom_domain_ids      = [azurerm_cdn_frontdoor_custom_domain.borrower_custom_domain.id]
}


# Azure front door profile for application gateway
resource "azurerm_cdn_frontdoor_profile" "frontdoor-profile-appgw" {
name                                  = "${var.project_name}-${var.project_environment}-appgw-front-door-profile"
resource_group_name                   = var.rg_mezzo
sku_name                              = "Standard_AzureFrontDoor"
tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-appgw-front-door-profile"}
  )
}
 
# Frontdoor enpoint for application gateway
resource "azurerm_cdn_frontdoor_endpoint" "frontdoor-endpoint-appgw" {
name                                  = "${var.project_name}-${var.project_environment}-appgw-endpoint"
cdn_frontdoor_profile_id              = azurerm_cdn_frontdoor_profile.frontdoor-profile-appgw.id
tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-appgw-endpoint"}
  )
}
 
# Origin group application gateway

resource "azurerm_cdn_frontdoor_origin_group" "origin-group-appgw" {
  name                                = "${var.project_name}-${var.project_environment}-appgw-origin-group"
  cdn_frontdoor_profile_id            = azurerm_cdn_frontdoor_profile.frontdoor-profile-appgw.id
  session_affinity_enabled            = false
  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = 10
  health_probe {
    interval_in_seconds                = 100
    protocol                           = "Http"
    request_type                       = "GET"
    path                               = "/"
  }
  load_balancing {
    sample_size                        = 4               # Number of samples for latency measurement
    successful_samples_required        = 3               # Required successful samples for an origin to be considered healthy
    additional_latency_in_milliseconds = 50              # Extra latency to add for load balancing decisions
  }
  
}
 
#  Origin for Application gateway

resource "azurerm_cdn_frontdoor_origin" "origin-appgw" {
  name                                 = "${var.project_name}-${var.project_environment}-appgw-origin"
  cdn_frontdoor_origin_group_id        = azurerm_cdn_frontdoor_origin_group.origin-group-appgw.id
  enabled                              = true
  host_name                            =  var.appgw_ip # Replace with your backend
  priority                             = 1
  weight                               = 1
  certificate_name_check_enabled       = true
 # origin_host_header                   = var.appgw_ip
  

}
 
#  Front door route configuration for application gateway

resource "azurerm_cdn_frontdoor_route" "route-appgw" {
  name                                 = "${var.project_name}-${var.project_environment}-appgw-route"
  cdn_frontdoor_endpoint_id            = azurerm_cdn_frontdoor_endpoint.frontdoor-endpoint-appgw.id
  cdn_frontdoor_origin_group_id        = azurerm_cdn_frontdoor_origin_group.origin-group-appgw.id
  cdn_frontdoor_origin_ids             = [azurerm_cdn_frontdoor_origin.origin-appgw.id]
  supported_protocols                  = ["Http", "Https"]
  patterns_to_match                    = ["/api/*"]
  https_redirect_enabled               = true
  link_to_default_domain               = true
  forwarding_protocol                  = "MatchRequest"
  cdn_frontdoor_custom_domain_ids      = [azurerm_cdn_frontdoor_custom_domain.api_custom_domain.id]
  
}

resource "azurerm_cdn_frontdoor_custom_domain" "api_custom_domain" {
  name                     = "${var.project_name}-${var.project_environment}-api-custom-domains"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor-profile-appgw.id
  host_name                = "mezzo-development-api.experionglobal.dev"  # Replace with your subdomain

  tls {
    certificate_type = "ManagedCertificate"
  }
}


#---------------------------------------3 front door end -----------------------------
/*
resource "azurerm_frontdoor_rule_set" "appgw_ruleset" {
  name                = "${var.project_name}-${var.project_environment}-appgw-rule-set"
  resource_group_name = var.rg_mezzo

  rule {
    name          = "${var.project_name}-${var.project_environment}-appgw-rule-1"
    action {
      route_configuration_override {
        origin_group_id = azurerm_cdn_frontdoor_origin_group.origin-group-appgw.id
      }
    }

    match_condition {
      match_variable = "RequestPath"
      operator       = "Contains"
      value          = "/*"
    }

    route_configuration {
      origin_group_id    = azurerm_cdn_frontdoor_origin_group.origin-group-appgw.id
      forwarding_protocol = "MatchIncomingRequest"
      caching            = "Disabled"
    }
  }
}
 






#--------------------------------------------------------------------------------------------
/* # AZURE DNS ZONE
resource "azurerm_dns_zone" "dns_zone" {
name                      = "mezzo-dev.com"
resource_group_name       = var.rg_mezzo
tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-dns-zone"}
  )
}*/
 /*
# WEB APPLICATION FIREWALL (WAF) POLICY
resource "azurerm_cdn_frontdoor_firewall_policy" "waf_policy" {
name                      = "${var.project_name}${var.project_environment}wafpolicy"
resource_group_name       = var.rg_mezzo
sku_name                  = "Standard_AzureFrontDoor"
mode                      = "Prevention"
custom_rule {
    name                           = "Rule1"
    enabled                        = true
    priority                       = 1
    rate_limit_duration_in_minutes = 1
    rate_limit_threshold           = 10
    type                           = "MatchRule"
    action                         = "Block"

    match_condition {
      match_variable               = "RemoteAddr"
      operator                     = "IPMatch"
      negation_condition           = false
      match_values                 = ["0.0.0.0/0"]
    }
  }
  tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-waf-policy"}
  )
}*/
#-------------- admin portal-----------------------------------------
/*# Security policy for admnin Portal
resource "azurerm_cdn_frontdoor_security_policy" "frontdoor-security-policy-admin" {
  name                                 = "${var.project_name}-${var.project_environment}-admin-frontdoor-security-policy"
  cdn_frontdoor_profile_id             = azurerm_cdn_frontdoor_profile.frontdoor-profile-admin.id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.waf_policy.id

      association {
        domain {
          cdn_frontdoor_domain_id      = azurerm_cdn_frontdoor_endpoint.frontdoor-endpoint-admin.id
        }
        patterns_to_match              = ["/*"]
      }
    }
  }
 
}

# Azure frontdoor for Admin portal
resource "azurerm_cdn_frontdoor_profile" "frontdoor-profile-admin" {
name                                  = "${var.project_name}-${var.project_environment}-admin-front-door-profile"
resource_group_name                   = var.rg_mezzo
sku_name                              = "Standard_AzureFrontDoor"
tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-admin-front-door-profile"}
  )
}
 
# Azure frontdoor endpoint for Admin portal
resource "azurerm_cdn_frontdoor_endpoint" "frontdoor-endpoint-admin" {
name                                  = "${var.project_name}-${var.project_environment}-admin-endpoint"
cdn_frontdoor_profile_id              = azurerm_cdn_frontdoor_profile.frontdoor-profile-admin.id
tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-admin-endpoint"}
  )
}
 
# Origin Group for Admin portal

resource "azurerm_cdn_frontdoor_origin_group" "origin-group-admin" {
  name                                = "${var.project_name}-${var.project_environment}-admin-origin-group"
  cdn_frontdoor_profile_id            = azurerm_cdn_frontdoor_profile.frontdoor-profile-admin.id
  session_affinity_enabled            = false
  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = 10
  health_probe {
    interval_in_seconds                = 100
    protocol                           = "Https"
    path                               = "/"
    request_type                       = "GET"
  }
  load_balancing {
    sample_size                        = 4            # Number of samples for latency measurement
    successful_samples_required        = 3            # Required successful samples for an origin to be considered healthy
    additional_latency_in_milliseconds = 50           # Extra latency to add for load balancing decisions
  }
  
}
 
# Origin for Admin portal

resource "azurerm_cdn_frontdoor_origin" "origin-admin" {
  name                                 = "${var.project_name}-${var.project_environment}-admin-origin"
  cdn_frontdoor_origin_group_id        = azurerm_cdn_frontdoor_origin_group.origin-group-admin.id
  enabled                              = true
  host_name                            =  "${var.static_web_app_url_admin}" 
  priority                             = 1
  weight                               = 1
  certificate_name_check_enabled       = true
  origin_host_header                   = var.static_web_app_url_admin

}
 
# Front door route configuration for Admin portal

resource "azurerm_cdn_frontdoor_route" "route-admin" {
  name                                 = "${var.project_name}-${var.project_environment}-admin-route"
  cdn_frontdoor_endpoint_id            = azurerm_cdn_frontdoor_endpoint.frontdoor-endpoint-admin.id
  cdn_frontdoor_origin_group_id        = azurerm_cdn_frontdoor_origin_group.origin-group-admin.id
  cdn_frontdoor_origin_ids             = [azurerm_cdn_frontdoor_origin.origin-admin.id]
  supported_protocols                  = ["Http", "Https"]
  patterns_to_match                    = ["/*"]
  https_redirect_enabled               = true
  link_to_default_domain               = true
  forwarding_protocol                  = "HttpsOnly"
  cdn_frontdoor_custom_domain_ids      = [azurerm_cdn_frontdoor_custom_domain.admin_custom_domain.id]

}

resource "azurerm_cdn_frontdoor_custom_domain" "admin_custom_domain" {
  name                     = "${var.project_name}-${var.project_environment}-admin-custom-domain"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor-profile-admin.id
  host_name                = "mezzo-testing.experionglobal.dev"  # Replace with your subdomain

  tls {
    certificate_type = "ManagedCertificate"
  }

}

#  Custom Domain for Admin portal
/*
resource "azurerm_dns_cname_record" "dns-frontdoor-admin" {
  name                = "${var.project_name}-${var.project_environment}-admin"
  zone_name           = azurerm_dns_zone.dns_zone.name
  resource_group_name = var.rg_mezzo
  ttl                 = 300
  record              = "${azurerm_cdn_frontdoor_endpoint.frontdoor-endpoint-admin.name}.azurefd.net"
  tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-admin-dns-record"}
  )
}
/*
# Custom Domain for Front Door
resource "azurerm_cdn_frontdoor_custom_domain" "admin-custom-domain" {
  name                     = "${var.project_name}-${var.project_environment}-admin-custom-domain"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor-profile-admin.id
  dns_zone_id              = azurerm_dns_zone.dns_zone.id
  host_name                = "${azurerm_dns_cname_record.dns-frontdoor-admin.name}.${azurerm_dns_zone.dns_zone.name}"

  tls {
    certificate_type = "ManagedCertificate"
  }
}
resource "azurerm_dns_txt_record" "admin-custom-domain-dns-record" {
  name                = join(".", ["_dnsauth", "contoso"])
  zone_name           = azurerm_dns_zone.dns_zone.name
  resource_group_name = var.rg_mezzo
  ttl                 = 3600

  record {
    value = azurerm_cdn_frontdoor_custom_domain.admin-custom-domain.validation_token
  }
}*/

#--------------------Borrower portal----------------

# Security policy for Borrower Portal
/*
resource "azurerm_cdn_frontdoor_security_policy" "frontdoor-security-policy-borrower" {
  name                                 = "${var.project_name}-${var.project_environment}-borrower-frontdoor-security-policy"
  cdn_frontdoor_profile_id             = azurerm_cdn_frontdoor_profile.frontdoor-profile-borrower.id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.waf_policy.id

      association {
        domain {
          cdn_frontdoor_domain_id      = azurerm_cdn_frontdoor_endpoint.frontdoor-endpoint-borrower.id
        }
        patterns_to_match              = ["/*"]
      }
    }
  }
}

# Azure Front Door Profile for borrower portal
resource "azurerm_cdn_frontdoor_profile" "frontdoor-profile-borrower" {
name                                  = "${var.project_name}-${var.project_environment}-borrower-front-door-profile"
resource_group_name                   = var.rg_mezzo
sku_name                              = "Standard_AzureFrontDoor"
tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-borrower-front-door-profile"}
  )
}
 
# Front door endpoint for borrower portal
resource "azurerm_cdn_frontdoor_endpoint" "frontdoor-endpoint-borrower" {
name                                  = "${var.project_name}-${var.project_environment}-borrower-endpoint"
cdn_frontdoor_profile_id              = azurerm_cdn_frontdoor_profile.frontdoor-profile-borrower.id
tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-borrower-endpoint"}
  )
}
 
# Origin Group for borrower portal

resource "azurerm_cdn_frontdoor_origin_group" "origin-group-borrower" {
  name                                = "${var.project_name}-${var.project_environment}-borrower-origin-group"
  cdn_frontdoor_profile_id            = azurerm_cdn_frontdoor_profile.frontdoor-profile-borrower.id
  session_affinity_enabled            = false
  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = 10
  health_probe {
    interval_in_seconds                = 30
    protocol                           = "Https"
    path                               = "/"
  }
  load_balancing {
    sample_size                        = 4             # Number of samples for latency measurement
    successful_samples_required        = 3             # Required successful samples for an origin to be considered healthy
    additional_latency_in_milliseconds = 50            # Extra latency to add for load balancing decisions
  }
  
}
 
#  Origin Group for Borrower portal

resource "azurerm_cdn_frontdoor_origin" "origin-borrower" {
  name                                 = "${var.project_name}-${var.project_environment}-borrower-origin"
  cdn_frontdoor_origin_group_id        = azurerm_cdn_frontdoor_origin_group.origin-group-borrower.id
  enabled                              = true
  host_name                            =  "${var.static_web_app_url_borrower}" # Replace with your backend
  priority                             = 1
  weight                               = 1
  certificate_name_check_enabled       = true
  origin_host_header                   = "${var.static_web_app_url_borrower}"    
  

}
 
# Front door configuration configuration for borrower portal

resource "azurerm_cdn_frontdoor_route" "route-borrower" {
  name                                 = "${var.project_name}-${var.project_environment}-borrower-route"
  cdn_frontdoor_endpoint_id            = azurerm_cdn_frontdoor_endpoint.frontdoor-endpoint-borrower.id
  cdn_frontdoor_origin_group_id        = azurerm_cdn_frontdoor_origin_group.origin-group-borrower.id
  cdn_frontdoor_origin_ids             = [azurerm_cdn_frontdoor_origin.origin-borrower.id]
  supported_protocols                  = ["Http", "Https"]
  patterns_to_match                    = ["/*"]
  https_redirect_enabled               = true
  link_to_default_domain               = true
}
 
#  Custom Domain for borrower portal
/*
resource "azurerm_dns_cname_record" "dns-frontdoor-borrower" {
  name                = "${var.project_name}-${var.project_environment}-borrower"
  zone_name           = azurerm_dns_zone.dns_zone.name
  resource_group_name = var.rg_mezzo
  ttl                 = 300
  record              = "${azurerm_cdn_frontdoor_endpoint.frontdoor-endpoint-borrower.name}.azurefd.net"
tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-borrower-dns-record"}
  )
}

#--------------------Application gateway(Backend)----------------

# Security policy for Borrower Portal
resource "azurerm_cdn_frontdoor_security_policy" "frontdoor-security-policy-appgw" {
  name                                 = "${var.project_name}-${var.project_environment}-appgw-frontdoor-security-policy"
  cdn_frontdoor_profile_id             = azurerm_cdn_frontdoor_profile.frontdoor-profile-appgw.id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.waf_policy.id

      association {
        domain {
          cdn_frontdoor_domain_id      = azurerm_cdn_frontdoor_endpoint.frontdoor-endpoint-appgw.id
        }
        patterns_to_match              = ["/*"]
      }
    }
  }
}

# Azure front door profile for application gateway
resource "azurerm_cdn_frontdoor_profile" "frontdoor-profile-appgw" {
name                                  = "${var.project_name}-${var.project_environment}-appgw-front-door-profile"
resource_group_name                   = var.rg_mezzo
sku_name                              = "Standard_AzureFrontDoor"
tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-appgw-front-door-profile"}
  )
}
 
# Frontdoor enpoint for application gateway
resource "azurerm_cdn_frontdoor_endpoint" "frontdoor-endpoint-appgw" {
name                                  = "${var.project_name}-${var.project_environment}-appgw-endpoint"
cdn_frontdoor_profile_id              = azurerm_cdn_frontdoor_profile.frontdoor-profile-appgw.id
tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-appgw-endpoint"}
  )
}
 
# Origin group application gateway

resource "azurerm_cdn_frontdoor_origin_group" "origin-group-appgw" {
  name                                = "${var.project_name}-${var.project_environment}-appgw-origin-group"
  cdn_frontdoor_profile_id            = azurerm_cdn_frontdoor_profile.frontdoor-profile-appgw.id
  session_affinity_enabled            = false
  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = 10
  health_probe {
    interval_in_seconds                = 30
    protocol                           = "Https"
    path                               = "/"
  }
  load_balancing {
    sample_size                        = 4               # Number of samples for latency measurement
    successful_samples_required        = 3               # Required successful samples for an origin to be considered healthy
    additional_latency_in_milliseconds = 50              # Extra latency to add for load balancing decisions
  }
  
}
 
#  Origin for Application gateway

resource "azurerm_cdn_frontdoor_origin" "origin-appgw" {
  name                                 = "${var.project_name}-${var.project_environment}-appgw-origin"
  cdn_frontdoor_origin_group_id        = azurerm_cdn_frontdoor_origin_group.origin-group-appgw.id
  enabled                              = true
  host_name                            =  var.appgw_public_ip # Replace with your backend
  priority                             = 1
  weight                               = 1
  certificate_name_check_enabled       = true
  origin_host_header                   = var.appgw_public_ip 
  

}
 
#  Front door route configuration for application gateway

resource "azurerm_cdn_frontdoor_route" "route-appgw" {
  name                                 = "${var.project_name}-${var.project_environment}-appgw-route"
  cdn_frontdoor_endpoint_id            = azurerm_cdn_frontdoor_endpoint.frontdoor-endpoint-appgw.id
  cdn_frontdoor_origin_group_id        = azurerm_cdn_frontdoor_origin_group.origin-group-appgw.id
  cdn_frontdoor_origin_ids             = [azurerm_cdn_frontdoor_origin.origin-appgw.id]
  supported_protocols                  = ["Http", "Https"]
  patterns_to_match                    = ["/*"]
  https_redirect_enabled               = true
  link_to_default_domain               = true
  
}
 /*
#  Custom domain for Application gateway

resource "azurerm_dns_cname_record" "dns-frontdoor-appgw" {
  name                = "${var.project_name}-${var.project_environment}-appgw"
  zone_name           = azurerm_dns_zone.dns_zone.name
  resource_group_name = var.rg_mezzo
  ttl                 = 300
  record              = "${azurerm_cdn_frontdoor_endpoint.frontdoor-endpoint-appgw.name}.azurefd.net"
tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-appgw-dns-record"}
  )
}*/










