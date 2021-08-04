# Red team exercise

## Pre-flight checks
- [ ] Login into all the user accounts via VNC and finish creating the account
    - [ ] macos Alpha
    - [ ] macos Beta
    - [ ] macos Charlie
- [ ] Login into all the user accounts via VNC and make sure OsqueryD has full-disk access
    - [ ] macos Alpha
    - [ ] macos Beta
    - [ ] macos Charlie
- [ ] SSH key exists on macOS BETA and can be used to SSH to the wiki server
- [ ] Test red team stagers
- [ ] User sends user on macOS beta an e-mail stating files exist on wiki server under `Media Manager`
- [ ] Check VPC network traffic sessions
    - [ ] Network traffic session exists for macos Alpha
    - [ ] Network traffic session exists for macos Beta
    - [ ] Network traffic session exists for macos Charlie
    - [ ] Network traffic session exists for wiki
    - [ ] Network traffic session exists for windows file server
    - [ ] Arkmie is turned on and collecting network traffic
- [ ] Arkmie check traffic types
    - [ ] Check for DNS traffic
    - [ ] Check for SMTP and headers
    - [ ] Check for HTTP and headers
- [ ] Ensure SIEMs are ingesting logs correctly 
    - [ ] Run the following command on an endpoint `http://348503745038973.example.com` 
    - [ ] Search Graylog for the following string `http://348503745038973.example.com` 
    - [ ] Search Splunk for the following string `http://348503745038973.example.com`
    - [ ] Search Elastic for the following string `http://348503745038973.example.com`
- [ ] Files for exfil exist on file share and/or wiki
- [ ]
- [ ]
- [ ]
- [ ] Clear indexes - instructions below

## Clear indexes
1. `ansible-playbook -i hosts.ini wipe_indexes.yml -u ubuntu`
    1. Enter `elastic` user password

## Test Open mail relay with telnet
1. `telnet 172.16.50.20 25`
1. `HELO <HOSTNAME>`
1. `MAIL FROM: admin@not-so-cyber-two.net`
1. `RCPT TO: lmanoban@hac.local`
1. 
```
DATA
Subject: hello world
Hello world! I am the test email.
.

QUIT
``` 

## Initial reachout
```python
from email.message import EmailMessage
import smtplib
smtp_server = "172.16.50.20"
port = 25

email_body = """Hello Lalisa, 
Please take a look at the recent news regarding a Microsoft vulnerability. 
https://msrc.microsoft.com/update-guide/vulnerability/CVE-2021-34527.  
Your servers must be patched.  

Let us know if you need any assistance,
IT Team
Not So Cyber Two
"""

msg = EmailMessage()
msg.set_content(email_body)

msg['Subject'] = "Microsoft vulnerability"
msg['From'] = "admin@not-so-cyber-two.net"
msg['To'] = "lmanoban@hac.local"

server = smtplib.SMTP(smtp_server,port)
server.ehlo()
server.send_message(msg)
```

## Phishing e-mail
```python
from email.message import EmailMessage
import smtplib
smtp_server = "172.16.50.20"
port = 25

email_body = """"Hello Hac Team
Check the news, here is contact information about Mrs. Ngoc's

http://18.190.169.168:80/All%20Tim%20Nha%20Chi%20Ngoc%20Canada.doc.app.zip
"""

server = smtplib.SMTP(smtp_server,port)
server.ehlo()

recipients = ['jso-yeon@hac.local','lmanoban@hac.local','dengziqi@hac.local']
for recipient in recipients:
    msg = EmailMessage()
    msg.set_content(email_body)
    msg['Subject'] = "Mrs. Ngoc's contact info"
    msg['From'] = "admin@not-so-cyber-two.net"
    msg['To'] = recipient
    server.send_message(msg)
```


## References
* [Installing IPython](https://ipython.org/install.html)
* [Python: “subject” not shown when sending email using smtplib module](https://stackoverflow.com/questions/7232088/python-subject-not-shown-when-sending-email-using-smtplib-module)
* [Sending Emails With Python](https://realpython.com/python-send-email/)
* []()
* []()