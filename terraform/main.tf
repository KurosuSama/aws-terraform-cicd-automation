#Auto-myIP
data "http" "my_ip" {
  url = "http://ipv4.icanhazip.com"
}

data "aws_instances" "asg_instances" {
  instance_tags = {
    Name = "ASG-WebApp-Server"
  }
  instance_state_names = ["running"]
  depends_on           = [aws_autoscaling_group.app_asg]
}

# Key
resource "aws_key_pair" "key" {
  key_name   = "aws_key"
  public_key = file(pathexpand("~/.ssh/aws_key.pub"))
}

# Generic inventory.ini
resource "local_file" "ansible_inventory" {
  content  = <<-EOT
    [webserver]
    %{for ip in data.aws_instances.asg_instances.public_ips~}
    ${ip} ansible_user=ubuntu
    %{endfor~}
  EOT
  filename = "${path.module}/../ansible/inventory.ini"
}
