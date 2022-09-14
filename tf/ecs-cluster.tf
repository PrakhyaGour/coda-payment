resource "aws_ecs_cluster" "public-ecs-cluster" {
  name = "${lookup(var.ecs_cluster_names, "public")}"
}
