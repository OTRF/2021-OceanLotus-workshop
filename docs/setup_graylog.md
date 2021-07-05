# Graylog
For the lastest installation instructions for this repo please see this blog post: [IR TALES: THE QUEST FOR THE HOLY SIEM: GRAYLOG + AUDITD + OSQUERY](https://holdmybeersecurity.com/2021/02/04/ir-tales-the-quest-for-the-holy-siem-graylog-auditd-osquery/)

<span style="color: red"> WARNING </span></br>
This Ansible playbook will allocate half of the systems memory to Elasticsearch. For example, if a machine has 16GBs of memory, 8GBs of memory will be allocated to Elasticsearch.</br>
<span style="color: red"> WARNING </span>

## Init Ansible playbook
1. `vim macos-workshop/ChooseYourSIEMAdventure/hosts.ini` and add the Graylog server IP address under `[graylog]`
1. `vim macos-workshop/ChooseYourSIEMAdventure/group_vars/all.yml` and set:
  1. `base_domain` - Set the domain where the server resides
  1. `timezone` – OPTIONAL – The default timezone is UTC+0
  1. `siem_username` – Ignore this setting
  1. `siem_password` – Set the Graylog admin password
  1. ![Graylog group_vars/all.yml](https://holdmybeersecurity.com/wp-content/uploads/2021/01/Screen-Shot-2021-01-09-at-5.38.46-PM-300x173.png)
1. `vim macos-workshop/ChooseYourSIEMAdventure/group_vars/graylog.yml` and set:
  1. `hostname` – Set the desired hostname for the server
  1. `graylog_version` – Set the desired version of Graylog to use
  1. `beats_port` – OPTIONAL – Set the port to ingest logs using BEAT clients
  1. `elastic_version` – OPTIONAL – Set the desired version of Elasticsearch to use with Graylog – best to leave as default
  1. `mongo_version` – OPTIONAL – Set the desired version of Mongo to use with Graylog – best to leave as default
  1. `mongo_admin_username` – OPTIONAL – Set Mongo admin username – best to leave as default
  1. `mongo_admin_password` – Set the Mongo admin user password
  1. `mongo_graylog_username` – Set Mongo username for Graylog user
  1. `mongo_graylog_password` – Set Mongo password for Graylog user
  1. ![Graylog group_vars/graylog.yml](https://holdmybeersecurity.com/wp-content/uploads/2021/01/Screen-Shot-2021-01-26-at-6.32.24-PM.png)

## Run Ansible playbook
1. `ansible-playbook -i hosts.ini deploy_graylog.yml -u ubuntu`
  1. ![Graylog ansibe playbook](https://holdmybeersecurity.com/wp-content/uploads/2021/01/Screen-Shot-2021-01-20-at-1.46.58-AM-768x401.png)

## Generate Let's Encrypt certificate
1. SSH into Elastic EC2 instance
1. `sudo su`
1. `apt install certbot python3-certbot-nginx -y`
1. `certbot --nginx -d graylog.<external domain>`
  1. Enter the e-mail for the admin of the domain
  1. Enter `A` for Terms of Service
  1. Enter `N` to share e-mail with EFF
  1. Enter `2` to redirect HTTP traffic to HTTPS 
1. Review NGINX config: `/etc/nginx/conf.d/graylog.conf` 
1. `systemctl restart nginx`

## Create workshop user
1. Open browser to `https://graylog.<external domain>` and login
  1. Enter `admin` for username
  1. Enter `<siem_password>` into Password
1. System > Users and Teams
1. Select "Create User" in top right
  1. Enter `threathunter` into username
  1. Enter `threathunter` into full name
  1. Leave e-mail blank
  1. Enter `6` for user session timeout
  1. Enter a password for the user
  1. Select `User inspector` for roles
  1. ![Create Graylog workshop user](.img/graylog_user_create.png)
  1. Select "Create user"

## Create Graylog indexes and streams
### Create indexes
1. System > Indicies
1. Select "Create index set" in the top right
  1. Enter `Osquery` for name
  1. Enter `Osquery logs` for description
  1. Enter `osquery` for index prefix
  1. Leave everything as default
  1. ![Graylog Osquery index](https://holdmybeersecurity.com/wp-content/uploads/2021/01/Screen-Shot-2021-01-27-at-5.21.42-PM-300x280.png)
  1. Select "Save"
1. Repeat the steps above to create an index called "test"

### Create streams
1. Select "Streams" at the top
  1. Select "Create stream" in the top right
  1. Enter `Osquery-stream` for name
  1. Enter `Osquery stream` for description
  1. Select "Osquery" for index set
  1. Check "Remove matches from 'All messages' stream"
  1. ![Graylog Osquery stream](https://holdmybeersecurity.com/wp-content/uploads/2021/01/Screen-Shot-2021-01-27-at-5.26.35-PM-300x228.png)
  1. Select "Save"
1. Repeat the steps above to create an index called "test" 
1. Select "Manage Rules" for Osquery stream
1. Select “Add stream rule” on the right
  1. Enter `filebeat_service_type` for field
  1. Select `match exactly` for type
  1. Enter `osquery` for value
  1. ![Graylog Osquery stream rule](https://holdmybeersecurity.com/wp-content/uploads/2021/01/Screen-Shot-2021-01-27-at-5.30.41-PM-300x260.png)
  1. Select "Save"
  1. ![](https://holdmybeersecurity.com/wp-content/uploads/2021/01/Screen-Shot-2021-01-27-at-5.31.15-PM-249x300.png)
1. Select "I’m done" in bottom left
1. Select "Start stream" for Osquery stream
1. Repeat the steps above for test