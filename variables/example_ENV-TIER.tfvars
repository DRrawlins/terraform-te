# Upload this file to s3://ENVIRONMENT-dr-useast1-terraform-state/dr/ENVIRONMENT-TIER.tfvars
tier = "prod"

ec2_app_user = "ops"

ec2_app_cluster_health_check_type = "EC2"

ec2_app_use_separate_box = "0"

ec2_app_storage_type = "gp2" # SSD

ec2_app_storage_size = "20" # in GB

ec2_app_cluster_desired_capacity = "1" # This is for the app specifically

ec2_app_cluster_min_size = "1" # This is for the app specifically

ec2_app_cluster_max_size = "1" # This is for the app specifically

ec2_app_instance_type = "t2.micro"
