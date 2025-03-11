data "kubectl_server_version" "current" {}

locals {
  files = fileset("${path.module}/manifests", "*.yaml")
  docs = flatten([
    for k, v in data.kubectl_file_documents.docs :
    [
      for i, doc in v.documents :
      {
        file    = k
        index   = i
        content = doc
      }
    ]
  ])
}

data "kubectl_file_documents" "docs" {
  for_each = { for file in local.files : file => "${path.module}/manifests/${file}" }

  content = file(each.value)
}

resource "kubectl_manifest" "test" {
  for_each = { for doc in local.docs : "${doc.file}-${doc.index}" => doc }

  yaml_body = each.value.content
}