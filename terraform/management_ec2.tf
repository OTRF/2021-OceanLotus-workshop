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

############################################ Create red team box - alpha ############################################
# resource "aws_security_group" "empire_server_sg" {
#   vpc_id = aws_vpc.vpc.id
#  # Allow ICMP from jumpbox
#   ingress {
#       description = "Allow ICMP from management subnet"
#       from_port = 8
#       to_port = 0
#       protocol = "icmp"
#       cidr_blocks = ["${aws_instance.jump_box.private_ip}/32"]
#   }

#   # Allow SSH from jumpbox
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

#   # Allow HTTP inbound from anywhere
# 	ingress {
#       from_port   = 80
#       to_port     = 80
#       protocol    = "tcp"
#       cidr_blocks = ["0.0.0.0/0"]
#   }

#   # Allow HTTPS inbound from anywhere
# 	ingress {
#       from_port   = 443
#       to_port     = 443
#       protocol    = "tcp"
#       cidr_blocks = ["0.0.0.0/0"]
#   }

#   # Allow port 7000-9000 inbound from anywhere
# 	ingress {
#       from_port   = 7000
#       to_port     = 9000
#       protocol    = "tcp"
#       cidr_blocks = ["0.0.0.0/0"]
#   }
 
#   # Allow all egress outbound
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

# resource "aws_instance" "red_team_box_alpha" {
# 	ami           					= var.ubunut-ami
#   instance_type 					= "t2.small"
#   subnet_id 							= aws_subnet.management_subnet.id
#   vpc_security_group_ids 	= [aws_security_group.empire_server_sg.id]
#   key_name 								= "${var.VPC_NAME}-ssh-key"
# 	private_ip							= "${var.management_subnet_map["red_team_box_alpha"]}"
#   user_data               = file("files/setup_empire.sh")

#  	tags = {
#   	Name = "${var.VPC_NAME}_RED_TEAM_BOX_ALPHA"
#  	}
# }

# resource "aws_eip" "red_team_box_alpha" {
# 	instance = aws_instance.red_team_box_alpha.id
#   vpc = true
# }
# ############################################ Create red team box - beta ############################################
# resource "aws_security_group" "empire_server_sg" {
#   vpc_id = aws_vpc.vpc.id
#  # Allow ICMP from jumpbox
#   ingress {
#       description = "Allow ICMP from management subnet"
#       from_port = 8
#       to_port = 0
#       protocol = "icmp"
#       cidr_blocks = ["${aws_instance.jump_box.private_ip}/32"]
#   }

#   # Allow SSH from jumpbox
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

#   # Allow HTTP inbound from anywhere
# 	ingress {
#       from_port   = 80
#       to_port     = 80
#       protocol    = "tcp"
#       cidr_blocks = ["0.0.0.0/0"]
#   }

#   # Allow HTTPS inbound from anywhere
# 	ingress {
#       from_port   = 443
#       to_port     = 443
#       protocol    = "tcp"
#       cidr_blocks = ["0.0.0.0/0"]
#   }

#   # Allow port 7000-9000 inbound from anywhere
# 	ingress {
#       from_port   = 7000
#       to_port     = 9000
#       protocol    = "tcp"
#       cidr_blocks = ["0.0.0.0/0"]
#   }
 
#   # Allow all egress outbound
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

# resource "aws_instance" "red_team_box_beta" {
# 	ami           					= var.ubunut-ami
#   instance_type 					= "t2.small"
#   subnet_id 							= aws_subnet.management_subnet.id
#   vpc_security_group_ids 	= [aws_security_group.empire_server_sg.id]
#   key_name 								= "${var.VPC_NAME}-ssh-key"
# 	private_ip							= "${var.management_subnet_map["red_team_box_beta"]}"
#   user_data               = file("files/setup_empire.sh")

#  	tags = {
#   	Name = "${var.VPC_NAME}_RED_TEAM_BOX_BETA"
#  	}
# }

# resource "aws_eip" "red_team_box_beta" {
# 	instance = aws_instance.red_team_box_beta.id
#   vpc = true
# }