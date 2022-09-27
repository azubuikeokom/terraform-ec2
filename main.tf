resource "aws_instance" "web" {
  ami           = "ami-052efd3df9dad4825"
  count = var.count_num
  instance_type = "t2.micro"
  key_name = "cloude-key"
  vpc_security_group_ids = [ aws_security_group.allow_tls.id ]
  subnet_id = aws_subnet.consul_subnet.id
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.id
  tags = {
    Name = "${var.server_name}-server${count.index}"
  }


}

