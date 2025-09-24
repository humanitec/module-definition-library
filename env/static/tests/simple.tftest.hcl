run "plan" {
  variables {
    values = {
      Key = "value"
    }
  }

  assert {
    condition = output.values.Key == "value"
    error_message = "incorrect data ${jsonencode(nonsensitive(output.values))}"
  }

  command = apply
}
