############################################ Create Logstash ingestor ############################################
resource "aws_security_group" "logstash_ingestor_server_sg" {
  vpc_id = aws_vpc.vpc.id

  # Allow ICMP from jumpbox
  ingress {
    description = "Allow ICMP from management subnet"
    from_port = 8
    to_port = 0
    protocol = "icmp"
    cidr_blocks = ["${aws_instance.jump_box.private_ip}/32"]
  }

  # Allow SSH from jumpbox
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.jump_box.private_ip}/32"]
  }

  # Logstash ingest port from management and corp subnet
	ingress {
    from_port   = 5044
    to_port     = 5044
    protocol    = "tcp"
    cidr_blocks = [var.managementCIDRblock, var.corpCIDRblock]
  }
 	
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.VPC_NAME}_LOGSTASH_INGESTOR_SERVER_SG"
  }
}

resource "aws_instance" "logstash_ingestor_server" {
	ami           					= var.ubunut-ami
  instance_type 					= "t2.large"
  subnet_id 							= aws_subnet.public_subnet.id
  vpc_security_group_ids 	= [aws_security_group.logstash_ingestor_server_sg.id]
  key_name 								= "${var.VPC_NAME}-ssh-key"
  private_ip	            = "${var.siem_servers_map["logstash_ingestor"]}"
  disable_api_termination = true

	root_block_device {
		volume_size	= 20
		volume_type = "gp2"
		delete_on_termination = true
	}

 	tags = {
  	Name = "${var.VPC_NAME}_logstash_ingestor"
 	}
}

############################################ Create NSM instance ############################################
# resource "aws_security_group" "nsm_box_server_sg" {
#   vpc_id = aws_vpc.vpc.id

#   # Allow ICMP from jumpbox
#   ingress {
#     description = "Allow ICMP from management subnet"
#     from_port = 8
#     to_port = 0
#     protocol = "icmp"
#     cidr_blocks = ["${aws_instance.jump_box.private_ip}/32"]
#   }

#   # Allow SSH from jumpbox
#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["${aws_instance.jump_box.private_ip}/32"]
#   }

#   # NGINX HTTP port for NGINX
# 	ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = [var.publicCIDRblock, var.managementCIDRblock, "0.0.0.0/0"]
#   }

#   # NGINX HTTPS port for NGINX
# 	ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = [var.publicCIDRblock, var.managementCIDRblock, "0.0.0.0/0"]
#   }
 	
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "${var.VPC_NAME}_NSM_BOX_SERVER_SG"
#   }
# }

# resource "aws_instance" "logstash_ingestor_server" {
# 	ami           					= var.ubunut-ami
#   instance_type 					= "r5.2xlarge"
#   subnet_id 							= aws_subnet.public_subnet.id
#   vpc_security_group_ids 	= [aws_security_group.nsm_box_server_sg.id]
#   key_name 								= "${var.VPC_NAME}-ssh-key"
#   private_ip	            = "${var.siem_servers_map["nsm_box"]}"
#   disable_api_termination = true

# 	root_block_device {
# 		volume_size	= 100
# 		volume_type = "gp2"
# 		delete_on_termination = true
# 	}

#  	tags = {
#   	Name = "${var.VPC_NAME}_nsm_box"
#  	}
# }

############################################ Create Elastic instance ############################################
resource "aws_security_group" "elastic_server_sg" {
  vpc_id = aws_vpc.vpc.id

  # Allow ICMP from jumpbox
  ingress {
    description = "Allow ICMP from management subnet"
    from_port = 8
    to_port = 0
    protocol = "icmp"
    cidr_blocks = ["${aws_instance.jump_box.private_ip}/32"]
  }

  # Allow SSH from jumpbox
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.jump_box.private_ip}/32"]
  }

  # Logstash ingest port from management and corp subnet
	ingress {
    from_port   = 5044
    to_port     = 5044
    protocol    = "tcp"
    cidr_blocks = [var.managementCIDRblock, "${aws_instance.logstash_ingestor_server.private_ip}/32"]
  }

  # NGINX HTTP port for Kibana
	ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.publicCIDRblock, var.managementCIDRblock, "0.0.0.0/0"]
  }

  # NGINX HTTPS port for Kibana
	ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.publicCIDRblock, var.managementCIDRblock, "0.0.0.0/0"]
  }
 	
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.VPC_NAME}_ELASTIC_SERVER_SG"
  }
}

