#---------------KeyPair Creation-----------------#

resource "aws_key_pair" "auth_key" {
  key_name   = "${var.project_name}-${var.project_env}"
  public_key = file("mykey.pub")
  tags = {
    Name = "${var.project_name}-${var.project_env}"
    project = var.project_name
    env = var.project_env
  }
}

#------------------SecurityGroup------------------#

resource "aws_security_group" "frontend" {
  name        = "${var.project_name}-${var.project_env}"
  description = "${var.project_name}-${var.project_env}"

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.project_env}"
    project = var.project_name
    env = var.project_env
  }
}

#---------------Ec2 Instance creation-------------#

resource "aws_instance" "frontend" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name = aws_key_pair.auth_key.key_name
  vpc_security_group_ids = [aws_security_group.frontend.id]
  tags = {
    Name = "${var.project_name}-${var.project_env}-frontend"
    project = var.project_name
    env = var.project_env
  }
  lifecycle {
    create_before_destroy = true
  }
}

#-----------------Adding DNS record in Route53-------#

resource "aws_route53_record" "frontend" {
  zone_id = data.aws_route53_zone.selected.id 
  name    = "${var.hostname}.${var.domain_name}"
  type    = "A"
  ttl     = 60
  records = [aws_instance.frontend.public_ip]
}
