# variables.tf

variable "VPC_NAME" {
  default = "OTRF_DEFCON_2021"
}

variable "vpcCIDRblock" {
  default = "172.16.0.0/16"
}

variable "availabilityZone" {
  default = "us-east-2a"
}

variable "instanceTenancy" {
  default = "default"
}

variable "dnsSupport" {
  default = true
}

variable "dnsHostNames" {
  default = true
}

variable "ubunut-ami" {
  # Ubuntu 20.04
  default = "ami-064446ad1d755489e"
}

variable "windows-ami" {
  # Windows Sever 2019
  #default = "ami-0a16ffe32a92704ea"
}


# Management subnet
variable "managementCIDRblock" {
  default = "172.16.21.0/24"
}

# public subnet
variable "publicCIDRblock" {
  default = "172.16.43.0/24"
}

# CORP subnet
variable "corpCIDRblock" {
  default = "172.16.50.0/24"
}

variable "ingressCIDRblock" {
  default = ["0.0.0.0/0"]
}

variable "egressCIDRblock" {
  default = ["0.0.0.0/0"]
}

variable "mapPublicIP" {
  default = true
}

variable "siem_servers_map" {
  type = map
  default = {
    "splunk_alpha" = "172.16.43.100",
    "splunk_beta" = "172.16.43.101",
    "elastic_alpha" = "172.16.43.110",
    "elastic_beta" = "172.16.43.111",
    "graylog_alpha" = "172.16.43.120",
    "graylog_beta" = "172.16.43.121",
    "logstash_ingestor" = "172.16.43.10"
  }
}

variable "management_subnet_map" {
  type = map
  default = {
    "jumpbox" = "172.16.21.100",
    "red_team_box_alpha" = "172.16.21.200",
    "red_team_box_beta" = "172.16.21.2001"
  }
}

variable "corp_servers_map" {
  type = map
  default = {
    "WinDC" = "172.16.50.100",
    "alpha" = "172.16.50.101",
    "beta" = "172.16.50.102",
    "charlie" = "172.16.50.103"
  }
}