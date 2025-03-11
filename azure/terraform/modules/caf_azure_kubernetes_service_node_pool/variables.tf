// Common Variables
//**********************************************************************************************

variable "location" {
  description = "(Required) The cafoud region where resources will be deployed into."
}
variable "caf_application" {
  type        = string
  description = "(Required) The name of the application where the resource is being deployed"
}
//**********************************************************************************************

// Required Variables
//**********************************************************************************************
// Azure Kubernetes Services cluster variables - additional node_pool
//**********************************************************************************************
//The name of a node pool may only contain lowercase alphanumeric characters and must begin with a lowercase letter. For Linux node pools, the length must be between 1 and 12 characters. For Windows node pools, the length must be between 1 and 6 characters.
variable "caf_kubernetes_node_pool_name" {
  description = "(Required) The name of the Node Pool which should be created within the Kubernetes cluster. Changing this forces a new resource to be created. A Windows Node Pool cannot have a name longer than 6 characters."
  type        = string
  default     = "cbcorepool"
}

variable "caf_kubernetes_node_pool_kubernetes_cluster_id" {
  description = "(Required) The ID of the Kubernetes cluster where this Node Pool should exist. Changing this forces a new resource to be created. The type of Default Node Pool for the Kubernetes cluster must be VirtualMachineScaleSets to attach multiple node pools."
  type        = string
}


