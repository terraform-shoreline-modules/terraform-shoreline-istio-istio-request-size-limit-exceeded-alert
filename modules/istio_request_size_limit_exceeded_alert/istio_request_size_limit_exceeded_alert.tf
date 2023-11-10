resource "shoreline_notebook" "istio_request_size_limit_exceeded_alert" {
  name       = "istio_request_size_limit_exceeded_alert"
  data       = file("${path.module}/data/istio_request_size_limit_exceeded_alert.json")
  depends_on = [shoreline_action.invoke_increase_request_limit]
}

resource "shoreline_file" "increase_request_limit" {
  name             = "increase_request_limit"
  input_file       = "${path.module}/data/increase_request_limit.sh"
  md5              = filemd5("${path.module}/data/increase_request_limit.sh")
  description      = "Increase the configured size limit for requests in Istio configuration."
  destination_path = "/tmp/increase_request_limit.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_increase_request_limit" {
  name        = "invoke_increase_request_limit"
  description = "Increase the configured size limit for requests in Istio configuration."
  command     = "`chmod +x /tmp/increase_request_limit.sh && /tmp/increase_request_limit.sh`"
  params      = ["ISTIO_DEPLOYMENT_NAME"]
  file_deps   = ["increase_request_limit"]
  enabled     = true
  depends_on  = [shoreline_file.increase_request_limit]
}

