# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform from "arn:aws:iam::<account-id>:policy/DemoConnectLambda-BedrockInvoke"
resource "aws_iam_policy" "demo_connect_lambda_bedrock_policy" {
  delay_after_policy_creation_in_ms = null
  description                       = null
  name                              = "DemoConnectLambda-BedrockInvoke"
  path                              = "/"
  policy = jsonencode({
    Statement = [{
      Action   = "bedrock:InvokeModel"
      Effect   = "Allow"
      Resource = ["arn:aws:bedrock:us-west-2:${data.aws_caller_identity.current.account_id}:inference-profile/us.amazon.nova-micro-v1:0", "arn:aws:bedrock:*::foundation-model/amazon.nova-micro-v1:0"]
    }]
    Version = "2012-10-17"
  })
  tags     = {}
  tags_all = {}
}

# __generated__ by Terraform
# resource "aws_iam_role_policy_attachment" "demo_connect_lambda_bedrock" {
#   policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/DemoConnectLambda-BedrockInvoke"
#   role       = "DemoCnnectLambda-role-qbq5963s"
# }
# This part is left as a reminder to not hard-code valuess
# Instead, Terraform doesn't understand that this attachment depends on the policy 
# and role resources — it's coincidentally pointing at the same values via hardcoded strings, 
# not structurally linked in Terraform's dependency graph. If you ever renamed the policy, 
# deleted and recreated the role, or reorganized things, this attachment wouldn't 
# automatically pick up the change — it'd silently keep pointing at the old literal 
# string until you noticed a mismatch. 
# The reference form is what makes Terraform actually know these three resources are 
# connected.

resource "aws_iam_role_policy_attachment" "demo_connect_lambda_bedrock" {
  role       = aws_iam_role.demo_connect_lambda_role.name
  policy_arn = aws_iam_policy.demo_connect_lambda_bedrock_policy.arn
}