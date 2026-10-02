# Lab 1 — something to look at in state
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "local_file" "app" {
  filename = "${path.module}/app-${random_string.suffix.result}.txt"
  content  = "managed by terraform\n"
}
