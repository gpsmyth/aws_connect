# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform
resource "aws_lambda_permission" "demo_connect_lambda" {
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.demo_connect_lambda.function_name
  principal      = "connect.amazonaws.com"
  source_account = data.aws_caller_identity.current.account_id
  source_arn     = aws_connect_instance.this.arn
  statement_id   = "connect-${aws_connect_instance.this.id}"
}

# __generated__ by Terraform from "7541c0d9-c664-43e9-8747-72dbe1cc5823:dbc27b19-242c-4893-9c50-0208b37fbdcd"
resource "aws_connect_routing_profile" "gerrys_rp" {
  default_outbound_queue_id = aws_connect_queue.gerrys_queue.queue_id
  description               = "gerrys routing profile"
  instance_id               = aws_connect_instance.this.id
  name                      = "gerrys-rp"

  media_concurrencies {
    channel     = "CHAT"
    concurrency = 1
  }
  queue_configs {
    channel  = "CHAT"
    delay    = 0
    priority = 1
    queue_id = aws_connect_queue.priority_queue.queue_id
  }
  queue_configs {
    channel  = "CHAT"
    delay    = 0
    priority = 2
    queue_id = aws_connect_queue.gerrys_queue.queue_id
  }
}
