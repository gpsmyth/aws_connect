# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform
resource "aws_lambda_function" "demo_connect_lambda" {
  #checkov:skip=CKV_AWS_117:No VPC required - this Lambda makes no calls to VPC-only resources (no RDS/ElastiCache), learning project
  #checkov:skip=CKV_AWS_116:No DLQ needed - invoked synchronously by Connect, not async/event-driven, so there's nothing to redrive
  #checkov:skip=CKV_AWS_272:Code signing is an enterprise control not applicable to a single-developer learning account
  architectures = ["x86_64"]
  # code_sha256 line removed — this is Computed, don't set it manually
  description                    = null
  filename                       = data.archive_file.lambda_zip.output_path
  function_name                  = "DemoCnnectLambda"
  handler                        = "lambda_function.lambda_handler"
  memory_size                    = 128
  package_type                   = "Zip"
  region                         = "us-west-2"
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.demo_connect_lambda_role.arn
  runtime                        = "python3.14"
  skip_destroy                   = false
  source_code_hash               = filebase64sha256("${path.module}/lambda_src/lambda_function.py")
  tags                           = {}
  tags_all                       = {}
  timeout                        = 3
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
