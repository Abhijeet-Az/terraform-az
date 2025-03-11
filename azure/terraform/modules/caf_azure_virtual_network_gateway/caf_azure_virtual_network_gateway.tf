resource "azurerm_virtual_network_gateway" "virtual_netwok_gateway" {
  name                = "vgw-${var.env_prefix}-${var.location}-${var.suffix}"
  location            = var.location
  resource_group_name = var.vgw_rg_name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = var.vgw_sku

  ip_configuration {
    name                          = "default"
    public_ip_address_id          = var.vgw_pip_id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.vgw_subnet_id
  }

  custom_route {
    address_prefixes = []
  }

  vpn_client_configuration {
    aad_audience         = "41b23e61-6c1e-4545-b367-cd054e0ed4b4"
    aad_issuer           = "https://sts.windows.net/c09fae9e-0750-4861-a01d-0dd6d9721be7/"
    aad_tenant           = "https://login.microsoftonline.com/c09fae9e-0750-4861-a01d-0dd6d9721be7"
    address_space        = ["172.160.0.0/16"]
    vpn_auth_types       = ["AAD"]
    vpn_client_protocols = ["OpenVPN"]
    # root_certificate {
    #   name             = "Main_Aline_generated"
    #   public_cert_data = "MIIDAzCCAeugAwIBAgIUVNkrxuiYg9pUI2V6XqMAZMvMSqMwDQYJKoZIhvcNAQELBQAwETEPMA0GA1UEAwwGVlBOIENBMB4XDTI0MDUxNTIxMTAwOVoXDTM0MDUxMzIxMTAwOVowETEPMA0GA1UEAwwGVlBOIENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAjyJ0hNq2RRPc6+8vIp0yibgwTr/fmRJA8+tffXaNBf/Nk7LYCqeXr1bwASydoUigggzAJgpxzVx4Ikla4yJggOU/mpBzaZiTWWCs6QGfiyQf8iUru6BP8M1z47S868SGalRcoYg6gnHQrSRjA7GcEDIPih+6/VixDG/6zEmHOtkwE7etA9xQIuc/VfFMNW3cmoEBfo5ZL5cg0a+sDTMD4+YYVRZ9I6Gv0A/d2SpyHoAYVk6s84Xwxs5cAp+FjdE9k43Vx4Ho7Ry5wkdgY8OxjRsb9sBPUIDZycCZY2NauaoFOC3t4XQM/g6vtvu2N3eJfa72GUp0de4JMPRSmFDgdwIDAQABo1MwUTAdBgNVHQ4EFgQUoRl0Tmdkq9qyc3+DeVeKw5S4s9IwHwYDVR0jBBgwFoAUoRl0Tmdkq9qyc3+DeVeKw5S4s9IwDwYDVR0TAQH/BAUwAwEB/zANBgkqhkiG9w0BAQsFAAOCAQEAYIEj67Hpx8ZkEYReVzHDNl4KawQmOeo1MNEH2qk9xTaf+6XLbK8nnrwS/99fbOUQ0Up7TX1xGNPg9a1diF3O3eC3As0YmUnGcfTRkadFw1uZFEQ1txg+7MebOFx9JLDaRtzZvCoGle7yYUagrfNqicykJgM4eBF/jnh/GIe1UZnTRLRR2SvvB0k2dC7qbei07NlPmrx6RrxIcY+mYgNUd1KNOB5pL45AoR5xKdo1HUitP0EbCERl60e2W4dHwJLE7sPL5iurghitNfbjyBA93vzl4SKWsbfMCpt8mEjRp0IWvXA7uuBWi5xUL2gFeSZBK9ABfGNQF3WJeiquWTtrqA=="
    # }
  }
  lifecycle {
    prevent_destroy = true
  }
}