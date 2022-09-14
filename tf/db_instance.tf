resource "aws_db_instance" "default" {
  engine                 = "mysql"
  option_group_name      = aws_db_option_group.default.name
  parameter_group_name   = aws_db_parameter_group.default.name
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.default.id]
  identifier = var.identifier
  engine_version = var.engine_version
  instance_class = var.instance_class
  allocated_storage = var.allocated_storage
  username = var.username
  password = var.password
  maintenance_window = var.maintenance_window
  apply_immediately = var.apply_immediately
  multi_az = var.multi_az
  port = var.port
  name = var.name
  storage_type = var.storage_type
  iops = var.iops
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  allow_major_version_upgrade = var.allow_major_version_upgrade
  backup_retention_period = var.backup_retention_period
  storage_encrypted = var.storage_encrypted
  kms_key_id = var.kms_key_id
  deletion_protection = var.deletion_protection
  final_snapshot_identifier = var.final_snapshot_identifier
  skip_final_snapshot = var.skip_final_snapshot
  snapshot_identifier = var.snapshot_identifier
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_role_arn
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  copy_tags_to_snapshot = var.copy_tags_to_snapshot
  publicly_accessible = var.publicly_accessible
  ca_cert_identifier = var.ca_cert_identifier
  license_model = var.license_model
  tags = merge({ "Name" = var.identifier }, var.tags)


  lifecycle {
    ignore_changes = [password]
  }
}

resource "aws_db_option_group" "default" {
  engine_name              = "mysql"
  name                     = var.identifier
  major_engine_version     = local.major_engine_version
  option_group_description = var.description

  tags = merge({ "Name" = var.identifier }, var.tags)
}

locals {
  version_elements       = split(".", var.engine_version)
  major_version_elements = [local.version_elements[0], local.version_elements[1]]
  major_engine_version   = var.major_engine_version == "" ? join(".", local.major_version_elements) : var.major_engine_version
}

resource "aws_db_parameter_group" "default" {
  name        = var.identifier
  family      = local.family
  description = var.description
  parameter {
    name         = "character_set_client"
    value        = var.character_set
    apply_method = "immediate"
  }
  parameter {
    name         = "character_set_connection"
    value        = var.character_set
    apply_method = "immediate"
  }
  parameter {
    name         = "character_set_database"
    value        = var.character_set
    apply_method = "immediate"
  }
  parameter {
    name         = "character_set_results"
    value        = var.character_set
    apply_method = "immediate"
  }
  parameter {
    name         = "character_set_server"
    value        = var.character_set
    apply_method = "immediate"
  }
  parameter {
    name         = "collation_connection"
    value        = var.collation
    apply_method = "immediate"
  }
  parameter {
    name         = "collation_server"
    value        = var.collation
    apply_method = "immediate"
  }
    value        = var.time_zone
    apply_method = "immediate"
  }
  parameter {
    name         = "tx_isolation"
    value        = var.tx_isolation
    apply_method = "immediate"
  }

  tags = merge({ "Name" = var.identifier }, var.tags)
}

locals {
  family = "mysql${local.major_engine_version}"
}

resource "aws_db_subnet_group" "default" {
  name        = var.identifier
  subnet_ids  = var.subnet_ids
  description = var.description
  tags = merge({ "Name" = var.identifier }, var.tags)
}

resource "aws_security_group" "default" {
  name   = local.security_group_name
  vpc_id = var.vpc_id
  tags = merge({ "Name" = local.security_group_name }, var.tags)
}

locals {
  security_group_name = "${var.identifier}-rds-mysql"
}


resource "aws_security_group_rule" "ingress" {
  type              = "ingress"
  from_port         = var.port
  to_port           = var.port
  protocol          = "tcp"
  cidr_blocks       = var.source_cidr_blocks
  security_group_id = aws_security_group.default.id
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.default.id
}
