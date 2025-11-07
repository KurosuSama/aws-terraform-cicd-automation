# SG_LB
resource "aws_security_group" "vpro_lb_sg" {
  name        = "vpro_lb_sg"
  description = "Allow HTTP from everythere"
  vpc_id      = aws_vpc.main.id 

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

# SG_EC2
resource "aws_security_group" "vpro_app_sg" {
  name        = "vpro_app_sg"
  description = "Allow SSH-myIP and HTTP from LB "
  vpc_id = aws_vpc.main.id

  #SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
  }

  #HTTP from LB
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.vpro_lb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}