# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform from "7541c0d9-c664-43e9-8747-72dbe1cc5823:758de154-51e9-4381-8dea-621e4ae8af66"
resource "aws_connect_hours_of_operation" "nine_to_five_nz" {
  description = "NZ"
  instance_id = aws_connect_instance.this.id
  name        = "9to5NZ"
  time_zone   = "NZ"
  config {
    day = "FRIDAY"
    end_time {
      hours   = 21
      minutes = 0
    }
    start_time {
      hours   = 9
      minutes = 0
    }
  }
  config {
    day = "MONDAY"
    end_time {
      hours   = 21
      minutes = 0
    }
    start_time {
      hours   = 9
      minutes = 0
    }
  }
  config {
    day = "THURSDAY"
    end_time {
      hours   = 21
      minutes = 0
    }
    start_time {
      hours   = 9
      minutes = 0
    }
  }
  config {
    day = "TUESDAY"
    end_time {
      hours   = 21
      minutes = 0
    }
    start_time {
      hours   = 9
      minutes = 0
    }
  }
  config {
    day = "WEDNESDAY"
    end_time {
      hours   = 21
      minutes = 0
    }
    start_time {
      hours   = 9
      minutes = 0
    }
  }
}

# __generated__ by Terraform from "7541c0d9-c664-43e9-8747-72dbe1cc5823:00d19a70-83af-47f9-bf77-c135d010e48d"
resource "aws_connect_queue" "priority_queue" {
  description           = "priorityQueue"
  hours_of_operation_id = aws_connect_hours_of_operation.nine_to_five_nz.hours_of_operation_id
  instance_id           = aws_connect_instance.this.id
  max_contacts          = 0
  name                  = "priorityQueue"
  status                = "ENABLED"
}

# __generated__ by Terraform from "7541c0d9-c664-43e9-8747-72dbe1cc5823:6733c40b-9ff4-45c7-9d1b-ea86c1ddc0d5"
resource "aws_connect_queue" "gerrys_queue" {
  description           = null
  hours_of_operation_id = aws_connect_hours_of_operation.nine_to_five_nz.hours_of_operation_id
  instance_id           = aws_connect_instance.this.id
  max_contacts          = 0
  name                  = "gerrysQueue"
  status                = "ENABLED"
}
