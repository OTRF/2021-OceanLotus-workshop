############################################ Create Logstash ingestor ############################################
resource "aws_security_group" "logstash_ingestor_server_sg" {
  vpc_id = aws_vpc.vpc.id

  # Allow ICMP from jumpbox
  ingress {
    description = "Allow ICMP from corp subnet and jumpbox"
    from_port = 8
    to_port = 0
    protocol = "icmp"
    cidr_blocks = ["${aws_instance.jump_box.private_ip}/32", var.corpCIDRblock]
  }

  # Allow SSH from jumpbox
  ingress {
    description = "Allow SSH from jumpbox"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.jump_box.private_ip}/32"]
  }

  # Logstash BEATs port
	ingress {
    from_port   = 5044
    to_port     = 5044
    protocol    = "tcp"
    cidr_blocks = [var.corpCIDRblock, "${aws_instance.jump_box.private_ip}/32"]
  }
 	
  # Allow SIEMs to consume logs from Kafka
	ingress {
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = [var.publicCIDRblock, "${aws_instance.jump_box.private_ip}/32"]
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
  subnet_id 							= aws_subnet.corp_subnet.id
  vpc_security_group_ids 	= [aws_security_group.logstash_ingestor_server_sg.id]
  key_name 								= "${var.VPC_NAME}-ssh-key"
  private_ip	            = "${var.corp_servers_map["logstash_ingestor"]}"
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

############################################ Wiki server ############################################
resource "aws_security_group" "wiki_server_sg" {
  vpc_id = aws_vpc.vpc.id

  # Allow ICMP from jumpbox
  ingress {
    description = "Allow ICMP from corp subnet and jumpbox"
    from_port = 8
    to_port = 0
    protocol = "icmp"
    cidr_blocks = ["${aws_instance.jump_box.private_ip}/32", var.corpCIDRblock]
  }

  # Allow SSH from jumpbox
  ingress {
    description = "Allow SSH from jumpbox"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.jump_box.private_ip}/32"]
  }

  # Allow NGINX via HTTP
	ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.jump_box.private_ip}/32", var.corpCIDRblock]
  }
 	
  # Allow NGINX via HTTPS
	ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.jump_box.private_ip}/32", var.corpCIDRblock]
  }
 	
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.VPC_NAME}_WIKI_SERVER_SG"
  }
}

resource "aws_instance" "wiki_server" {
  ami           					= var.ubunut-ami
  instance_type 					= "t3.medium"
  subnet_id 							= aws_subnet.corp_subnet.id
  vpc_security_group_ids 	= [aws_security_group.wiki_server_sg.id]
  key_name 								= "${var.VPC_NAME}-ssh-key"
  private_ip	            = "${var.corp_servers_map["wiki_server"]}"
  disable_api_termination = true

	root_block_device {
		volume_size	= 40
		volume_type = "gp2"
		delete_on_termination = true
	}

 	tags = {
  	Name = "${var.VPC_NAME}_wiki_server"
 	}
}


############################################ Windows file server ############################################
# Create Security group for Win2k16 server
resource "aws_security_group" "windows_file_server_sg" {
  vpc_id = aws_vpc.vpc.id
  
  # Allow ICMP from jumpbox
  ingress {
    description = "Allow ICMP from corp subnet and jumpbox"
    from_port = 8
    to_port = 0
    protocol = "icmp"
    cidr_blocks = ["${aws_instance.jump_box.private_ip}/32", var.corpCIDRblock]
  }

  # Allow ANYTHING from corp subnet and jumpbox
	ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${aws_instance.jump_box.private_ip}/32", var.corpCIDRblock]
  }

 	egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.VPC_NAME}_WINDOWS_SERVER_SG"
  }
}

resource "aws_instance" "windows_file_server" {
	ami           					= var.windows-ami
  instance_type 					= "t3.medium"
  subnet_id 							= aws_subnet.corp_subnet.id
  vpc_security_group_ids 	= [aws_security_group.windows_file_server_sg.id]
  key_name 								= "${var.VPC_NAME}-ssh-key"
	private_ip							= "${var.corp_servers_map["win_file_sever"]}"
  get_password_data       = true
  disable_api_termination = true

	root_block_device {
		volume_size	= 40
		volume_type = "gp2"
		delete_on_termination = true
	}

 	tags = {
  	Name = "${var.VPC_NAME}_WINDOWS_FILE_SERVER"
 	}
}
 
############################################ macos - alpha ############################################
resource "aws_security_group" "macos_sg" {
  vpc_id = aws_vpc.vpc.id

  # Allow jumbox and CORP network
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${aws_instance.jump_box.private_ip}/32", var.corpCIDRblock]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.VPC_NAME}_MACOS_SG"
  }
}

resource "aws_instance" "mac_instance_alpha" {
  ami           					= var.macos-ami
  instance_type 					= "mac1.metal"
  host_id                 = "${var.macos_dedicated_hosts["alpha"]}"
  subnet_id 							= aws_subnet.corp_subnet.id
  vpc_security_group_ids 	= [aws_security_group.macos_sg.id]
  key_name 								= "${var.VPC_NAME}-ssh-key"
  private_ip	            = "${var.corp_servers_map["macos_alpha"]}"
  disable_api_termination = true

  root_block_device {
		volume_size	= 100
		volume_type = "gp2"
		delete_on_termination = true
	}

 	tags = {
  	Name = "${var.VPC_NAME}_MACOS_ALPHA"
 	}
}

resource "aws_instance" "mac_instance_beta" {
  ami           					= var.macos-ami
  instance_type 					= "mac1.metal"
  host_id                 = "${var.macos_dedicated_hosts["beta"]}"
  subnet_id 							= aws_subnet.corp_subnet.id
  vpc_security_group_ids 	= [aws_security_group.macos_sg.id]
  key_name 								= "${var.VPC_NAME}-ssh-key"
  private_ip	            = "${var.corp_servers_map["macos_beta"]}"
  disable_api_termination = true

  root_block_device {
		volume_size	= 100
		volume_type = "gp2"
		delete_on_termination = true
	}

 	tags = {
  	Name = "${var.VPC_NAME}_MACOS_BETA"
 	}
}

resource "aws_instance" "mac_instance_charlie" {
  ami           					= var.macos-ami
  instance_type 					= "mac1.metal"
  host_id                 = "${var.macos_dedicated_hosts["charlie"]}"
  subnet_id 							= aws_subnet.corp_subnet.id
  vpc_security_group_ids 	= [aws_security_group.macos_sg.id]
  key_name 								= "${var.VPC_NAME}-ssh-key"
  private_ip	            = "${var.corp_servers_map["macos_charlie"]}"
  disable_api_termination = true

  root_block_device {
		volume_size	= 100
		volume_type = "gp2"
		delete_on_termination = true
	}

 	tags = {
  	Name = "${var.VPC_NAME}_MACOS_CHARLIE"
 	}
}