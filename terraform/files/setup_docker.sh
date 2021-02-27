#!/bin/bash
# Uninstall old versions
sudo apt-get remove docker docker-engine docker.io containerd runc -y

# Install using the repository
sudo apt-get update -y
sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y

# Add Docker’s official GPG key:
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add stable repo
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# INSTALL DOCKER ENGINE
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io -y

# Enable Docker service
sudo systemctl enable docker

# Add user to docker group
usermod -aG docker ubuntu