#Auto-myIP
data "http" "my_ip" {
  url = "http://ipv4.icanhazip.com"
}

#Provider and region
provider "aws" {
  region = "us-east-1"
}

# SG
resource "aws_security_group" "app_sg" {
  name        = "app_sg"
  description = "Allow SSH-myIP and HTTP traffic "

  #SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
  }

  #HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Outside
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Key
resource "aws_key_pair" "key" {
  key_name   = "aws_key"
  public_key = file(pathexpand("~/.ssh/aws_key.pub"))
}

# EC2
resource "aws_instance" "web_server" {
  count = 2
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t3.small"

  key_name        = aws_key_pair.key.key_name
  security_groups = [aws_security_group.app_sg.name]

  tags = {
    Name = "WebApp Server ${count.index + 1}"
  }
}

# Public-IP EC2
output "instance_public_ip" {
  value = aws_instance.web_server.*.public_ip
}

# Generic inventory.ini
resource "local_file" "ansible_inventory" {
  content  = <<-EOT
    [webserver]
    %{ for ip in aws_instance.web_server.*.public_ip ~}
    ${ip} ansible_user=ubuntu
    %{ endfor ~}
  EOT
  filename = "${path.module}/../ansible/inventory.ini"
}
