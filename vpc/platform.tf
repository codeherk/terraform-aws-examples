provider "aws" {
   region = "${var.aws_region}"
   default_tags {
      tags = {
         Environment = "dev"
         Service     = "tf-vpc-example"
         CreatedBy   = "terraform"
      }
  }
}
