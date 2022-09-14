resource "aws_db_instance" "default" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  name                 = "mydb"
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.rdssg.id]
  db_subnet_group_name    = aws_db_subnet_group.rds-group.id
}


resource "aws_db_subnet_group" "rds-group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.private-subnet.0.id, aws_subnet.private-subnet.1.id]
}

resource "aws_security_group" "rdssg" {
    name = "rdssg"
    vpc_id              = "${aws_vpc.vpc.id}"

    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        security_groups = [aws_security_group.webserver-sg.id]

    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]

    }
}
