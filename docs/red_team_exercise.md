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

## Open mail relay test
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


## Time frame of red team exercise actions
| # | Time | MITRE technique | Notes |
| --- | --- | --- | --- |
| 1 | 587641616 | TXXX | Initial comp | 
| 1 | 587641616 | TXXX | Initial comp | 
| 1 | 587641616 | TXXX | Initial comp | 
| 1 | 587641616 | TXXX | Initial comp | 

## References
* []()
* []()
* []()
* []()
* []()
* []()
* []()
* []()
* []()
* []()
* []()
* []()
* []()
* []()
* []()
* []()
* []()
* []()

