############################################ Interal corporate domain ############################################
resource "aws_route53_zone" "internal_corp_domain" {
  # domain/zone
  name = var.internalCorpDomain
  
  vpc {
   vpc_id = aws_vpc.vpc.id
  }

  tags = {
    name = "${var.VPC_NAME}_internal_corp_domain"
  }
}

resource "aws_route53_record" "mail_A_record" {
  zone_id = aws_route53_zone.internal_corp_domain.zone_id
  name    = "mail"
  type    = "A"
  ttl     = "30"
  records = ["${aws_instance.windows_file_server.private_ip}"]
}

resource "aws_route53_record" "mail_CNAME_smtp_record" {
  zone_id = aws_route53_zone.internal_corp_domain.zone_id
  name    = "smtp"
  type    = "CNAME"
  ttl     = "30"
  records = ["mail.${var.internalCorpDomain}"]
}

resource "aws_route53_record" "mail_CNAME_imap_record" {
  zone_id = aws_route53_zone.internal_corp_domain.zone_id
  name    = "imap"
  type    = "CNAME"
  ttl     = "30"
  records = ["mail.${var.internalCorpDomain}"]
}

resource "aws_route53_record" "fileserver_A_record" {
  zone_id = aws_route53_zone.internal_corp_domain.zone_id
  name    = "fileserver"
  type    = "A"
  ttl     = "30"
  records = ["${aws_instance.windows_file_server.private_ip}"]
}

resource "aws_route53_record" "wiki_A_record" {
  zone_id = aws_route53_zone.internal_corp_domain.zone_id
  name    = "wiki"
  type    = "A"
  ttl     = "30"
  records = ["${aws_instance.wiki_server.private_ip}"]
}


resource "aws_route53_record" "mx_record" {
  zone_id = aws_route53_zone.internal_corp_domain.zone_id
  name    = "@"
  type    = "MX"
  ttl     = "30"
  records = ["10 ${aws_instance.windows_file_server.private_ip}"]
}

############################################ Red team domain 1 ############################################
# resource "aws_route53_zone" "internal_corp_domain" {
#   vpc_id = aws_vpc.vpc.id

#   name = ""
  
#   #vpc {
#   #  vpc_id = aws_vpc.vpc.id
#   #}

#   tags = {
#     name = "${var.VPC_NAME}_internal_corp_domain"
#   }
# }

# resource "aws_route53_record" "mail_A_record" {
#   zone_id = aws_route53_zone.internal_corp_domain.zone_id
#   name    = "mail.${internalCorpDomain}"
#   type    = "A"
#   ttl     = "30"
#   records = [aws_route53_zone.dev.name_servers]
# }

############################################ Red team domain 2 ############################################


############################################ Red team domain 3 ############################################