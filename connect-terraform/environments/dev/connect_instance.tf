# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform
resource "aws_connect_instance" "this" {
  auto_resolve_best_voices_enabled = true
  contact_flow_logs_enabled        = true
  contact_lens_enabled             = true
  directory_id                     = null
  early_media_enabled              = true
  identity_management_type         = "CONNECT_MANAGED"
  inbound_calls_enabled            = true
  instance_alias                   = "gps-connect-demo"
  multi_party_conference_enabled   = true
  outbound_calls_enabled           = true
  region                           = "us-west-2"
  tags                             = {}
  tags_all                         = {}
}
