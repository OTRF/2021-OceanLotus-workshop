############################################ Create NSM instance ############################################
resource "aws_security_group" "nsm_box_server_sg" {
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

  # NGINX HTTP port for NGINX
	ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.publicCIDRblock, var.managementCIDRblock, "0.0.0.0/0"]
  }

  # NGINX HTTPS port for NGINX
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
    Name = "${var.VPC_NAME}_NSM_BOX_SERVER_SG"
  }
}

resource "aws_network_interface" "nsm_primary_interface" {
  subnet_id       = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.nsm_box_server_sg.id]
  private_ips	    = [var.siem_servers_map["arkmie"]]
  
  tags = {
    Name = "${var.VPC_NAME}_NSM_BOX_SERVER_PRIMARY_INTERFACE"
  }
}

resource "aws_instance" "nsm_server" {
	ami           					= var.ubunut-ami
  instance_type 					= "r5.2xlarge"
  #instance_type 					= "t3.large"
  key_name 								= "${var.VPC_NAME}-ssh-key"
  disable_api_termination = true

  network_interface {
    device_index            = 0
    network_interface_id    = "${aws_network_interface.nsm_primary_interface.id}"
  }

	root_block_device {
		volume_size	= 300
		volume_type = "gp2"
		delete_on_termination = true
	}

 	tags = {
  	Name = "${var.VPC_NAME}_nsm_box"
 	}
   
}

resource "aws_eip" "nsm_server_eip" {
	network_interface = aws_network_interface.nsm_primary_interface.id
  tags = {
    Name = "${var.VPC_NAME}_nsm_server_eip"
  }
}

############################################ Create NSM box network tap ############################################
resource "aws_security_group" "nsm_box_traffic_mirror_sg" {
  name = "Traffic mirror"
  vpc_id = aws_vpc.vpc.id

  # Allow all inbound
  ingress {
    description = "Allow ALL inbound traffic on network TAP"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # Allow all outbound
  egress {
    description = "Allow ALL outbound traffic on network TAP"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_network_interface" "nsm_tap_interface" {
  subnet_id       = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.nsm_box_traffic_mirror_sg.id]
  private_ips_count = 0
  tags = {
    Name = "${var.VPC_NAME}_NSM_BOX_SERVER_TAP_INTERFACE"
  }

  attachment {
    instance     = aws_instance.nsm_server.id
    device_index = 1
  }
}

resource "aws_ec2_traffic_mirror_target" "nsm_traffic_mirror_target" {
  description          = "${var.VPC_NAME}_nsm_box ENI target"
  network_interface_id = "${aws_network_interface.nsm_tap_interface.id}"
  
  tags = {
  	Name = "${var.VPC_NAME}_nsm_box_traffic_mirror_target"
 	}
}

resource "aws_ec2_traffic_mirror_filter" "nsm_traffic_mirror_filter" {
  description = "${var.VPC_NAME}_nsm_box traffic mirror filter - Allow All"
  tags = {
  	Name = "${var.VPC_NAME}_nsm_box_traffic_mirror_filter"
 	}
}

resource "aws_ec2_traffic_mirror_filter_rule" "nsm_traffic_mirror_ipv4_filter_rule_ingress" {
  description              = "${var.VPC_NAME}_nsm_traffic_mirror_ipv4_filter_rule_ingress"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.nsm_traffic_mirror_filter.id
  destination_cidr_block   = "0.0.0.0/0"
  source_cidr_block        = "0.0.0.0/0"
  rule_number              = 100
  rule_action              = "accept"
  traffic_direction        = "ingress"

}

resource "aws_ec2_traffic_mirror_filter_rule" "nsm_traffic_mirror_ipv6_filter_rule_ingress" {
  description              = "${var.VPC_NAME}_nsm_traffic_mirror_ipv6_filter_rule_ingress"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.nsm_traffic_mirror_filter.id
  destination_cidr_block   = "::/0"
  source_cidr_block        = "::/0"
  rule_number              = 101
  rule_action              = "accept"
  traffic_direction        = "ingress"

}

resource "aws_ec2_traffic_mirror_filter_rule" "nsm_traffic_mirror_ipv4_filter_rule_egress" {
  description              = "${var.VPC_NAME}_nsm_traffic_mirror_ipv4_filter_rule_egress"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.nsm_traffic_mirror_filter.id
  destination_cidr_block   = "0.0.0.0/0"
  source_cidr_block        = "0.0.0.0/0"
  rule_number              = 200
  rule_action              = "accept"
  traffic_direction        = "egress"
}

resource "aws_ec2_traffic_mirror_filter_rule" "nsm_traffic_mirror_ipv6_filter_rule_egress" {
  description              = "${var.VPC_NAME}_nsm_traffic_mirror_ipv6_filter_rule_egress"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.nsm_traffic_mirror_filter.id
  destination_cidr_block   = "::/0"
  source_cidr_block        = "::/0"
  rule_number              = 201
  rule_action              = "accept"
  traffic_direction        = "egress"
}


resource "aws_ec2_traffic_mirror_session" "wiki_server_traffic_mirror_session" {
  description              = "${var.VPC_NAME}_wiki_server_traffic_mirror_session"
  network_interface_id     = "${aws_instance.wiki_server.primary_network_interface_id}"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.nsm_traffic_mirror_filter.id
  traffic_mirror_target_id = aws_ec2_traffic_mirror_target.nsm_traffic_mirror_target.id
  session_number           = 1 
  tags = {
  	Name = "${var.VPC_NAME}_wiki_server_traffic_mirror_session"
 	}
}

resource "aws_ec2_traffic_mirror_session" "win_file_server_traffic_mirror_session" {
  description              = "${var.VPC_NAME}_win_file_server_traffic_mirror_session"
  network_interface_id     = "${aws_instance.windows_file_server.primary_network_interface_id}"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.nsm_traffic_mirror_filter.id
  traffic_mirror_target_id = aws_ec2_traffic_mirror_target.nsm_traffic_mirror_target.id
  session_number           = 1 
  tags = {
  	Name = "${var.VPC_NAME}_win_file_server_traffic_mirror_session"
 	}
}

########################################### Create Elastic instance ############################################
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

  # Logstash ingest port from logstash ingestor
	ingress {
    from_port   = 5044
    to_port     = 5044
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.logstash_ingestor_server.private_ip}/32"]
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
  tags = {
    Name = "${var.VPC_NAME}_elastic_server_eip"
  }
}

########################################### Create Graylog instance ############################################
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
    cidr_blocks = ["${aws_instance.logstash_ingestor_server.private_ip}/32"]
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
  tags = {
    Name = "${var.VPC_NAME}_graylog_server_eip"
  }
}

########################################### Create Splunk instance ############################################
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
    cidr_blocks = ["${aws_instance.logstash_ingestor_server.private_ip}/32"]
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
 	
  # Splunk REST API port for Splunk
	ingress {
    from_port   = 8089
    to_port     = 8089
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.jump_box.private_ip}/32"]
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
  tags = {
    Name = "${var.VPC_NAME}_splunk_server_eip"
  }
}