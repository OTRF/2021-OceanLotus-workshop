# Setup hMail server as a mail server

## Install hMaiLServer
1. [Download hMaiLServer](https://www.hmailserver.com/download_getfile/?performdownload=1&downloadid=262)
1. Install hMaiLServer
1. Select database-type
    1. Select `Use built-in database engine`
1. Enter `<mysql_hMailServer_password from group_vars/corp.yml>` for password

## Domains and accounts
1. Start hMailAdmin
1. Enter `<mysql_hMailServer_password from group_vars/corp.yml>` for password

### Create domain
1. Select "Domains" on the left
1. Select "Add" on the right
    1. Enter `hac.local` into domain
    1. ![hmail_create_domain](../.img/hmail_create_domain.png)
    1. Select "Save"

### Create users
1. Domains > `<internalCorpDomain in terraform/variables.tf>`> Accounts
1. Select "Add" on the right
    1. Enter `<username>` into address
    1. Enter `<user password>` into Password
    1. Repeat for all users
    1. ![hmail_create_users](../.img/hmail_create_users.png)
    
## Test mail server
1. Download and install Thunderbird
1. Manually add e-mail
    1. ![hmail_thick_client](../.img/hmail_thick_client.png)

## References
* [Getting Started with hMailServer: Installation and Configuration](https://adamtheautomator.com/hmailserver/)
* [64bit MySQL requires 32bit libmysql.dll](https://www.hmailserver.com/forum/viewtopic.php?t=26759)
* [ERROR 1396 (HY000): Operation CREATE USER failed for 'jack'@'localhost'](https://stackoverflow.com/questions/5555328/error-1396-hy000-operation-create-user-failed-for-jacklocalhost)
* [HOW DO I CREATE A NEW DATABASE AND DATABASE USER IN MYSQL?](https://matomo.org/faq/how-to-install/faq_23484/)
* [Securing the Initial MySQL Accounts](http://download.nust.na/pub6/mysql/doc/refman/5.1/en/default-privileges.html#:~:text=On%20Windows%2C%20if%20you%20want,so%20removing%20it%20improves%20security.)
* [What is the default username and password in MySQL?](https://tableplus.com/blog/2018/11/what-is-the-default-username-password-in-mysql.html#:~:text=In%20MySQL%2C%20by%20default%2C%20the,skip%2Dgrant%2Dtables%20option.)
* [Installation tutorial](https://www.hmailserver.com/documentation/v5.4/?page=howto_install)
* []()
* []()
* []()
* []()
* []()