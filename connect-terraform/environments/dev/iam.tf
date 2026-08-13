# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform from "DemoCnnectLambda-role-qbq5963s/arn:aws:iam::<account_id>:policy/service-role/AWSLambdaBasicExecutionRole-02fa59a6-d874-473b-bf44-f8b43b412b5f"
# resource "aws_iam_role_policy_attachment" "demo_connect_lambda_logs" {
#   policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/service-role/AWSLambdaBasicExecutionRole-02fa59a6-d874-473b-bf44-f8b43b412b5f"
#   role       = "DemoCnnectLambda-role-qbq5963s"
# }

resource "aws_iam_role_policy_attachment" "demo_connect_lambda_logs" {
  role       = aws_iam_role.demo_connect_lambda_role.name
  policy_arn = aws_iam_policy.demo_connect_lambda_logs_policy.arn
}

# __generated__ by Terraform from "arn:aws:iam::<account_id>:policy/service-role/AWSLambdaBasicExecutionRole-02fa59a6-d874-473b-bf44-f8b43b412b5f"
resource "aws_iam_policy" "demo_connect_lambda_logs_policy" {
  delay_after_policy_creation_in_ms = null
  description                       = null
  name                              = "AWSLambdaBasicExecutionRole-02fa59a6-d874-473b-bf44-f8b43b412b5f"
  path                              = "/service-role/"
  policy = jsonencode({
    Statement = [{
      Action   = "logs:CreateLogGroup"
      Effect   = "Allow"
      Resource = "arn:aws:logs:us-west-2:${data.aws_caller_identity.current.account_id}:*"
      }, {
      Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
      Effect   = "Allow"
      Resource = ["arn:aws:logs:us-west-2:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/DemoCnnectLambda:*"]
    }]
    Version = "2012-10-17"
  })
  tags     = {}
  tags_all = {}
}

# __generated__ by Terraform from "DemoCnnectLambda-role-qbq5963s"
resource "aws_iam_role" "demo_connect_lambda_role" {
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
  description           = null
  force_detach_policies = false
  max_session_duration  = 3600
  name                  = "DemoCnnectLambda-role-qbq5963s"
  path                  = "/service-role/"
  permissions_boundary  = null
  tags                  = {}
  tags_all              = {}
}
