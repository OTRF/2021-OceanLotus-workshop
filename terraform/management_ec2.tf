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
	private_ip							= "${var.management_subnet_map["jumpbox"]}"
  user_data               = file("files/setup_openvpn.sh")
  disable_api_termination = true

 	tags = {
  	Name = "${var.VPC_NAME}_jump_box"
 	}
}

resource "aws_eip" "jump_box_eip" {
	instance = aws_instance.jump_box.id
  vpc = true
  tags = {
    Name = "${var.VPC_NAME}_jump_box_eip"
  }
}

########################################### Create red team box - alpha ############################################
resource "aws_security_group" "red_team_server_alpha_sg" {
  vpc_id = aws_vpc.vpc.id

  # Allow ICMP from jumpbox
  ingress {
    description = "Allow ICMP from management subnet"
    from_port = 8
    to_port = 0
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH from jumpbox
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.jump_box.private_ip}/32"]
  }

  # Allow all traffic form jumpbox
	ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${aws_instance.jump_box.private_ip}/32"]
  }
 
  # Allow all egress outbound
 	egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.VPC_NAME}_RED_TEAM_SERVER_ALPHA_SG"
  }

}

resource "aws_instance" "red_team_server_alpha" {
	ami           					= var.ubunut-ami
  instance_type 					= "t2.small"
  subnet_id 							= aws_subnet.management_subnet.id
  vpc_security_group_ids 	= [aws_security_group.red_team_server_alpha_sg.id]
  key_name 								= "${var.VPC_NAME}-ssh-key"
	private_ip							= "${var.management_subnet_map["red_team_box_alpha"]}"

  root_block_device {
		volume_size	= 40
		volume_type = "gp2"
		delete_on_termination = true
	}

 	tags = {
  	Name = "${var.VPC_NAME}_RED_TEAM_BOX_ALPHA"
 	}
}

resource "aws_eip" "red_team_box_alpha_eip" {
	instance = aws_instance.red_team_server_alpha.id
  vpc = true
}

########################################### Create red team box - beta ############################################
resource "aws_security_group" "red_team_server_beta_sg" {
  vpc_id = aws_vpc.vpc.id

  # Allow ICMP from jumpbox
  ingress {
    description = "Allow ICMP from management subnet"
    from_port = 8
    to_port = 0
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH from jumpbox
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.jump_box.private_ip}/32"]
  }

   # Allow all traffic form jumpbox
	ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${aws_instance.jump_box.private_ip}/32"]
  }
 
  # Allow all egress outbound
 	egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.VPC_NAME}_RED_TEAM_SERVER_ALPHA_SG"
  }

}

resource "aws_instance" "red_team_server_beta" {
	ami           					= var.ubunut-ami
  instance_type 					= "t2.small"
  subnet_id 							= aws_subnet.management_subnet.id
  vpc_security_group_ids 	= [aws_security_group.red_team_server_alpha_sg.id]
  key_name 								= "${var.VPC_NAME}-ssh-key"
	private_ip							= "${var.management_subnet_map["red_team_box_beta"]}"

  root_block_device {
		volume_size	= 40
		volume_type = "gp2"
		delete_on_termination = true
	}

 	tags = {
  	Name = "${var.VPC_NAME}_RED_TEAM_BOX_BETA"
 	}
}

resource "aws_eip" "red_team_box_beta_eip" {
	instance = aws_instance.red_team_server_beta.id
  vpc = true
}