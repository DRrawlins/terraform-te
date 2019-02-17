// variable "ssl_cert_arn"         {}
variable "env" {}

variable "azs" {}
variable "region" {}
variable "short_region" {}
variable "public_subnet_id" {}
variable "ephem_subnet_ids" {}
variable "vpc_id" {}
variable "vpc_cidr" {}
variable "instance_type" {}
variable "key_path" {}
variable "key_name" {}
variable "my_ip_cidr" {}
variable "company" {}
variable "shell_username" {}
variable "desired_capacity" {}
variable "min_size" {}
variable "max_size" {}
variable "health_check_type" {}
variable "storage_type" {}
variable "storage_size" {}
variable "tier" {}

// variable "zone_id"				{}

// Get us the newest base ami to update our launch configurations
data "aws_ami" "worker_baseami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "tag:OS_Version"
    values = ["Fedora"]
  }

  filter {
    name   = "tag:Release"
    values = ["29"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "name"
    values = ["Fedora 29 x86_64 Base*"]
  }

  owners = ["505028564994"]
}

resource "aws_elb" "worker" {
  name                        = "${var.env}-${var.tier}-worker-elb"
  connection_draining         = true
  connection_draining_timeout = 60
  cross_zone_load_balancing   = true
  subnets                     = ["${var.public_subnet_id}"]
  security_groups             = ["${aws_security_group.elb.id}"]

#  access_logs {
#    bucket   = "elb-dr-access-logs"
#    interval = 60
#  }

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }

  #    listener {
  #        lb_port             = 443
  #        lb_protocol         = "https"
  #        instance_port       = 80
  #        instance_protocol   = "http"
  #        ssl_certificate_id  = "${var.ssl_cert_arn}"
  #    }

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 5
    timeout             = 5
    target              = "HTTP:80/cacheStamp"
    interval            = 30
  }
  tags {
    Name      = "${var.env}-${var.tier}-elb"
    TERRAFORM = "true"
    ENV       = "${var.env}"
    TIER      = "${var.tier}"
  }
}

/*
resource "aws_lb_cookie_stickiness_policy" "worker" {
      name                      = "${var.env}-${var.tier}-worker-stickiness-policy"
      load_balancer             = "${aws_elb.worker.id}"
      lb_port                   = 80
#      cookie_expiration_period  = 60
}
*/

