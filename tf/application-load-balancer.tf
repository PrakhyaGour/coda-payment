##############################################################################
# PUBLIC Zone Load Balancing
##############################################################################
locals {
  target_groups = ["pri", "sec"]
  hosts_name = ["*.yourdomain.com"]
}

resource "aws_alb" "public-load-balancer" {
  name            = "public-load-balancer"
  security_groups = ["${aws_security_group.public-alb-sg.id}"]

  subnets = [
    "${aws_subnet.public-subnet.0.id}",
    "${aws_subnet.public-subnet.1.id}",
  ]
}

resource "aws_alb_target_group" "public-ecs-target-group" {
  count    =  "${length(local.target_groups)}"
  name     = "public-ecs-target-group-${element(local.target_groups, count.index)}"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.vpc.id}"

  health_check {
    healthy_threshold   = "5"
    unhealthy_threshold = "2"
    interval            = "30"
    matcher             = "200"
    path                = "/"
    port                = "80"
    protocol            = "HTTP"
    timeout             = "5"
  }

  depends_on = [
    "aws_alb.public-load-balancer",
  ]

  tags = {
    Name = "public-ecs-target-group-${element(local.target_groups, count.index)}"
  }
}

resource "aws_alb_listener" "public-alb-listener" {
  load_balancer_arn = "${aws_alb.public-load-balancer.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.public-ecs-target-group.1.arn}"
    type             = "forward"
  }
}


resource "aws_alb_listener_rule" "public-alb-listener-rule" {
  listener_arn = "${aws_alb_listener.public-alb-listener.arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.public-ecs-target-group.1.arn}"
  }

  condition {
    host_header {
      values = "${local.hosts_name}"
    }
  }
}
