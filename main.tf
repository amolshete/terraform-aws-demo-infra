

resource "aws_instance" "webapp-1" {
  ami           = var.custom-AMI
  instance_type = "t2.micro"
  key_name = "linux-os-key"
  subnet_id = aws_subnet.mysubnet-1a.id
  #security_groups = [aws_security_group.allow_80.id,aws_security_group.allow_22.id]
  vpc_security_group_ids = [aws_security_group.allow_80.id,aws_security_group.allow_22.id]
  tags = {
    Name = "WebApp-1"
  }
}


resource "aws_instance" "webapp-2" {
  ami           = "ami-0da6a4a19ffff19e9"
  instance_type = "t2.micro"
  key_name = "linux-os-key"
  subnet_id = aws_subnet.mysubnet-1b.id
  #security_groups = [aws_security_group.allow_80.id,aws_security_group.allow_22.id]
  vpc_security_group_ids = [aws_security_group.allow_80.id,aws_security_group.allow_22.id]
  tags = {
    Name = "WebApp-2"
  }
}

resource "aws_lb_target_group" "webapp-lb-target-group" {
  name     = "Webapp-lb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.webapp-vpc.id
}

resource "aws_lb_target_group_attachment" "webapp-lb-target-group-attachment-1" {
  target_group_arn = aws_lb_target_group.webapp-lb-target-group.arn
  target_id        = aws_instance.webapp-1.id
  port             = 80
}


resource "aws_lb_target_group_attachment" "webapp-lb-target-group-attachment-2" {
  target_group_arn = aws_lb_target_group.webapp-lb-target-group.arn
  target_id        = aws_instance.webapp-2.id
  port             = 80
}

resource "aws_lb_listener" "webapp-lb-listener" {
  load_balancer_arn = aws_lb.webapp-application-lb.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webapp-lb-target-group.arn
  }
}

resource "aws_lb" "webapp-application-lb" {
  name               = "webapp-application-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_22.id,aws_security_group.allow_80.id]
  subnets            = [aws_subnet.mysubnet-1a.id,aws_subnet.mysubnet-1b.id]

  enable_deletion_protection = false

  tags = {
    Environment = "production"
    Owner = "Amol"
  }
}

resource "aws_launch_template" "webapp-launch-template" {
  name_prefix   = "webapp-launch-template"
  image_id      = "ami-0f69bc5520884278e"
  instance_type = "t3.micro"
  key_name = "linux-os-key"
  vpc_security_group_ids = [aws_security_group.allow_80.id,aws_security_group.allow_22.id]
  user_data = filebase64("example.sh")
   tags = {
    Environment = "production"
    Owner = "Amol"
  }
  
}

resource "aws_autoscaling_group" "webapp-ASG" {
  desired_capacity   = 3
  max_size           = 5
  min_size           = 3
  vpc_zone_identifier = [aws_subnet.mysubnet-1a.id,aws_subnet.mysubnet-1b.id]
  

  launch_template {
    id      = aws_launch_template.webapp-launch-template.id
    version = "$Latest"
  }
}

resource "aws_lb_target_group" "webapp-lb-target-grp-2" {
  name     = "webapp-lb-target-grp-2"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.webapp-vpc.id
}

resource "aws_lb" "webapp-lb-2" {
  name               = "webapp-lb-2"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_22.id,aws_security_group.allow_80.id]
  subnets            = [aws_subnet.mysubnet-1a.id,aws_subnet.mysubnet-1b.id]
}

resource "aws_lb_listener" "webapp-lb-listener-2" {
  load_balancer_arn = aws_lb.webapp-lb-2.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webapp-lb-target-grp-2.arn
  }
}

resource "aws_autoscaling_attachment" "terramino" {
  autoscaling_group_name = aws_autoscaling_group.webapp-ASG.id
  alb_target_group_arn   = aws_lb_target_group.webapp-lb-target-grp-2.arn
}