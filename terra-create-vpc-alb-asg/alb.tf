# 2. Application Load Balancer
resource "aws_lb" "alb" {
  name               = "alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public_subnet[*].id
  depends_on         = [aws_internet_gateway.igw_vpc]
}

# Target Groups
resource "aws_lb_target_group" "alb_ec2_tg" {
  name     = "alb-ec2-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.custom_vpc.id
  tags = {
    Name = "alb_ec2_tg"
  }
}

# Listener
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_ec2_tg.arn
  }
  tags = {
    Name = "alb_listener"
  }
}


# Launch Template
resource "aws_launch_template" "ec2_lt" {
  name          = "ec2_lt"
  image_id      = "ami-01811d4912b4ccb26"
  instance_type = "t2.micro"
  key_name = "terraform-keypair"
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ec2_sg.id]
  }
  user_data = filebase64("userdata.sh")
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ec2-web-server"
    }
  }
}


# Autoscaling Group
resource "aws_autoscaling_group" "ec2_webserver_asg" {
  name                = "ec2_webserver_asg"
  max_size            = 3
  min_size            = 1
  desired_capacity    = 1
  target_group_arns   = [aws_lb_target_group.alb_ec2_tg.arn]
  vpc_zone_identifier = aws_subnet.private_subnet[*].id
  launch_template {
    id      = aws_launch_template.ec2_lt.id
    version = "$Latest"
  }
  health_check_type = "EC2"
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}