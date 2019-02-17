variable "region" {}
variable "env" {}
variable "company" {}
variable "my_ip_cidr" {}
variable "vpc_cidr" {}
variable "azs" {}
variable "public_subnet_cidrs" {}
variable "public_subnet_id" {}
variable "private_subnet_cidrs" {}
variable "ephemeral_subnet_cidrs" {}
variable "key_path" {}
variable "key_name" {}

variable "vpc_id" {}

// variable "dns_zone_id"		       {} 

variable "tier" {}
variable "ec2_app_user" {}
variable "ec2_app_cluster_health_check_type" {}
variable "ec2_app_storage_type" {}
variable "ec2_app_storage_size" {}
variable "ec2_app_cluster_desired_capacity" {}
variable "ec2_app_cluster_min_size" {}
variable "ec2_app_cluster_max_size" {}
variable "ec2_app_instance_type" {}

module "app" {
  source            = "modules/app"
  env               = "${var.env}"
  region            = "${var.region}"
  short_region      = "${replace(var.region,"-","")}"
  azs               = "${var.azs}"
  public_subnet_id = "${var.public_subnet_id}"
  ephem_subnet_ids  = "${var.public_subnet_id}"
  vpc_id            = "${var.vpc_id}"
  vpc_cidr          = "${var.vpc_cidr}"
  instance_type     = "${var.ec2_app_instance_type}"
  storage_type      = "${var.ec2_app_storage_type}"
  storage_size      = "${var.ec2_app_storage_size}"
  shell_username    = "${var.ec2_app_user}"
  key_path          = "${var.key_path}"
  key_name          = "${var.key_name}"
  my_ip_cidr        = "${var.my_ip_cidr}"
  company           = "${var.company}"
  desired_capacity  = "${var.ec2_app_cluster_desired_capacity}"
  min_size          = "${var.ec2_app_cluster_min_size}"
  max_size          = "${var.ec2_app_cluster_max_size}"
  health_check_type = "EC2"
  tier              = "${var.tier}"

  providers = {
    aws = "aws.primary"
  }
}

//  zone_id           = "${var.dns_zone_id}"
//  ssl_cert_arn      = "${var.ssl_cert_arn}"

