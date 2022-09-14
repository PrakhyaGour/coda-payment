data "aws_ecs_task_definition" "nginx" {
  depends_on = [ "aws_ecs_task_definition.nginx" ]
  task_definition = "${aws_ecs_task_definition.nginx.family}"
}

resource "aws_ecs_task_definition" "nginx" {
  family = "nginx"

  container_definitions = <<DEFINITION
  [
    {
        "name": "nginx",
        "image": "nginx:latest",
        "memory": 256,
        "cpu": 256,
        "essential": true,
        "portMappings": [
          {
            "containerPort": 80,
            "hostPort": 80,
            "protocol": "tcp"
          }
        ]
    }
  ]
  DEFINITION
}

resource "aws_ecs_service" "web-server-service" {
  name            = "web-server-service"
  iam_role        = "${aws_iam_role.ecs-service-role.name}"
  cluster         = "${aws_ecs_cluster.public-ecs-cluster.id}"
  task_definition = "${aws_ecs_task_definition.nginx.family}:${max("${aws_ecs_task_definition.nginx.revision}", "${data.aws_ecs_task_definition.nginx.revision}")}"
  desired_count   = 1

  load_balancer {
    target_group_arn = "${aws_alb_target_group.public-ecs-target-group.1.arn}"
    container_port   = 80
    container_name   = "nginx"
  }

  launch_type                        = "EC2"
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  depends_on = ["aws_alb_listener.public-alb-listener"]
}
