output "web_server_public_ip" {
  description = "Public IP of the web server"
  value       = aws_instance.web.public_ip
}

output "web_server_private_ip" {
  value = aws_instance.web.private_ip
}

output "db_server_private_ip" {
  value = aws_instance.db.private_ip
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "nat_gateway_public_ip" {
  value = aws_eip.nat.public_ip
}

output "app_url" {
  value = "http://${aws_instance.web.public_ip}"
}

output "ssh_web" {
  value = "ssh -i ${var.private_key_path} ubuntu@${aws_instance.web.public_ip}"
}

output "ssh_db_via_bastion" {
  value = "ssh -i ${var.private_key_path} -o ProxyCommand=\"ssh -i ${var.private_key_path} -W %h:%p -q ubuntu@${aws_instance.web.public_ip}\" ubuntu@${aws_instance.db.private_ip}"
}
