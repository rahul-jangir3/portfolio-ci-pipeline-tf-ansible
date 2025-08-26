variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"    # change if you use another region
}

variable "ami_id" {
  description = "AMI ID to use"
  type        = string
  default     = "ami-02d26659fd82cf299"
}

variable "key_name" {
  description = "Existing key pair name in AWS (no .pem)"
  type        = string
  default     = "abc"
}

variable "security_group_id" {
  description = "Existing security group id to attach"
  type        = string
  default     = "sg-02a234701a5f09033"
}

variable "root_volume_size" {
  description = "Root EBS size (GB)"
  type        = number
  default     = 16
}

