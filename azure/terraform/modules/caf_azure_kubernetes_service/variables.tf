// Common Variables
//**********************************************************************************************
variable "env_prefix" {
  description = "(Required) The env_prefix where resources will be deployed into. Part of the naming scheme."
}
variable "suffix" {
  description = "(Required) A unique identifier for the deployment. Part of the naming scheme."
}
variable "location" {
  description = "(Required) The cafoud region where resources will be deployed into."
}
variable "caf_application" {
  type        = string
  description = "(Required) The name of the application where the resource is being deployed"
}
//**********************************************************************************************

// Required Variables Azure Kubernetes Services
//**********************************************************************************************
variable "caf_aks_rg" {
  description = "(Required) Specifies AKS Deployment RG (must be empty)"
  type        = string
}

variable "agent_pool_subnet_id" {
  description = "(Required) The ID of the Subnet where the Agents in the Pool should be provisioned."
  type        = string
}

variable "agent_pools" {
  description = "(Optional) List of agent_pools profile for multiple node pools"
  type = list(object({
    name                = string
    count               = number
    vm_size             = string
    os_type             = string
    os_disk_size_gb     = number
    type                = string
    max_pods            = number
    availability_zones  = list(number)
    enable_auto_scaling = bool
    min_count           = number
    max_count           = number
  }))
  default = [{
    name                = "default"
    count               = 2
    vm_size             = "Standard_D4ds_v5"
    os_type             = "Ubuntu"
    os_disk_size_gb     = 128
    type                = "VirtualMachineScaleSets"
    max_pods            = 15
    availability_zones  = [1]
    enable_auto_scaling = true
    min_count           = 2
    max_count           = 5
  }]
}

variable "linux_admin_username" {
  description = "(Optional) User name for authentication to the Kubernetes linux agent virtual machines in the cluster."
  type        = string
  default     = "azureuser"
}

variable "kubernetes_version" {
  description = "(Optional) Version of Kubernetes specified when creating the AKS managed cluster"
  default     = ""
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to all resources."
  type        = map(any)
  default     = {}
}

variable "sku_tier" {
  description = "SKU of the Kubernetes Control Plane"
}
variable "addon_profile" {
  description = "(Optional) AddOn Profile block."
  default = {
    oms_agent_enabled                = false # Enable Container Monitoring
    http_application_routing_enabled = true  # Disable HTTP Application Routing
    kube_dashboard_enabled           = true  # Disable Kubernetes Dashboard
  }
}

variable "default_nodepool_kubernetes_version" {
  description = "Kubernetes Version for Default Node Pool"
}

variable "azurerm_container_registry_id" {
  description = "(Optional) The ID of the Container Registry which the AKS should get AcrPull rights to."
}

variable "network_profile" {
  description = "(Optional) Sets up network profile for Advanced Networking."
  default = {
    # Use azure-cni for advanced networking
    network_plugin = "kubenet"
    # Sets up network policy to be used with Azure CNI. Currently supported values are calico and azure." 
    network_policy     = "calico"
    service_cidr       = "192.168.0.0/16"
    dns_service_ip     = "192.168.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
    # Specifies the SKU of the Load Balancer used for this Kubernetes Cluster. Use standard for when enable agent_pools availability_zones.
    load_balancer_sku = "standard"
  }
}

variable "oms_workspace_id" {
  description = "Workspace ID for OMS AGent for AKS to send logs"
}

variable "prometheus_am_workspace_id" {
  description = "Azure Monitor Workspace ID to stream Data Collection logs"
}

variable "action_group_id" {
  description = "Action Group to link the alerts to"
}

variable "cluster_level_prometheus_rules" {
  description = "List of Prometheus alert rule configurations"
  type = list(object({
    alert      = string
    expression = string
    for        = string
    severity   = number
  }))
}

variable "node_level_prometheus_rules" {
  description = "List of Prometheus alert rule configurations"
  type = list(object({
    alert      = string
    expression = string
    for        = string
    severity   = number
  }))
}

variable "pod_level_prometheus_rules" {
  description = "List of Prometheus alert rule configurations"
  type = list(object({
    alert      = string
    expression = string
    for        = string
    severity   = number
  }))
}

variable "metric_labels_allowlist" {
  default = null
}

variable "metric_annotations_allowlist" {
  default = null
}