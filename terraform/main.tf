# use default VPC and first subnet
data "aws_vpc" "default" {
  default = true
}

resource "aws_instance" "web" {
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  vpc_security_group_ids      = [var.security_group_id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
  }

  tags = {
    Name = "portfolio-web"
  }
}
