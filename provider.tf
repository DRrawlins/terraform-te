variable "aws_accountid" {
  default = "505028564994"
}

provider "aws" {
  alias               = "primary"
  region              = "${var.region}"
  profile             = "default"
  allowed_account_ids = ["${var.aws_accountid}"]
}
