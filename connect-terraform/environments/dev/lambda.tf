# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform
resource "aws_lambda_function" "demo_connect_lambda" {
  #checkov:skip=CKV_AWS_117:No VPC required - this Lambda makes no calls to VPC-only resources (no RDS/ElastiCache), learning project
  #checkov:skip=CKV_AWS_116:No DLQ needed - invoked synchronously by Connect, not async/event-driven, so there's nothing to redrive
  #checkov:skip=CKV_AWS_272:Code signing is an enterprise control not applicable to a single-developer learning account
  architectures                        = ["x86_64"]
  code_sha256                          = "BTUL/0dVlSu2Ix1LL6vN4jnIsCqnCDRQgiMgZsHR/Zs="
  code_signing_config_arn              = null
  description                          = null
  filename                             = data.archive_file.lambda_zip.output_path
  function_name                        = "DemoCnnectLambda"
  handler                              = "lambda_function.lambda_handler"
  kms_key_arn                          = null
  layers                               = []
  memory_size                          = 128
  package_type                         = "Zip"
  publish                              = null
  publish_to                           = null
  region                               = "us-west-2"
  replace_security_groups_on_destroy   = null
  replacement_security_group_ids       = null
  reserved_concurrent_executions       = -1
  role                                 = aws_iam_role.demo_connect_lambda_role.arn
  runtime                              = "python3.14"
  skip_destroy                         = false
  source_code_hash                     = data.archive_file.lambda_zip.output_base64sha256
  source_kms_key_arn                   = null
  tags                                 = {}
  tags_all                             = {}
  timeout                              = 3
  use_resource_timeout_for_propagation = null
  ephemeral_storage {
    size = 512
  }
  logging_config {
    application_log_level = null
    log_format            = "Text"
    log_group             = "/aws/lambda/DemoCnnectLambda"
    system_log_level      = null
  }
  tracing_config {
    mode = "PassThrough"
  }
}
