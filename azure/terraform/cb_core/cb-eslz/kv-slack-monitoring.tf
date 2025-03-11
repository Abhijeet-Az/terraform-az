resource "azurerm_monitor_action_group" "action_group" {
  name                = "action-group-${var.environment}-${var.location}-${var.suffix}"
  resource_group_name = module.caf_resource_group.caf_resource_group.name
  short_name          = "slk-ag-${var.suffix}"
  logic_app_receiver {
    name                    = "logic-app-slack-${var.environment}-${var.location}-${var.suffix}"
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
  name                = "logic-app-slack-${var.environment}-${var.location}-${var.suffix}"
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
  name         = "logic-app-slack-trigger-${var.environment}-${var.location}-${var.suffix}"
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
                        "properties": {
                            "type": "object",
                            "properties": {}
                        },
                        "conditionType": {
                            "type": "string"
                        },
                        "condition": {
                            "type": "object",
                            "properties": {
                                "windowSize": {
                                    "type": "string"
                                },
                                "allOf": {
                                    "type": "array",
                                    "items": {
                                        "type": "object",
                                        "properties": {
                                            "searchQuery": {
                                                "type": "string"
                                            },
                                            "metricMeasureColumn": {},
                                            "targetResourceTypes": {
                                                "type": "string"
                                            },
                                            "operator": {
                                                "type": "string"
                                            },
                                            "threshold": {
                                                "type": "string"
                                            },
                                            "timeAggregation": {
                                                "type": "string"
                                            },
                                            "dimensions": {
                                                "type": "array"
                                            },
                                            "metricValue": {
                                                "type": "integer"
                                            },
                                            "failingPeriods": {
                                                "type": "object",
                                                "properties": {
                                                    "numberOfEvaluationPeriods": {
                                                        "type": "integer"
                                                    },
                                                    "minFailingPeriodsToAlert": {
                                                        "type": "integer"
                                                    }
                                                }
                                            },
                                            "linkToSearchResultsUI": {
                                                "type": "string"
                                            },
                                            "linkToFilteredSearchResultsUI": {
                                                "type": "string"
                                            },
                                            "linkToSearchResultsAPI": {
                                                "type": "string"
                                            },
                                            "linkToFilteredSearchResultsAPI": {
                                                "type": "string"
                                            },
                                            "event": {}
                                        },
                                        "required": [
                                            "searchQuery",
                                            "metricMeasureColumn",
                                            "targetResourceTypes",
                                            "operator",
                                            "threshold",
                                            "timeAggregation",
                                            "dimensions",
                                            "metricValue",
                                            "failingPeriods",
                                            "linkToSearchResultsUI",
                                            "linkToFilteredSearchResultsUI",
                                            "linkToSearchResultsAPI",
                                            "linkToFilteredSearchResultsAPI",
                                            "event"
                                        ]
                                    }
                                },
                                "windowStartTime": {
                                    "type": "string"
                                },
                                "windowEndTime": {
                                    "type": "string"
                                }
                            }
                        }
                    }
                },
                "customProperties": {
                    "type": "object",
                    "properties": {}
                }
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
    "Switch": {
      "type": "Switch",
      "expression": "@triggerBody()?['data']?['essentials']?['alertRule']",
      "default": {
        "actions": {
          "For_each": {
            "type": "Foreach",
            "foreach": "@triggerOutputs()?['body']?['data']?['alertContext']?['condition']?['allOf']",
            "actions": {
              "logic-app-slack-action-kv-shared-eastus-001": {
                "type": "Http",
                "inputs": {
                  "uri": "${data.azurerm_key_vault_secret.slack_webhook_uri.value}",
                  "method": "POST",
                  "headers": {
                    "Content-type": "application/json"
                  },
                  "body": {
                    "blocks": [
                      {
                        "text": {
                          "text": "*A secret was updated in @{split(triggerOutputs()?['body/data/essentials/alertTargetIDs'][0], '/')[8]}*\n*Secret Name*: @{split(item()?['dimensions'][0]?['value'],'/')[4]}",
                          "type": "mrkdwn"
                        },
                        "type": "section"
                      },
                      {
                        "text": {
                          "text": "*Investigation Links*\n*Investigation:* <@{triggerOutputs()?['body/data/essentials/investigationLink']}|View Investigation Details>\n*Search Results:* <@{triggerOutputs()?['body/data/alertContext/condition/allOf'][0]['linkToSearchResultsUI']}|View Search Results>",
                          "type": "mrkdwn"
                        },
                        "type": "section"
                      }
                    ],
                    "channel": "C07KH1569U6",
                    "text": "Azure Alert Notification"
                  }
                },
                "runtimeConfiguration": {
                  "contentTransfer": {
                    "transferMode": "Chunked"
                  }
                }
              }
            }
          }
        }
      },
      "cases": {
        "Case": {
          "actions": {
            "For_each_1": {
              "type": "Foreach",
              "foreach": "@triggerOutputs()?['body']?['data']?['alertContext']?['condition']?['allOf']",
              "actions": {
                "Switch_1": {
                  "type": "Switch",
                  "expression": "@item()?['dimensions'][1]?['value']",
                  "default": {
                    "actions": {}
                  },
                  "cases": {
                    "Case 2": {
                      "actions": {
                        "logic-app-slack-action-quota-shared-eastus-001-dev": {
                          "type": "Http",
                          "inputs": {
                            "uri": "${data.azurerm_key_vault_secret.slack_webhook_quota_updates_uri.value}",
                            "method": "POST",
                            "headers": {
                              "Content-type": "application/json"
                            },
                            "body": {
                              "blocks": [
                                {
                                  "text": {
                                    "text": "*A Resource Limit has crossed 75% in CB Core-Dev subscription*\n*Resource Quota Affected - @{item()?['dimensions'][0]?['value']}*",
                                    "type": "mrkdwn"
                                  },
                                  "type": "section"
                                },
                                {
                                  "text": {
                                    "text": "*Investigation Links*\n*Investigation:* <@{triggerOutputs()?['body/data/essentials/investigationLink']}|View Investigation Details>\n*Search Results:* <@{triggerOutputs()?['body/data/alertContext/condition/allOf'][0]['linkToSearchResultsUI']}|View Search Results>",
                                    "type": "mrkdwn"
                                  },
                                  "type": "section"
                                }
                              ],
                              "channel": "C07LY9MQ7TJ",
                              "text": "Azure Alert Notification"
                            }
                          },
                          "runtimeConfiguration": {
                            "contentTransfer": {
                              "transferMode": "Chunked"
                            }
                          }
                        }
                      },
                      "case": "88a89f8b-0b06-4ab8-ac9f-d59c57422ad6"
                    },
                    "Case 3": {
                      "actions": {
                        "logic-app-slack-action-quota-shared-eastus-001-qa": {
                          "type": "Http",
                          "inputs": {
                            "uri": "${data.azurerm_key_vault_secret.slack_webhook_quota_updates_uri.value}",
                            "method": "POST",
                            "headers": {
                              "Content-type": "application/json"
                            },
                            "body": {
                              "blocks": [
                                {
                                  "text": {
                                    "text": "*A Resource Limit has crossed 75% in CB Core-QA subscription*\n*Resource Quota Affected - @{item()?['dimensions'][0]?['value']}*",
                                    "type": "mrkdwn"
                                  },
                                  "type": "section"
                                },
                                {
                                  "text": {
                                    "text": "*Investigation Links*\n*Investigation:* <@{triggerOutputs()?['body/data/essentials/investigationLink']}|View Investigation Details>\n*Search Results:* <@{triggerOutputs()?['body/data/alertContext/condition/allOf'][0]['linkToSearchResultsUI']}|View Search Results>",
                                    "type": "mrkdwn"
                                  },
                                  "type": "section"
                                }
                              ],
                              "channel": "C07LY9MQ7TJ",
                              "text": "Azure Alert Notification"
                            }
                          },
                          "runtimeConfiguration": {
                            "contentTransfer": {
                              "transferMode": "Chunked"
                            }
                          }
                        }
                      },
                      "case": "c96b1579-3994-45ad-bdc8-d2bb03bed4fa"
                    },
                    "Case 4": {
                      "actions": {
                        "logic-app-slack-action-quota-shared-eastus-001-prod": {
                          "type": "Http",
                          "inputs": {
                            "uri": "${data.azurerm_key_vault_secret.slack_webhook_quota_updates_uri.value}",
                            "method": "POST",
                            "headers": {
                              "Content-type": "application/json"
                            },
                            "body": {
                              "blocks": [
                                {
                                  "text": {
                                    "text": "*A Resource Limit has crossed 75% in CB Core-Prod subscription*\n*Resource Quota Affected - @{item()?['dimensions'][0]?['value']}*",
                                    "type": "mrkdwn"
                                  },
                                  "type": "section"
                                },
                                {
                                  "text": {
                                    "text": "*Investigation Links*\n*Investigation:* <@{triggerOutputs()?['body/data/essentials/investigationLink']}|View Investigation Details>\n*Search Results:* <@{triggerOutputs()?['body/data/alertContext/condition/allOf'][0]['linkToSearchResultsUI']}|View Search Results>",
                                    "type": "mrkdwn"
                                  },
                                  "type": "section"
                                }
                              ],
                              "channel": "C07LY9MQ7TJ",
                              "text": "Azure Alert Notification"
                            }
                          },
                          "runtimeConfiguration": {
                            "contentTransfer": {
                              "transferMode": "Chunked"
                            }
                          }
                        }
                      },
                      "case": "7994c938-91d9-46db-afed-6e49669438da"
                    },
                    "Case 5": {
                      "actions": {
                        "logic-app-slack-action-quota-shared-eastus-001-cust-app-int": {
                          "type": "Http",
                          "inputs": {
                            "uri": "${data.azurerm_key_vault_secret.slack_webhook_quota_updates_uri.value}",
                            "method": "POST",
                            "headers": {
                              "Content-type": "application/json"
                            },
                            "body": {
                              "blocks": [
                                {
                                  "text": {
                                    "text": "*A Resource Limit has crossed 75% in Customer Apps(Internal Dev) Subscription*\n*Resource Quota Affected - @{item()?['dimensions'][0]?['value']}*",
                                    "type": "mrkdwn"
                                  },
                                  "type": "section"
                                },
                                {
                                  "text": {
                                    "text": "*Investigation Links*\n*Investigation:* <@{triggerOutputs()?['body/data/essentials/investigationLink']}|View Investigation Details>\n*Search Results:* <@{triggerOutputs()?['body/data/alertContext/condition/allOf'][0]['linkToSearchResultsUI']}|View Search Results>",
                                    "type": "mrkdwn"
                                  },
                                  "type": "section"
                                }
                              ],
                              "channel": "C07LY9MQ7TJ",
                              "text": "Azure Alert Notification"
                            }
                          },
                          "runtimeConfiguration": {
                            "contentTransfer": {
                              "transferMode": "Chunked"
                            }
                          }
                        }
                      },
                      "case": "f0cd098d-47c6-45e3-9972-ee2e8ec9e2ce"
                    },
                    "Case 6": {
                      "actions": {
                        "logic-app-slack-action-quota-shared-eastus-001-cust-app-prod": {
                          "type": "Http",
                          "inputs": {
                            "uri": "${data.azurerm_key_vault_secret.slack_webhook_quota_updates_uri.value}",
                            "method": "POST",
                            "headers": {
                              "Content-type": "application/json"
                            },
                            "body": {
                              "blocks": [
                                {
                                  "text": {
                                    "text": "*A Resource Limit has crossed 75% in Customer Apps(Production) Subscription*\n*Resource Quota Affected - @{item()?['dimensions'][0]?['value']}*",
                                    "type": "mrkdwn"
                                  },
                                  "type": "section"
                                },
                                {
                                  "text": {
                                    "text": "*Investigation Links*\n*Investigation:* <@{triggerOutputs()?['body/data/essentials/investigationLink']}|View Investigation Details>\n*Search Results:* <@{triggerOutputs()?['body/data/alertContext/condition/allOf'][0]['linkToSearchResultsUI']}|View Search Results>",
                                    "type": "mrkdwn"
                                  },
                                  "type": "section"
                                }
                              ],
                              "channel": "C07LY9MQ7TJ",
                              "text": "Azure Alert Notification"
                            }
                          },
                          "runtimeConfiguration": {
                            "contentTransfer": {
                              "transferMode": "Chunked"
                            }
                          }
                        }
                      },
                      "case": "c5a9afc7-3cb1-4292-b012-d7ccc5708b6c"
                    }
                  }
                }
              }
            }
          },
          "case": "Resource Quota Alert"
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