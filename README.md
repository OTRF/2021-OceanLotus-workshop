# macos-workshops

# Table of Contents  
* [Network diageam](#network-diagram)  
* [AWS pricing](#aws-pricing)
* [AWS inital setup](#AWS-inital-setup)
  * [Create an AWS account](##Create-an-AWS)
  * [Select a region](##Select-a-region)
  * [Install/Setup AWS CLI on macOS](##Install/Setup-AWS-CLI-on-macOS)
* [Install/Setup Terraform](#Install/Setup-Terraform)
* [Setup/Create management subnet](#Setup/Create-management-subnet)
  * [Setup jumpbox/VPN](##Setup-jumpbox/VPN)
* [References](##References)

# Network diagram
<p align="center">
  <img width="460" height="300" src=".img/aws_network_diagram.png">
</p>

# AWS pricing
Below is a table of all the AWS compute resources needed for this workshop. Depending your target audience size you can adjsut the size allocations for each machine. The SIEM machines use `r5` machines to provide as much memory as possible to keep search times down.

It should be noted at the time of this writing that if you plan on running this setup in AWS including the macOS machines even before they are turned on it's $25 per macOS instance. The macOS license states that each instance must be used at least 24 hours. Even, if you use macOS machines for 3 seconds you still end up paying for 24 hours worth of use.

Let's discuss the $5.1774 per hour pricing listed below. It should be noted that hourly price listed is only the EC2 computing. The pricing does not include: 
  * networking (ingress/egress) charges
  * Storage which is $0.10 per GB-month = $74.88
  * macOS up-front license cost which is $25 per instance = $75
  * API costs
  * Etc

Despite all the things listed above, it roughly costs roughly $200 to run a 6 hour workshop. Math:
  * $25 * 3 for macOS machines
  * 6 hour workshop * $5.1744/hr
  * 1 month of storage as $0.10/GB-month
  * Adding $20 for networking and etc

Lastly, on normal user accounts AWS imposes a 32 vCPUs limit. You will need to request a vCPU limit increase and you can use the table below as jsutification for that increase.

| # | EC2 type | vCPU | Memory | SSD | Rate per hour | Description
| --- | --- | --- | --- | --- | --- | --- |
| 1 | r5.2xlarge | 8 | 64GB | 100GB | $0.504 | Elastic server |
| 2 | r5.2xlarge | 8 | 64GB | 100GB | $0.504 | Graylog server |
| 3 | r5.2xlarge | 8 | 64GB | 100GB | $0.504 | Splunk server |
| 4 | t2.small | 1 | 2GB | 8GB | $0.023 | Jumpbox |
| 5 | t2.small | 1 | 2GB | 20GB | $0.023 | red team box - alpha |
| 6 | t2.small | 1 | 2GB | 20GB | $0.023 | red team box - beta |
| 7 | t2.xlarge	 | 4 | 16GB | 100GB | $0.1856	 | NSM server |
| 8 | t2.large | 2 | 8GB | 20GB | $0.0928 | Logstah ingestor server |
| 9 | t2.small | 1 | 2GB | 20GB | $0.023 | wiki server |
| 10 | t2.small | 1 | 2GB | 20GB | $0.0234 | file server |
| 11 | t2.small | 1 | 2GB | 60GB | $0.0234 | Windows server |
| 12 | mac1.metal	 | 12 | 32GB | 60GB | $1.083 | macOS client - alpha |
| 13 | mac1.metal	 | 12 | 32GB | 60GB | $1.083 | macOS client - beta |
| 14 | mac1.metal	 | 12 | 32GB | 60GB | $1.083 | macOS client - charlie |
| Total |          | 72 | 320GB | 748GB  | $5.1774/hr | |

# AWS inital setup
## Create an AWS account
Follow the steps on this [page to create an AWS account](https://aws.amazon.com/premiumsupport/knowledge-center/cre.  ate-and-activate-aws-account/)

## Select a region
Once you login into AWS it should automatically select the nearest datacenter based on your IP address. This repo has been created and tested on the `US East - Ohio` datacenter. This repo should be compatible with any region but pick the best region based on your location/users.

![AWS region](.img/aws_region.png)

## Install/Setup AWS CLI on macOS
* [AWS CLI Windows install](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-windows.html)
* [AWS CLI Linux install](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html)
* [AWS CLI macOS install](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-mac.html)

1. Select `<YOUR username>` in the top-right then "My Security Credentials"
1. Scroll down to "Access keys for CLI..."
1. Select "Create access key"
  1. Save your generated access key ID and secret access key in a safe location

1. Open terminal
1. `curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o /tmp/AWSCLIV2.pkg`
  1. Download AWS CLI v2
1. `sudo installer -pkg /tmp/AWSCLIV2.pkg -target /`
  1. Install AWS CLI v2
1. `aws configure`
  1. Paste the access key ID generated from above
  1. Paste the access key generated from above
  1. Enter your region - Ohio is `us-east-2`
  1. Leave ouput format as default
  1. ![aws configure setup](.img/aws_configure_setup.png)
1. Credentails are saved at `~/.aws/credentials`

## Install/Setup Terraform
### Install Terraform on macOS
It should be noted that this repo only supports Terraform v0.15 and greater.

* [Terraform install on Windows](https://learn.hashicorp.com/tutorials/terraform/install-cli)
* [Terraform install on Linux ](https://learn.hashicorp.com/tutorials/terraform/install-cli)
* [Terraform install on macOS](https://learn.hashicorp.com/tutorials/terraform/install-cli)

1. `brew tap hashicorp/tap`
1. `brew install hashicorp/tap/terraform`

### Generate SSH key pair
1. `git clone https://github.com/OTRF/macos-workshops`
1. `cd macos-workshops/terraform`
1. `ssh-keygen -b 4096 -t rsa -m pem -f ssh_keys/id_rsa -q -N ""`

### Setup variables.tf
1. `vim variables.tf` and set:
  1. `VPC_NAME` - Set this to a generic name like `OTR_DEFCON_2021`. It's important to note that all resouces created will be prepended with this variable. For example, the EC2 name for the Elastic box will be `OTR_DEFCON_2021_jump_box`.
  1. `vpcCIDRblock` - This defines the network subnet for the VPC. The subnet should be a Class B because Class C subnets will be created inside the VPC. - Default is `172.16.0.0/16`
    1. `managementCIDRblock` - This subnet hosts the VPN/jumpbox and the red team boxes. Set this value to a class C subnet inside the subnet defined above - default `172.16.21.0/24`.
    1. `publicCIDRblock` - This subnet hosts the boxes that will be interacted by workshop participants so the SIEM boxes - default `172.16.43.0/16`
    1. `corpCIDRblock` - This subnet hosts the boxes that will emulate an enterprise environment - default `172.16.50.0/16`
  1. `availabilityZone` - The AWS region to create resources in. Be default this is set to Ohio: `us-east-2a`.
  1. `ubunut-ami` - Set this to the AMI UID 
    1. AWS Services > Compute > EC2 > Images > AMIs
    1. Search for `Ubuntu 20.04`
    1. Copy the AMI ID
  1. Repeat the same steps for the Ubuntu AMI for the Windows server AMI
  1. `siem_servers_map` - This maps SIEM names to IP addresses for the local subnet. It's best to leave this set as default.
  1. `management_subnet_map` - Same as the map above
  1. `corp_servers_map` - Same as the maps above

# Setup/Create management subnet
1. `terraform init`
1. `terraform plan`
1. `terraform apply`
1. Services > Compute > EC2 > Instances > Instances
1. Check `${VPC_NAME}_jump_box` 
1. Actions > Instance settings > Change termination protection
  1. Ensure that termination protection is enabled

## Setup jumpbox/VPN
The Terraform playbook will execute the following script `files/setup_openvpn.sh` to setup an OpenVPN server on the jumpbox.

1. `cat ~/.ssh/id_rsa.pub` and copy output
1. `ssh -i ssh_keys/id_rsa ubuntu@<jumpbox public IPv4>`
1. `echo '<SSH pub key>' >> ~/.ssh/authorized_keys`
1. `sudo su`
1. `apt update -y && apt upgrade -y && reboot`
1. Login into jumpbox using YOUR SSH key
1. Ensure that `client.ovpn` exists in the home directory
1. `sudo su`
1. Add VPC subnets to OpenVPN server config
  1. `echo 'push "route 172.16.43.0 255.255.255.0"' >> /etc/openvpn/server.conf`
  1. `echo 'push "route 172.16.50.0 255.255.255.0"' >> /etc/openvpn/server.conf`
  1. `echo 'push "route 172.16.21.0 255.255.255.0"' >> /etc/openvpn/server.conf`
1. `systemctl restart openvpn@server.service`
1. `exit`
1. `scp ubuntu@3.23.158.45:/home/ubuntu/client.ovpn ~/Desktop/client.ovpn`
  1. Download OpenVPN client config
1. Import the OpenVPN client config into your VPN client


## References
### AWS
* [How do I create and activate a new AWS account?](https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/)
* [Elastic IP addresses](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-eips.html)
* [AWS CLI Windows install](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-windows.html)
* [AWS CLI Linux install](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html)
* [AWS CLI macOS install](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-mac.html)
* [Quick configuration with aws configure](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)
* []()
* []()
* []()
* []()
* []()
* []()


### Terraform
* [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
* [Resource: aws_eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip)
* [Resource: aws_nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway)
* [How to use Terraform variables](https://upcloud.com/community/tutorials/terraform-variables/)
* [Github - angristan/openvpn-install](https://github.com/angristan/openvpn-install)
* []()
* []()
* []()
* []()
* []()
* []()


### OpenVPN
* [Expanding the scope of the VPN to include additional machines on either the client or server subnet.](https://openvpn.net/community-resources/expanding-the-scope-of-the-vpn-to-include-additional-machines-on-either-the-client-or-server-subnet/)
* [How to Download a File from a Server with SSH / SCP](https://osxdaily.com/2016/11/07/download-file-from-server-scp-ssh/)
* []()
* []()
* []()
* []()
* []()
* []()
