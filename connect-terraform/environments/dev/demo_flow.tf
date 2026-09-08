resource "aws_connect_contact_flow" "demo_flow" {
  instance_id = aws_connect_instance.this.id
  name        = "DemoFlow"
  type        = "CONTACT_FLOW"
  content = templatefile("${path.module}/flows/demo_flow_output.json.tftpl", {
    hours_of_operation_arn = aws_connect_hours_of_operation.nine_to_five_nz.arn
    gerrys_queue_arn       = aws_connect_queue.gerrys_queue.arn
  })
}

resource "aws_connect_contact_flow" "demo_flow_lambda" {
  instance_id = aws_connect_instance.this.id
  name        = "DemoFlow-lambda"
  description = "Demoflow using lambda"
  type        = "CONTACT_FLOW"
  content = templatefile("${path.module}/flows/demo_flow_lambda.json.tftpl", {
    hours_of_operation_arn = aws_connect_hours_of_operation.nine_to_five_nz.arn
    gerrys_queue_arn       = aws_connect_queue.gerrys_queue.arn
    lambda_arn              = aws_lambda_function.demo_connect_lambda.arn
  })
}

resource "aws_connect_contact_flow" "demo_flow_lambda_with_attributes" {
  instance_id = aws_connect_instance.this.id
  name        = "DemoFlow-attributes"
  description = "Demoflow using lambda with attributes"
  type        = "CONTACT_FLOW"
  content = templatefile("${path.module}/flows/demo_flow_lambda_with_attributes.json.tftpl", {
    hours_of_operation_arn = aws_connect_hours_of_operation.nine_to_five_nz.arn
    gerrys_queue_arn       = aws_connect_queue.gerrys_queue.arn
    lambda_arn              = aws_lambda_function.demo_connect_lambda.arn
  })
}

resource "aws_connect_contact_flow" "demo_flow_lambda_with_queues" {
  instance_id = aws_connect_instance.this.id
  name        = "DemoFlow-queues"
  description = "Demoflow using lambda with a contacts attributes block and a 2nd queue"
  type        = "CONTACT_FLOW"
  content = templatefile("${path.module}/flows/demo_flow_queues.json.tftpl", {
    hours_of_operation_arn = aws_connect_hours_of_operation.nine_to_five_nz.arn
    gerrys_queue_arn       = aws_connect_queue.gerrys_queue.arn
    priority_queue_arn     = aws_connect_queue.priority_queue.arn
    lambda_arn             = aws_lambda_function.demo_connect_lambda.arn
  })
}
