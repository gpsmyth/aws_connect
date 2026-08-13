data "aws_caller_identity" "current" {}

output "account_id" {
  description = "AWS account ID for the configured provider credentials."
  value       = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  description = "ARN of the IAM principal used by Terraform."
  value       = data.aws_caller_identity.current.arn
}

output "caller_user_id" {
  description = "Unique IAM principal user ID used by Terraform."
  value       = data.aws_caller_identity.current.user_id
}

output "caller_identity_summary" {
  description = "Human-readable summary of the AWS identity currently used by Terraform."
  value = format(
    "Terraform is using principal %s in account %s (user ID %s).",
    data.aws_caller_identity.current.arn,
    data.aws_caller_identity.current.account_id,
    data.aws_caller_identity.current.user_id,
  )
}