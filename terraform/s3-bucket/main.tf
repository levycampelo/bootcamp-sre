provider "aws" {
  region = "us-east-1" 
}

resource "aws_s3_bucket" "tf_state" {
  bucket = "bootcamp-tf-state"
  force_destroy = true

  tags = {
    Name        = "Guarda tf-state"
    Environment = "Bootcamp"
  }
}

output "bucket_name" {
  value = aws_s3_bucket.tf_state.bucket
}

