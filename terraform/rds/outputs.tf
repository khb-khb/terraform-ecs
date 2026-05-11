output "rds_cluster_identifier" {
  value = aws_rds_cluster.this.cluster_identifier
}

output "rds_instance_identifier" {
  value = [
    for instance in aws_rds_cluster_instance.this :
    instance.identifier
  ]
}

output "rds_writer_endpoint" {
  value = aws_rds_cluster.this.endpoint
}

output "rds_reader_endpoint" {
  value = aws_rds_cluster.this.reader_endpoint
}
