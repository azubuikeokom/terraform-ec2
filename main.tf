resource "aws_instance" "web" {
  ami           = "ami-052efd3df9dad4825"
  count = var.count_num
  instance_type = "t2.micro"
  key_name = "cloude-key"
  vpc_security_group_ids = [ aws_security_group.allow_tls.id ]
  subnet_id = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.id

  connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = file("~/.ssh/cloude-key.pem")
    host     = self.public_ip
  }
  provisioner "file" {
    source = "data_env.sh"
    destination = "/home/ubuntu/data_env.sh"

  }
  # provisioner "remote-exec" {
  #   inline = [
  #     "chmod +x /home/ubuntu/data_env.sh",
  #     "/home/ubuntu/data_env.sh"
  #   ]
  # }
  user_data = <<-EOF
    #!/bin/bash
    chmod +x /home/ubuntu/data_env.sh
    source /home/ubuntu/data_env.sh
    curl $DATA -o '/home/ubuntu/awscliv2.zip'
  EOF
  tags = {
    Name = "${var.server_name}-server${count.index}"
  }
}

