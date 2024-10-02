provider "aws" {
  region = "us-east-1"  # Defina a região desejada
}

resource "aws_s3_bucket" "tf_state" {
  bucket = "bootcamp-tf-state"
  force_destroy = true

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "Bootcamp"
  }
}

output "bucket_name" {
  value = aws_s3_bucket.tf_state.bucket
}

