# Lab 1, step 2 — the FOR_EACH version: resources are keyed by name, not position
variable "users" {
  type = map(object({
    team  = string
    admin = bool
  }))
  default = {
    alice = { team = "platform", admin = true }
    bob   = { team = "data", admin = false }
    carol = { team = "platform", admin = false }
  }
}

resource "local_file" "user" {
  for_each = var.users
  filename = "${path.module}/users/${each.key}.txt"
  content  = "team=${each.value.team} admin=${each.value.admin}\n"
}

output "user_files" {
  value = values(local_file.user)[*].filename
}
