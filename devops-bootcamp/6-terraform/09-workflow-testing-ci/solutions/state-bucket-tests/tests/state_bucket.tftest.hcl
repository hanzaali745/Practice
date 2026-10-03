# Lab 3 — test the state bucket config with a MOCKED AWS provider: no account, no cost, instant.
mock_provider "aws" {
  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "123456789012"
    }
  }
}

run "bucket_is_private_versioned_and_encrypted" {
  command = apply

  assert {
    condition     = aws_s3_bucket.state.bucket == "devops-bootcamp-tfstate-123456789012"
    error_message = "bucket name must include the account id"
  }
  assert {
    condition = alltrue([
      aws_s3_bucket_public_access_block.state.block_public_acls,
      aws_s3_bucket_public_access_block.state.block_public_policy,
      aws_s3_bucket_public_access_block.state.ignore_public_acls,
      aws_s3_bucket_public_access_block.state.restrict_public_buckets,
    ])
    error_message = "all public access must be blocked"
  }
  assert {
    condition     = aws_s3_bucket_versioning.state.versioning_configuration[0].status == "Enabled"
    error_message = "versioning must be enabled"
  }
  assert {
    condition     = one(aws_s3_bucket_server_side_encryption_configuration.state.rule[*].apply_server_side_encryption_by_default[0].sse_algorithm) == "AES256"
    error_message = "state must be encrypted at rest"
  }
}