resource "aws_instance" "elastic_server" {
	ami           					= var.ubunut-ami
  instance_type 					= "r5.2xlarge"
  subnet_id 							= aws_subnet.public_subnet.id
  vpc_security_group_ids 	= [aws_security_group.elastic_server_sg.id]
  key_name 								= "${var.VPC_NAME}-ssh-key"
  private_ip	            = "${var.siem_servers_map["elastic"]}"
  disable_api_termination = true

	root_block_device {
		volume_size	= 100
		volume_type = "gp2"
		delete_on_termination = true
	}

 	tags = {
  	Name = "${var.VPC_NAME}_elastic-beefyboi"
 	}
}


resource "aws_eip" "elastic_server_eip" {
	instance = aws_instance.elastic_server.id
  vpc = true
}

############################################ Create Graylog instance ############################################
resource "aws_security_group" "graylog_server_sg" {
  vpc_id = aws_vpc.vpc.id

  # Allow ICMP from jumpbox
  ingress {
    description = "Allow ICMP from management subnet"
    from_port = 8
    to_port = 0
    protocol = "icmp"
    cidr_blocks = ["${aws_instance.jump_box.private_ip}/32"]
  }

  # Allow SSH from jumpbox
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.jump_box.private_ip}/32"]
  }

  # Logstash ingest port from management and corp subnet
	ingress {
    from_port   = 5044
    to_port     = 5044
    protocol    = "tcp"
    cidr_blocks = [var.managementCIDRblock, "${aws_instance.logstash_ingestor_server.private_ip}/32"]
  }

  # NGINX HTTP port for Kibana
	ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.publicCIDRblock, var.managementCIDRblock, "0.0.0.0/0"]
  }

  # NGINX HTTPS port for Kibana
	ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.publicCIDRblock, var.managementCIDRblock, "0.0.0.0/0"]
  }
 	
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.VPC_NAME}_GRAYLOG_SERVER_SG"
  }
}

resource "aws_instance" "graylog_server" {
	ami           					= var.ubunut-ami
  instance_type 					= "r5.2xlarge"
  subnet_id 							= aws_subnet.public_subnet.id
  vpc_security_group_ids 	= [aws_security_group.graylog_server_sg.id]
  key_name 								= "${var.VPC_NAME}-ssh-key"
  private_ip	            = "${var.siem_servers_map["graylog"]}"
  disable_api_termination = true

	root_block_device {
		volume_size	= 100
		volume_type = "gp2"
		delete_on_termination = true
	}

 	tags = {
  	Name = "${var.VPC_NAME}_graylog-beefyboi"
 	}
}


resource "aws_eip" "graylog_server_eip" {
	instance = aws_instance.graylog_server.id
  vpc = true
}

############################################ Create Splunk instance ############################################
resource "aws_security_group" "splunk_server_sg" {
  vpc_id = aws_vpc.vpc.id

  # Allow ICMP from jumpbox
  ingress {
    description = "Allow ICMP from management subnet"
    from_port = 8
    to_port = 0
    protocol = "icmp"
    cidr_blocks = ["${aws_instance.jump_box.private_ip}/32"]
  }

  # Allow SSH from jumpbox
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.jump_box.private_ip}/32"]
  }

  # Logstash ingest port from management and corp subnet
	ingress {
    from_port   = 5044
    to_port     = 5044
    protocol    = "tcp"
    cidr_blocks = [var.managementCIDRblock, "${aws_instance.logstash_ingestor_server.private_ip}/32"]
  }

  # NGINX HTTP port for Kibana
	ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.publicCIDRblock, var.managementCIDRblock, "0.0.0.0/0"]
  }

  # NGINX HTTPS port for Kibana
	ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.publicCIDRblock, var.managementCIDRblock, "0.0.0.0/0"]
  }
 	
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.VPC_NAME}_SPLUNK_SERVER_SG"
  }
}

resource "aws_instance" "splunk_server" {
	ami           					= var.ubunut-ami
  instance_type 					= "r5.2xlarge"
  subnet_id 							= aws_subnet.public_subnet.id
  vpc_security_group_ids 	= [aws_security_group.splunk_server_sg.id]
  key_name 								= "${var.VPC_NAME}-ssh-key"
  private_ip	            = "${var.siem_servers_map["splunk"]}"
  disable_api_termination = true

	root_block_device {
		volume_size	= 100
		volume_type = "gp2"
		delete_on_termination = true
	}

 	tags = {
  	Name = "${var.VPC_NAME}_splunk-beefyboi"
 	}
}

resource "aws_eip" "splunk_server_eip" {
	instance = aws_instance.splunk_server.id
  vpc = true
}