resource "aws_iam_role" "instance_role" {
  name = "${var.env}-${var.tier}-worker-instance-role"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "instance_policy" {
  name = "${var.env}-${var.tier}-worker-instance-role-policy"
  role = "${aws_iam_role.instance_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [ "s3:List*" ],
        "Resource": [
            "arn:aws:s3:::fedora-amis-dr/*",
            "arn:aws:s3:::fedora-amis-dr"
        ]
    },
    {
        "Effect": "Allow",
        "Action": [ "S3:Get*" ],
        "Resource": [
            "arn:aws:s3:::fedora-amis-dr/*"
        ]
    },
    {
        "Effect": "Allow",
        "Action": [
            "S3:PutObject",
            "S3:AbortMultipartUpload"
        ],
        "Resource": [
            "arn:aws:s3:::fedora-amis-dr/*",
            "arn:aws:s3:::fedora-amis-dr"
        ]
    },
    {
        "Effect": "Allow",
        "Action": [
            "ec2:Describe*",
            "route53:ListHostedZones",
            "route53:ListResourceRecordSets",
            "rds:Describe*",
            "elasticache:Describe*"
        ],
        "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "worker" {
  name = "${var.env}-${var.tier}-worker-instance-profile"
  role = "${aws_iam_role.instance_role.name}"

  # Allows the IAM role enough time to propagate through AWS
  provisioner "local-exec" {
    command = <<EOT
            echo "Sleeping for 10 seconds to allow the IAM role enough time to propagate through AWS";
            sleep 10;
            echo "IAM role should be propagated, proceeding.";
EOT
  }
}

resource "aws_security_group" "webserver" {
  name        = "${var.env}-${var.tier}-worker-access-via-elb-sg"
  vpc_id      = "${var.vpc_id}"
  description = "Allow HTTP, HTTPS inbound traffic from LB only"

  ingress {
    protocol        = "tcp"
    from_port       = 8080
    to_port         = 8080
    cidr_blocks     = ["${var.my_ip_cidr}"]
#    security_groups = ["${aws_security_group.elb.id}"]
  }

  ingress {
    protocol        = "tcp"
    from_port       = 8081
    to_port         = 8081
    cidr_blocks     = ["${var.my_ip_cidr}"]
#    security_groups = ["${aws_security_group.elb.id}"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name      = "${var.env}-${var.tier}-worker-access-via-elb-sg"
    TERRAFORM = "true"
    ENV       = "${var.env}"
    TIER      = "${var.tier}"
  }
}

resource "aws_security_group" "ssh" {
  name        = "${var.env}-${var.tier}-worker-ssh-access-sg"
  vpc_id      = "${var.vpc_id}"
  description = "Allow ssh access"

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["${var.my_ip_cidr}"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name      = "${var.env}-${var.tier}-worker-ssh-access-sg"
    TERRAFORM = "true"
    ENV       = "${var.env}"
    TIER      = "${var.tier}"
  }
}

resource "aws_security_group" "elb" {
  name        = "worker-${var.env}-${var.tier}-elb"
  vpc_id      = "${var.vpc_id}"
  description = "Allow HTTP, HTTPS inbound traffic from anythere and allow all outbound traffic"

  tags {
    Name      = "worker-${var.env}-${var.tier}-elb-sg"
    TERRAFORM = "true"
    ENV       = "${var.env}"
    TIER      = "${var.tier}"
  }

  ingress {
    protocol        = "tcp"
    from_port       = 8080
    to_port         = 8080
    cidr_blocks     = ["${var.my_ip_cidr}"]
  }

  ingress {
    protocol        = "tcp"
    from_port       = 8081
    to_port         = 8081
    cidr_blocks     = ["${var.my_ip_cidr}"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "template_file" "worker" {
  template = "${file("${path.module}/init.sh")}"

  vars {
    TERRAFORM_env   = "${var.env}"
    TERRAFORM_tier  = "${var.tier}"
    TERRAFORM_role  = "worker"
    TERRAFORM_user  = "${var.shell_username}"
    TERRAFORM_hosts = "localhost"
  }
}

resource "aws_launch_configuration" "worker" {
  name_prefix           = "${var.region}-ec2-${var.env}-${var.tier}-launch-config"
  image_id             = "${data.aws_ami.worker_baseami.id}"
  instance_type        = "${var.instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.worker.name}"
  key_name             = "${var.key_name}"
  user_data            = "${data.template_file.worker.rendered}"

  security_groups = [
    "${aws_security_group.webserver.id}",
    "${aws_security_group.ssh.id}",
  ]

  root_block_device = {
    volume_type = "${var.storage_type}"
    volume_size = "${var.storage_size}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

#resource "aws_internet_gateway" "gw" {
#  vpc_id      = "${var.vpc_id}"
#}

resource "aws_autoscaling_group" "worker" {
  availability_zones        = ["${split(",", var.azs)}"]
  vpc_zone_identifier       = ["${var.ephem_subnet_ids}"]
  min_size                  = "${var.min_size}"
  max_size                  = "${var.max_size}"
  desired_capacity          = "${var.desired_capacity}"
  health_check_type         = "${var.health_check_type}"
  name = "${aws_launch_configuration.worker.name}-asg"
  launch_configuration      = "${aws_launch_configuration.worker.name}"
  load_balancers            = ["${aws_elb.worker.id}"]
  health_check_grace_period = "300"

  tag {
    key                 = "ENV"
    value               = "${var.env}"
    propagate_at_launch = true
  }

  tag {
    key                 = "TERRAFORM"
    value               = "true"
    propagate_at_launch = true
  }

  tag {
    key                 = "ROLES"
    value               = "worker"
    propagate_at_launch = true
  }

  tag {
    key                 = "TYPE"
    value               = "worker"
    propagate_at_launch = true
  }

  tag {
    key                 = "TIER"
    value               = "${var.tier}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "${var.env}_${var.tier}_${var.short_region}_worker"
    propagate_at_launch = true
  }
}

#resource "aws_route53_record" "access_url" {
#	zone_id = "${var.zone_id}"
#  	name    = "${var.tier}-worker.${var.company}.com"
#  	type    = "A"
#
#  	alias {
#  		zone_id                 = "${aws_elb.worker.zone_id}"
#  		name                    = "${aws_elb.worker.dns_name}"
#  		evaluate_target_health  = true
#  	}
#}

#output "zone_id"      	    { value = "${aws_elb.worker.zone_id}" }
#output "elb_raw_url" 	    { value = "${aws_elb.worker.dns_name}" }
#output "elb_r53_pretty_url" { value = "${aws_route53_record.access_url.name}" }

output "ami_image_id" {
  value = "${data.aws_ami.worker_baseami.image_id}"
}

output "ami_creation_date" {
  value = "${data.aws_ami.worker_baseami.creation_date}"
}

output "ami_name" {
  value = "${data.aws_ami.worker_baseami.name}"
}
