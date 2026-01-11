resource "aws_lb" "example" {
  name               = "example"
  internal           = false
  load_balancer_type = "application"
  subnets = values(aws_subnet.public)[*].id

  security_groups = [
    aws_security_group.https.id,
    aws_security_group.http_redirect.id
  ]

  tags = {
    Name = "example"
  }
}

resource "aws_security_group" "https" {
  name        = "https"
  description = "https"
  vpc_id      = aws_vpc.example.id

  tags = {
    Name = "https"
  }
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.https.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "https" {
  security_group_id = aws_security_group.https.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_security_group" "http_redirect" {
  name        = "http_redirect"
  description = "http_redirect"
  vpc_id      = aws_vpc.example.id

  tags = {
    Name = "http_redirect"
  }
}

resource "aws_vpc_security_group_ingress_rule" "http_redirect" {
  security_group_id = aws_security_group.http_redirect.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "http_redirect" {
  security_group_id = aws_security_group.http_redirect.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.example.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.example.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example.arn
  }
}

resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.example.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_target_group" "example" {
  name        = "example"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.example.id
}
