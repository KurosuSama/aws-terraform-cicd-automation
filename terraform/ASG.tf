# LT-EC2
resource "aws_launch_template" "web_server_lt" {
  name_prefix   = "Vpro_web-lt"
  image_id      = "ami-053b0d53c279acc90"
  instance_type = "t3.small"
  key_name      = aws_key_pair.key.key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.vpro_app_sg.id]
  }
  tag_specifications {
    resource_type = "instance"
    tags          = { Name = "ASG-WebApp-Server" }
  }
}

# Auto-Scalling-Group-Settings
resource "aws_autoscaling_group" "app_asg" {
  name                = "Vpro_app-asg"
  desired_capacity    = 2
  max_size            = 3
  min_size            = 1
  vpc_zone_identifier = [aws_subnet.public_1a.id, aws_subnet.public_1b.id, aws_subnet.public_1c.id]
  target_group_arns   = [aws_lb_target_group.app_tg.arn]

  launch_template {
    id      = aws_launch_template.web_server_lt.id
    version = "$Latest"
  }
}