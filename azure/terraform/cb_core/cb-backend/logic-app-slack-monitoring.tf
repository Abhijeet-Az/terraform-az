resource "azurerm_monitor_action_group" "action_group" {
  name                = "action-group-${var.environment}-${var.location}-${var.azure_config[var.environment].env_prefix}"
  resource_group_name = module.caf_resource_group.caf_resource_group.name
  short_name          = "slk-ag-${var.azure_config[var.environment].env_prefix}"
  logic_app_receiver {
    name                    = "logic-app-slack-${var.environment}-${var.location}-${var.azure_config[var.environment].env_prefix}"
    resource_id             = azurerm_logic_app_workflow.logicapp.id
    callback_url            = azurerm_logic_app_trigger_http_request.logicapp-trigger.callback_url
    use_common_alert_schema = true
  }
  depends_on = [azurerm_logic_app_workflow.logicapp, azurerm_logic_app_trigger_http_request.logicapp-trigger]
  lifecycle {
    prevent_destroy = true
  }
}


resource "azurerm_logic_app_workflow" "logicapp" {
  name                = "logic-app-slack-${var.environment}-${var.location}-${var.azure_config[var.environment].env_prefix}"
  resource_group_name = module.caf_resource_group.caf_resource_group.name
  location            = var.location

  parameters = {
    "$connections" = jsonencode({
    })
  }

  workflow_parameters = {
    "$connections" = jsonencode({
      "defaultValue" = {}
      "type"         = "Object"
    })
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_logic_app_trigger_http_request" "logicapp-trigger" {
  name         = "logic-app-slack-trigger-${var.environment}-${var.location}-${var.azure_config[var.environment].env_prefix}"
  logic_app_id = azurerm_logic_app_workflow.logicapp.id

  schema = <<SCHEMA
  {
    "type": "object",
    "properties": {
        "schemaId": {
            "type": "string"
        },
        "data": {
            "type": "object",
            "properties": {
                "essentials": {
                    "type": "object",
                    "properties": {
                        "alertId": {
                            "type": "string"
                        },
                        "alertRule": {
                            "type": "string"
                        },
                        "severity": {
                            "type": "string"
                        },
                        "signalType": {
                            "type": "string"
                        },
                        "monitorCondition": {
                            "type": "string"
                        },
                        "monitoringService": {
                            "type": "string"
                        },
                        "alertTargetIDs": {
                            "type": "array",
                            "items": {
                                "type": "string"
                            }
                        },
                        "configurationItems": {
                            "type": "array",
                            "items": {
                                "type": "string"
                            }
                        },
                        "originAlertId": {
                            "type": "string"
                        },
                        "firedDateTime": {
                            "type": "string"
                        },
                        "resolvedDateTime": {
                            "type": "string"
                        },
                        "description": {
                            "type": "string"
                        },
                        "essentialsVersion": {
                            "type": "string"
                        },
                        "alertContextVersion": {
                            "type": "string"
                        },
                        "investigationLink": {
                            "type": "string"
                        }
                    }
                },
                "alertContext": {
                    "type": "object",
                    "properties": {
                        "interval": {
                            "type": "string"
                        },
                        "expression": {
                            "type": "string"
                        },
                        "for": {
                            "type": "string"
                        },
                        "labels": {
                            "type": "object",
                            "properties": {
                                "alertname": {
                                    "type": "string"
                                },
                                "cluster": {
                                    "type": "string"
                                },
                                "container": {
                                    "type": "string"
                                },
                                "instance": {
                                    "type": "string"
                                },
                                "job": {
                                    "type": "string"
                                },
                                "namespace": {
                                    "type": "string"
                                },
                                "pod": {
                                    "type": "string"
                                },
                                "uid": {
                                    "type": "string"
                                }
                            }
                        },
                        "annotations": {
                            "type": "object",
                            "properties": {}
                        },
                        "ruleGroup": {
                            "type": "string"
                        },
                        "monitoringWorkspace": {
                            "type": "string"
                        },
                        "grafanaExploreUrl": {
                            "type": "string"
                        },
                        "conditionType": {
                            "type": "string"
                        }
                    }
                },
                "customProperties": {}
            }
        }
    }
}
SCHEMA

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_logic_app_action_custom" "slack" {
  name         = "slack"
  logic_app_id = azurerm_logic_app_workflow.logicapp.id

  body = <<BODY
{
  "type": "If",
  "expression": {
    "and": [
      {
        "equals": [
          "@triggerBody()?['data']?['essentials']?['monitorCondition']",
          "Fired"
        ]
      }
    ]
  },
  "actions": {
    "logic-app-slack-action-shared-eastus-001": {
      "type": "Http",
      "inputs": {
        "uri": "${data.azurerm_key_vault_secret.slack_webhook_uri.value}",
        "method": "POST",
        "headers": {
          "Content-type": "application/json"
        },
        "body": {
          "channel": "${var.azure_config[var.environment].slack_channel_id}" ,
          "text": "Azure Alert Notification",
          "blocks": [
            {
              "type": "section",
              "text": {
                "type": "mrkdwn",
                "text": "*Labels*\n*Alert Name:* @{triggerOutputs()?['body/data/alertContext/labels/alertname']}\n*Cluster:* @{triggerOutputs()?['body/data/alertContext/labels/cluster']}\n*Container:* @{triggerOutputs()?['body/data/alertContext/labels/container']}\n*Job:* @{triggerOutputs()?['body/data/alertContext/labels/job']}\n*Namespace:* @{triggerOutputs()?['body/data/alertContext/labels/namespace']}"
              }
            },
            {
              "text": {
                "text": "*Investigation Link:* <@{triggerOutputs()?['body/data/essentials/investigationLink']}|View Investigation Details>\n*Grafana URL:* <@{concat('${azurerm_dashboard_grafana.grafana.endpoint}', triggerBody()?['data']?['alertContext']?['grafanaExploreUrl'])}|Drill Down in Grafana>",
                "type": "mrkdwn"
              },
              "type": "section"
            }
          ]
        }
      },
      "runtimeConfiguration": {
        "contentTransfer": {
          "transferMode": "Chunked"
        }
      }
    }
  },
  "else": {
    "actions": {}
  },
  "runAfter": {}
}
BODY

  lifecycle {
    prevent_destroy = true
  }
}
