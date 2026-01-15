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
