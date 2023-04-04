provider "aws" {
   region = "${var.aws_region}"
   default_tags {
      tags = {
         Environment = "dev"
         Service     = "go-api-mysql"
         CreatedBy   = "terraform"
      }
  }
}
