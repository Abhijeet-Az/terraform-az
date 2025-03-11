# Create a new cloudamqp instance
resource "cloudamqp_instance" "instance" {
  name   = "cloudamqp-${var.environment}-${var.location}-${var.azure_config[var.environment].suffix}"
  plan   = var.azure_config[var.environment].cloudamqp_plan
  region = "azure-arm::${var.location}"
}
