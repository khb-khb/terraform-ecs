resource "aws_instance" "bastion" {
  ami                         = var.ec2_ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.sg_id
  iam_instance_profile        = var.iam
  associate_public_ip_address = true

  tags = {
    Name = var.ec2_name
  }
}
