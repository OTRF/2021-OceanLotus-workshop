# 2021 OTRF Decon macOS workshop - Terraform

## Install Terraform on macOS
1. `brew install terraform`
    1. Using version Terraform v0.12.26

## Init AWS config for Terraform
1. `pip3 install awscli`
  1. version
  1. The orginal package `aws` is not compatible with Python3
1. `aws configure`
  1. Enter AWS_ACCESS_KEY_ID
  1. Enter AWS_SECRET_ACCESS_KEY
  1. Enter `us-east-2` for region
  1. Accept default for output format

## Generate SSH key
1. `ssh-keygen -b 2048 -t rsa -m pem -f ssh_keys/id_rsa -q -N ""`

## References
* []()
* []()
* []()
* []()
* []()
* []()
* []()
* []()