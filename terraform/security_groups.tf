# Only looked up when ssh_allowed_cidr is empty
data "http" "my_ip" {
  count = var.ssh_allowed_cidr == "" ? 1 : 0
  url   = "https://checkip.amazonaws.com"
}

locals {
  ssh_cidr = var.ssh_allowed_cidr != "" ? var.ssh_allowed_cidr : "${chomp(join("", data.http.my_ip[*].response_body))}/32"
}

resource "aws_security_group" "web" {
  name        = "${var.project}-web-sg"
  description = "Web server"
  vpc_id      = aws_vpc.main.id
  tags        = { Name = "${var.project}-web-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "web_ssh" {
  security_group_id = aws_security_group.web.id
  description       = "SSH"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = local.ssh_cidr
}

resource "aws_vpc_security_group_ingress_rule" "web_http" {
  security_group_id = aws_security_group.web.id
  description       = "HTTP from anywhere"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "web_https" {
  security_group_id = aws_security_group.web.id
  description       = "HTTPS from anywhere"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "web_all" {
  security_group_id = aws_security_group.web.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_security_group" "db" {
  name        = "${var.project}-db-sg"
  description = "MongoDB server"
  vpc_id      = aws_vpc.main.id
  tags        = { Name = "${var.project}-db-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "db_mongo" {
  security_group_id            = aws_security_group.db.id
  description                  = "MongoDB from web server only"
  ip_protocol                  = "tcp"
  from_port                    = 27017
  to_port                      = 27017
  referenced_security_group_id = aws_security_group.web.id
}

resource "aws_vpc_security_group_ingress_rule" "db_ssh" {
  security_group_id            = aws_security_group.db.id
  description                  = "SSH from web server (bastion) only"
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  referenced_security_group_id = aws_security_group.web.id
}

resource "aws_vpc_security_group_egress_rule" "db_all" {
  security_group_id = aws_security_group.db.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
