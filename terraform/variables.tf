# variables.tf

variable "VPC_NAME" {
  default = "OTR_DEFCON_2021"
}

variable "vpcCIDRblock" {
  default = "172.16.0.0/16"
}

variable "availabilityZone" {
  default = "us-east-2b"
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

variable "internalCorpDomain" {
  default = "hac.local"
}

variable "ubunut-ami" {
  # Ubuntu 20.04
  # https://cloud-images.ubuntu.com/locator/ec2/
  default = "ami-00399ec92321828f5"
}

variable "macos-ami" {
  # macOS Catalina 10.15.7
  default = "ami-0dcfefad26e3bde40"
}

variable "macos-mojave-ami" {
  # macOS Mojave 10.14.6
  default = "ami-0924cd7ae910285e4"
}

variable "windows-ami" {
  # Windows Sever 2019
  default = "ami-086850e3dda52e84a"
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
    "splunk" = "172.16.43.100",
    "elastic" = "172.16.43.110",
    "graylog" = "172.16.43.120",
    "arkmie" = "172.16.43.130"
  }
}

variable "management_subnet_map" {
  type = map
  default = {
    "jumpbox" = "172.16.21.100",
    "red_team_box_alpha" = "172.16.21.200",
    "red_team_box_beta" = "172.16.21.201"
  }
}

variable "corp_servers_map" {
  type = map
  default = {
    "logstash_ingestor" = "172.16.50.10"
    "win_file_sever" = "172.16.50.20"
    "wiki_server" = "172.16.50.30"
    "macos_alpha" = "172.16.50.130"
    "macos_beta" = "172.16.50.131"
    "macos_charlie" = "172.16.50.132"
  }
}

variable "macos_dedicated_hosts" {
  type = map
  default = {
    "alpha" = "h-0a10a5ac0e5ea5cf5"
    "beta" = "h-0a0089ffea5b9db2c"
    "charlie" = "h-0ac39554558ce2867"
  }
}