// Optional Variables
//**********************************************************************************************
// Azure Kubernetes Services cluster optional variables - additional node_pool
//**********************************************************************************************
variable "caf_kubernetes_node_pool_vm_size" {
  description = "(Optional) The SKU which should be used for the Virtual Machines used in this Node Pool. Changing this forces a new resource to be created."
  type        = string
  default     = "Standard_DS2_v2"
}
variable "caf_kubernetes_node_pool_availability_zones" {
  description = "(Optional) A list of Availability Zones where the Nodes in this Node Pool should be created in. Changing this forces a new resource to be created."
  type        = list(number)
  default     = [1, 2, 3]
}
variable "caf_kubernetes_node_pool_enable_auto_scaling" {
  description = "(Optional) Whether to enable auto-scaler. Defaults to false."
  type        = bool
  default     = true
}
variable "caf_kubernetes_node_pool_enable_host_encryption" {
  description = "(Optional) Should the nodes in this Node Pool have host encryption enabled? Defaults to false. Encryption at host feature must be enabled on the subscription: https://docs.microsoft.com/azure/virtual-machines/linux/disks-enable-host-based-encryption-cafi"
  type        = bool
  default     = false
}
variable "caf_kubernetes_node_pool_enable_node_public_ip" {
  description = "(Optional) Should each node have a Public IP Address? Defaults to false."
  type        = bool
  default     = false
}
//NOTE: FIPS support is in Public Preview 
variable "caf_kubernetes_node_pool_fips_enabled" {
  description = "(Optional) Should the nodes in this Node Pool have Federal Information Processing Standard enabled? Changing this forces a new resource to be created.FIPS support is in Public Preview"
  type        = bool
  default     = false
}
variable "caf_kubernetes_node_pool_kubelet_disk_type" {
  description = "(Optional) The type of disk used by kubelet. At this time the only possible value is OS."
  type        = string
  default     = null
}
variable "caf_kubernetes_node_pool_eviction_policy" {
  description = "(Optional) The Eviction Policy which should be used for Virtual Machines within the Virtual Machine Scale Set powering this Node Pool. Possible values are Deallocate and Delete. Changing this forces a new resource to be created."
  type        = string
  default     = null
}
variable "caf_kubernetes_node_pool_max_pods" {
  description = "(Optional) The maximum number of pods that can run on each agent. Changing this forces a new resource to be created."
  type        = number
  default     = 25
}
variable "caf_kubernetes_node_pool_mode" {
  description = "(Optional) Should this Node Pool be used for System or User resources? Possible values are System and User. Defaults to User."
  type        = string
  default     = "User"
}
variable "caf_kubernetes_node_pool_node_labels" {
  description = "(Optional) A map of Kubernetes labels which should be applied to nodes in this Node Pool. Changing this forces a new resource to be created."
  type        = map(string)
  default     = {}
}
variable "caf_kubernetes_node_pool_node_public_ip_prefix_id" {
  description = "(Optional) Resource ID for the Public IP Addresses Prefix for the nodes in this Node Pool."
  type        = string
  default     = null
}
variable "caf_kubernetes_node_pool_node_taints" {
  description = "(Optional) A list of Kubernetes taints which should be applied to nodes in the agent pool (e.g key=value:NoSchedule). Changing this forces a new resource to be created."
  type        = list(string)
  #default     = []
}
variable "caf_kubernetes_node_pool_orchestrator_version" {
  description = "(Optional) Version of Kubernetes used for the Agents. If not specified, the latest recommended version will be used at provisioning time (but won't auto-upgrade). This version must be supported by the Kubernetes cluster - as such the version of Kubernetes used on the cluster/Control Plane may need to be upgraded first."
  type        = string
  default     = null
}
variable "caf_kubernetes_node_pool_os_disk_size_gb" {
  description = "(Optional) The Agent Operating System disk size in GB. Changing this forces a new resource to be created."
  type        = number
  default     = null
}
variable "caf_kubernetes_node_pool_os_disk_type" {
  description = "(Optional) The type of disk which should be used for the Operating System. Possible values are Ephemeral and Managed. Defaults to Managed. Changing this forces a new resource to be created."
  type        = string
  default     = "Managed"
}
variable "caf_kubernetes_node_pool_os_sku" {
  description = "(Optional) OsSKU to be used to specify Linux OSType. Not applicable to Windows OSType. Possible values incafude: Ubuntu, CBLMariner. Defaults to Ubuntu. Changing this forces a new resource to be created."
  type        = string
  default     = null
}
//This requires that the Preview Feature Microsoft.ContainerService/PodSubnetPreview is enabled and the Resource Provider is re-registered.
variable "caf_kubernetes_node_pool_pod_subnet_id" {
  description = "(Optional) The ID of the Subnet where the pods in the default Node Pool should exist. Changing this forces a new resource to be created."
  type        = string
  default     = null
}
variable "caf_kubernetes_node_pool_os_type" {
  description = "(Optional) The Operating System which should be used for this Node Pool. Changing this forces a new resource to be created. Possible values are Linux and Windows. Defaults to Linux."
  type        = string
  default     = "Linux"
}
variable "caf_kubernetes_node_pool_priority" {
  description = "(Optional) The Priority for Virtual Machines within the Virtual Machine Scale Set that powers this Node Pool. Possible values are Regular and Spot. Defaults to Regular. Changing this forces a new resource to be created. When setting priority to Spot - you must configure an eviction_policy, spot_max_price and add the applicable node_labels and node_taints."
  type        = string
  default     = "Regular"
}
variable "caf_kubernetes_node_pool_proximity_placement_group_id" {
  description = "(Optional) The ID of the Proximity Placement Group where the Virtual Machine Scale Set that powers this Node Pool will be placed. Changing this forces a new resource to be created."
  type        = string
  default     = null
}
variable "caf_kubernetes_node_pool_spot_max_price" {
  description = "(Optional) The maximum price you're willing to pay in USD per Virtual Machine. Valid values are -1 (the current on-demand price for a Virtual Machine) or a positive value with up to five decimal places. Changing this forces a new resource to be created. This field can only be configured when priority is set to Spot."
  type        = number
  default     = null
}
variable "caf_kubernetes_node_pool_ultra_ssd_enabled" {
  description = "(Optional) Used to specify whether the UltraSSD is enabled in the Default Node Pool. Defaults to false."
  type        = bool
  default     = false
}
variable "tags" {
  description = "(Optional) A mapping of tags to assign to the resource. At this time there's a bug in the AKS API where Tags for a Node Pool are not stored in the correct case"
  type        = map(any)
  default     = {}
}
//Max surge percent values can be a minimum of 1% and a maximum of 100%. For production node pools, we recommend a max_surge setting of 33%. If a percentage is provided, the number of surge nodes is calculated from the node_count value on the current cluster. Node surge can allow a cluster to have more nodes than max_count during an upgrade. Ensure that your cluster has enough IP space during an upgrade.
variable "caf_kubernetes_node_pool_max_surge" {
  description = "(Optional) The maximum number or percentage of nodes which will be added to the Node Pool size during an upgrade.If a percentage is provided, the number of surge nodes is calculated from the current node count on the cluster. Node surge can allow a cluster to have more nodes than max_count during an upgrade. Ensure that your cluster has enough IP space during an upgrade."
  type        = string
  default     = "33%"
}
variable "caf_kubernetes_node_pool_vnet_subnet_id" {
  description = "(Optional) The ID of the Subnet where this Node Pool should exist. At this time the vnet_subnet_id must be the same for all node pools in the cluster. A route table must be configured on this Subnet."
  type        = string
  default     = null
}
//If enable_auto_scaling is set to true, then the following fields can also be configured:
variable "caf_kubernetes_node_pool_max_count" {
  description = "(Required) The maximum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be greater than or equal to min_count."
  type        = number
  # default     = 10
}
variable "caf_kubernetes_node_pool_min_count" {
  description = "(Required) The minimum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be less than or equal to max_count."
  type        = number
  default     = 1
}
variable "caf_kubernetes_node_pool_node_count" {
  description = "(Optional) The initial number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be a value in the range min_count - max_count. If you're specifying an initial number of nodes you may wish to use Terraform's ignore_changes functionality to ignore changes to this field."
  type        = number
  default     = 3
}
//If a percentage is provided, the number of surge nodes is calculated from the node_count value on the current cluster. Node surge can allow a cluster to have more nodes than max_count during an upgrade. Ensure that your cluster has enough IP space during an upgrade.
variable "caf_kubernetes_node_pool_upgrade_max_surge" {
  description = "(Required) The maximum number or percentage of nodes which will be added to the Node Pool size during an upgrade"
  type        = number
  default     = null
}
//**********************************************************************************************

