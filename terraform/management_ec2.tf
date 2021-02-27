############################################ Create Jump host ############################################
# Create Security group for jumpbox
resource "aws_security_group" "jumpbox_pubic_sg" {
  vpc_id = aws_vpc.vpc.id
	ingress {
      from_port   = 1194
      to_port     = 1194
      protocol    = "udp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
 	egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.VPC_NAME}_PUBLIC_SG"
  }
}

resource "aws_instance" "jump_box" {
	ami           					= var.ubunut-ami
  instance_type 					= "t2.small"
  subnet_id 							= aws_subnet.management_subnet.id
  vpc_security_group_ids 	= [aws_security_group.jumpbox_pubic_sg.id]
  key_name 								= "${var.VPC_NAME}-ssh-key"
	private_ip							= "172.16.21.100"
  user_data               = file("files/setup_openvn.sh")
  disable_api_termination = true

 	tags = {
  	Name = "${var.VPC_NAME}_jump_box"
 	}
}

resource "aws_eip" "jump_box_eip" {
	instance = aws_instance.jump_box.id
  vpc = true
}

############################################ Create Grafana instance ############################################
resource "aws_security_group" "grafana_server_sg" {
  vpc_id = aws_vpc.vpc.id
  # Allow ICMP from management subnet
  ingress {
      description = "Allow ICMP from management subnet"
      from_port = 8
      to_port = 0
      protocol = "icmp"
      cidr_blocks = ["${aws_instance.jump_box.private_ip}/32"]
  }
  ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["${aws_instance.jump_box.private_ip}/32"]
  }
  # Allow Docker-machine
  ingress {
      from_port   = 2376
      to_port     = 2377
      protocol    = "tcp"
      cidr_blocks = ["${aws_instance.jump_box.private_ip}/32"]
  }
	ingress {
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      cidr_blocks = ["${aws_instance.jump_box.private_ip}/32"]
  }
	ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["${aws_instance.jump_box.private_ip}/32"]
  }
	ingress {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["${aws_instance.jump_box.private_ip}/32"]
  }
	ingress {
      from_port   = 8086
      to_port     = 8086
      protocol    = "tcp"
      cidr_blocks = [var.corpCIDRblock, var.managementCIDRblock]
  }
	ingress {
      from_port   = 9090
      to_port     = 9090
      protocol    = "tcp"
      cidr_blocks = [var.corpCIDRblock, var.managementCIDRblock]
  }
 	egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.VPC_NAME}_GRAFNA_SERVER_SG"
  }
}

resource "aws_instance" "grafana_server" {
	ami           					= var.ubunut-ami
  instance_type 					= "t2.medium"
  subnet_id 							= aws_subnet.corp_subnet.id
  vpc_security_group_ids 	= [aws_security_group.grafana_server_sg.id]
  key_name 								= "${var.VPC_NAME}-ssh-key"
	private_ip							= "172.16.44.200"
  user_data               = file("files/setup_docker.sh")

	root_block_device {
		volume_size	= 40
		volume_type = "gp2"
		delete_on_termination = true
	}

 	tags = {
  	Name = "${var.VPC_NAME}_GRAFNA_SERVER"
 	}
}

