#### Add SSH keys ####
# https://www.bogotobogo.com/DevOps/Terraform/Terraform-parameters-variables.php
resource "aws_key_pair" "deployer" {
  key_name   = "${var.VPC_NAME}-ssh-key"
  public_key = file("ssh_keys/id_rsa.pub")
}