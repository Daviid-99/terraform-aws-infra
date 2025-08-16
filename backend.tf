terraform {
  backend "s3" {
    bucket         = "my-production-bucket-12345"   # replace with your bucket name
    key            = "ecs-app/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"             # replace with your DynamoDB table
    encrypt        = true
  }
}