# ############################################ Create Powershell Empire ############################################
# resource "aws_security_group" "empire_server_sg" {
#   vpc_id = aws_vpc.vpc.id
#   # Allow ICMP from management subnet
#   ingress {
#       description = "Allow ICMP from management subnet"
#       from_port = 8
#       to_port = 0
#       protocol = "icmp"
#       cidr_blocks = [var.managementCIDRblock]
#   }
#   ingress {
#       from_port   = 22
#       to_port     = 22
#       protocol    = "tcp"
#       cidr_blocks = ["${aws_instance.jump_box.private_ip}/32"]
#   }
#   # Allow node-exporter
#   ingress {
#       from_port   = 9100
#       to_port     = 9100
#       protocol    = "tcp"
#       cidr_blocks = ["${aws_instance.grafana_server.private_ip}/32"]
#   }
# 	ingress {
#       from_port   = 80
#       to_port     = 80
#       protocol    = "tcp"
#       cidr_blocks = ["0.0.0.0/0"]
#   }
# 	ingress {
#       from_port   = 443
#       to_port     = 443
#       protocol    = "tcp"
#       cidr_blocks = ["0.0.0.0/0"]
#   }
# 	ingress {
#       from_port   = 7000
#       to_port     = 8000
#       protocol    = "tcp"
#       cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#       from_port   = 8001
#       to_port     = 8001
#       protocol    = "tcp"
#       cidr_blocks = [var.managementCIDRblock,var.corpCIDRblock]
#   }
#   ingress {
#       from_port   = 8002
#       to_port     = 9000
#       protocol    = "tcp"
#       cidr_blocks = ["0.0.0.0/0"]
#   }
#  	egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   tags = {
#     Name = "${var.VPC_NAME}_PUBLIC_SG"
#   }
# }

# resource "aws_instance" "empire_server" {
# 	ami           					= var.ubunut-ami
#   instance_type 					= "t2.small"
#   subnet_id 							= aws_subnet.management_subnet.id
#   vpc_security_group_ids 	= [aws_security_group.empire_server_sg.id]
#   key_name 								= "${var.VPC_NAME}-ssh-key"
# 	private_ip							= "172.16.21.200"
#   user_data               = file("files/setup_empire.sh")

#  	tags = {
#   	Name = "${var.VPC_NAME}_EMPIRE_SERVER"
#  	}
# }

# resource "aws_eip" "empire_server_eip" {
# 	instance = aws_instance.empire_server.id
#   vpc = true
# }

# ############################################ Create caldera ############################################
# resource "aws_security_group" "caldera_server_sg" {
#   vpc_id = aws_vpc.vpc.id
#   # Allow ICMP from management subnet
#   ingress {
#       description = "Allow ICMP from management subnet"
#       from_port = 8
#       to_port = 0
#       protocol = "icmp"
#       cidr_blocks = [var.managementCIDRblock]
#   }
#   ingress {
#       from_port   = 22
#       to_port     = 22
#       protocol    = "tcp"
#       cidr_blocks = ["${aws_instance.jump_box.private_ip}/32"]
#   }
#   # Allow node-exporter
#   ingress {
#       from_port   = 9100
#       to_port     = 9100
#       protocol    = "tcp"
#       cidr_blocks = ["${aws_instance.grafana_server.private_ip}/32"]
#   }
# 	ingress {
#       from_port   = 8888
#       to_port     = 8888
#       protocol    = "tcp"
#       cidr_blocks = ["${aws_instance.jump_box.private_ip}/32"]
#   }
#   ingress {
#       from_port   = 80
#       to_port     = 80
#       protocol    = "tcp"
#       cidr_blocks = ["0.0.0.0/0"]
#   }
# 	ingress {
#       from_port   = 443
#       to_port     = 443
#       protocol    = "tcp"
#       cidr_blocks = ["0.0.0.0/0"]
#   }
# 	ingress {
#       from_port   = 8000
#       to_port     = 9000
#       protocol    = "tcp"
#       cidr_blocks = ["0.0.0.0/0"]
#   }
#  	egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   tags = {
#     Name = "${var.VPC_NAME}_PUBLIC_SG"
#   }
# }

# resource "aws_instance" "caldera_server" {
# 	ami           					= var.ubunut-ami
#   instance_type 					= "t2.small"
#   subnet_id 							= aws_subnet.management_subnet.id
#   vpc_security_group_ids 	= [aws_security_group.caldera_server_sg.id]
#   key_name 								= "${var.VPC_NAME}-ssh-key"
# 	private_ip							= "172.16.21.201"
#   user_data               = file("files/setup_caldera.sh")
#   disable_api_termination = true
  
#  	tags = {
#   	Name = "${var.VPC_NAME}_caldera_SERVER"
#  	}
# }

# resource "aws_eip" "caldera_server_eip" {
# 	instance = aws_instance.caldera_server.id
#   vpc = true
# }