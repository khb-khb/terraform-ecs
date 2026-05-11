resource "aws_db_subnet_group" "this" {
  name       = var.db_subnet_group_name
  subnet_ids = var.db_subnet_ids

  tags = {
    Name = var.db_subnet_group_name
  }
}

resource "aws_rds_cluster" "this" {
  cluster_identifier = var.db_identifier

  engine         = var.engine
  engine_version = var.engine_version

  database_name   = var.db_name
  master_username = var.db_username
  master_password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.db_security_group_ids

  backup_retention_period = var.backup_retention_period

  skip_final_snapshot = var.skip_final_snapshot
}

# 추후에 reader instance 가 필요할 때를 위해 count 로 생성
resource "aws_rds_cluster_instance" "this" {
  count              = var.instance_count
  identifier         = "${var.db_identifier}-instance-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.this.id
  engine             = aws_rds_cluster.this.engine
  engine_version     = aws_rds_cluster.this.engine_version
  instance_class     = var.instance_class
}
