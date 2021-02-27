############################################# Create VPC ############################################
resource "aws_vpc" "vpc" {
	cidr_block           = var.vpcCIDRblock
	instance_tenancy     = var.instanceTenancy
	enable_dns_support   = var.dnsSupport
	enable_dns_hostnames = var.dnsHostNames
	tags = {
		Name = "${var.VPC_NAME}_VPC"
	}
}

############################################ Create the Internet Gateway ############################################
resource "aws_internet_gateway" "VPC_IGW" {
	vpc_id = aws_vpc.vpc.id
	tags = {
		Name = "${var.VPC_NAME}_VPC_Internet_Gateway"
	}
}

# Create the Route Table
resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.vpc.id
 	    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.VPC_IGW.id
    }

    tags = {
        Name = "${var.VPC_NAME}_VPC_public_route_table"
 	}
}


############################################ Create management subnet ############################################
resource "aws_subnet" "management_subnet" {
	vpc_id                  = aws_vpc.vpc.id
    cidr_block              = var.managementCIDRblock
	map_public_ip_on_launch = false
    availability_zone       = var.availabilityZone
	
 	tags = {
        Name = "${var.VPC_NAME}_management_subnet"
 	}
}

# Associate the management Route Table with the management Subnet
resource "aws_route_table_association" "management_route_table_association" {
    subnet_id      = aws_subnet.management_subnet.id
    route_table_id = aws_route_table.public_route_table.id
}

############################################ Create SIEM/public subnet ############################################
resource "aws_subnet" "public_subnet" {
	vpc_id                  = aws_vpc.vpc.id
    cidr_block              = var.publicCIDRblock
	map_public_ip_on_launch = false
    availability_zone       = var.availabilityZone
	
 	tags = {
        Name = "${var.VPC_NAME}_public_subnet"
 	}
}

# Associate the management Route Table with the management Subnet
resource "aws_route_table_association" "publicroute_table_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

############################################ Create CORP subnet ############################################
resource "aws_subnet" "corp_subnet" {
	vpc_id                  = aws_vpc.vpc.id
    cidr_block              = var.corpCIDRblock
	map_public_ip_on_launch = false
    availability_zone       = var.availabilityZone
	
 	tags = {
        Name = "${var.VPC_NAME}_corp_subnet"
 	}
}

############################################ Create NAT gateway ############################################
resource "aws_eip" "nat_gw_eip" {
    vpc = true
}

resource "aws_nat_gateway" "nat_gw" {
    allocation_id = aws_eip.nat_gw_eip.id
    subnet_id     = aws_subnet.public_subnet.id
}


# Create the Route Table
resource "aws_route_table" "private_route_table" {
    vpc_id = aws_vpc.vpc.id
 	route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.nat_gw.id
    }

    tags = {
        Name = "${var.VPC_NAME}_VPC_private_route_table"
 	}
}

# Associate the corp Route Table with the corp Subnet
resource "aws_route_table_association" "corp_route_table_association" {
    subnet_id      = aws_subnet.corp_subnet.id
    route_table_id = aws_route_table.private_route_table.id
}