# Install/Setup Arkmie (formley known as Moloch)

## Init Ansible playbook
1. `vim macos-workshop/hosts.ini` and add the Arkmie server IP address under `[arkmie]`
1. `cp group_vars/sec_tools.yml.example group_vars/sec_tools.yml`
1. `vim group_vars/sec_tools.yml` and set:
  1. `monitoring_interface` – Set this to the interface that will be used for network monitoring
  1. `arkmie_version` – Set the version of Arkmie to install
  1. `arkmie_admin_user` - Username of Arkmie admin
  1. `arkmie_admin_password` - Password for Arkmie admin
  1. `arkmie_regular_user` - Username for workshop participant account
  1. `arkmie_regular_password` - Password for workshop participants
  1. `elasticsearch_oss_version` - Elasticsearch OSS version to install
  1. ![Arkmie ansible - group_vars/sec_tools.yml](../.img/ansible_arkmie.png)

## Run Ansible playbook
1. `ansible-playbook -i hosts.ini deploy_arkmie.yml -u ubuntu --key-file terraform/ssh_keys/id_rsa`

## Generate Let's Encrypt certificate
1. SSH into Elastic EC2 instance
1. `sudo su`
1. `apt install certbot python3-certbot-nginx -y`
1. `certbot --nginx -d arkmie.<external domain>`
  1. Enter the e-mail for the admin of the domain
  1. Enter `A` for Terms of Service
  1. Enter `N` to share e-mail with EFF
  1. Enter `2` to redirect HTTP traffic to HTTPS 
1. Review NGINX config: `/etc/nginx/conf.d/kibana.conf` 
1. `systemctl restart nginx`

## Clearing index data
1. `systemctl stop molochviewer`
1. `systemctl stop molochcapture`
1. `/data/moloch/db/db.pl http://127.0.0.1:9200 wipe`
  1. Type `WIPE`
1. `systemctl start molochviewer`
1. `systemctl start molochcapture`

## References
* [Redirect HTTP to HTTPS in Nginx](https://serversforhackers.com/c/redirect-http-to-https-nginx)
* [Arkmie - How do I proxy Arkime using Apache](https://arkime.com/faq)
* [How To Create a Self-Signed SSL Certificate for Nginx in Ubuntu 16.04](https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-in-ubuntu-16-04)
* [Arkmie install instructions](https://raw.githubusercontent.com/arkime/arkime/main/release/README.txt)
* [How To Install Java with Apt on Ubuntu 20.04](https://www.digitalocean.com/community/tutorials/how-to-install-java-with-apt-on-ubuntu-20-04)
* [community.docker.docker_swarm – Manage Swarm cluster](https://docs.ansible.com/ansible/latest/collections/community/docker/docker_swarm_module.html)
* [How to Use the Netplan Network Configuration Tool on Linux](https://www.linux.com/topic/distributions/how-use-netplan-network-configuration-tool-linux/)
* [Elasticsearch](https://docs.graylog.org/en/4.0/pages/installation/os/ubuntu.html)
* [Elasticsearch - Response Data Formats](https://www.elastic.co/guide/en/elasticsearch/reference/current/sql-rest-format.html)
* [cat indices API](https://www.elastic.co/guide/en/elasticsearch/reference/current/cat-indices.html)
* [Elasticsearch - Delete API](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-delete.html)
* []()
* []()
* []()
* []()
* []()