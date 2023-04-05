provider "aws" {
   region = "${var.aws_region}"
   default_tags {
      tags = {
         Environment = "${var.environment}"
         Service     = "go-api-mysql"
         CreatedBy   = "terraform"
      }
  }
}
