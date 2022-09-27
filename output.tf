output "instance1"{
    value = ["${aws_instance.web.*.public_ip}"]
    description = "instance public ips"
}