//  Azure Kubernetes Services cluster optional variables - additional node_pool - kubelet_config
//**********************************************************************************************
//allowed_unsafe_sysctls: Specifies the allow list of unsafe sysctls command or patterns (ending in *). Changing this forces a new resource to be created."
//container_log_max_line:Specifies the maximum number of container log files that can be present for a container. must be at least 2. Changing this forces a new resource to be created."
//container_log_max_size_mb: Specifies the maximum size (e.g. 10MB) of container log file before it is rotated. Changing this forces a new resource to be created."
//cpu_cfs_quota_enabled:Is CPU CFS quota enforcement for containers enabled? Changing this forces a new resource to be created."
//cpu_cfs_quota_period: Specifies the CPU CFS quota period value. Changing this forces a new resource to be created."
//cpu_manager_policy: Specifies the CPU Manager policy to use. Possible values are none and static, Changing this forces a new"
//image_gc_high_threshold: Specifies the percent of disk usage above which image garbage collection is always run. Must be between 0 and 100. Changing this forces a new resource to be created."
//image_gc_low_threshold: Specifies the percent of disk usage lower than which image garbage collection is never run. Must be between 0 and 100. Changing this forces a new resource to be created."
//pod_max_pid: Specifies the maximum number of processes per pod. Changing this forces a new resource to be created."
//topology_manager_policy: Specifies the Topology Manager policy to use. Possible values are none, best-effort, restricted or single-numa-node. Changing this forces a new resource to be created."

variable "caf_kubernetes_node_pool_kubelet_config" {
  description = "(Optional) Customizing your node configuration allows you to configure or tune your operating system (OS) settings or the kubelet parameters to match the needs of the workloads. When you create an AKS cluster or add a node pool to your cluster, you can customize a subset of commonly used OS and kubelet settings. To configure settings beyond this subset."
  type = map(object({
    allowed_unsafe_sysctls    = list(string)
    container_log_max_line    = number
    container_log_max_size_mb = number
    cpu_cfs_quota_enabled     = bool
    cpu_cfs_quota_period      = string
    cpu_manager_policy        = string
    image_gc_high_threshold   = number
    image_gc_low_threshold    = number
    pod_max_pid               = number
    topology_manager_policy   = string
  }))
  default = {}
}

// Local Variables
//**********************************************************************************************
locals {
  timeout_duration = "2h"
}
//**********************************************************************************************