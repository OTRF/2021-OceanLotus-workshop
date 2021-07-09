#!/bin/sh
. /etc/rc.common
dscl . create /Users/{{ username }}
dscl . create /Users/{{ username }} RealName '{{ fullname | replace("'", "'\\''") }}'
dscl . create /Users/{{ username }} hint '{{ password | replace("'", "'\\''") | truncate(4, True) }}'
if [ -n "{{ image }}" ]; then
    dscl . create /Users/{{ username }} picture "/Library/User Pictures/Ansible/{{ image }}"
fi
dscl . passwd /Users/{{ username }} '{{ password | replace("'", "'\\''") }}'
dscl . create /Users/{{ username }} UniqueID {{ uid.stdout }}
dscl . create /Users/{{ username }} PrimaryGroupID 20
dscl . create /Users/{{ username }} UserShell /bin/bash
dscl . create /Users/{{ username }} NFSHomeDirectory /Users/{{ username }}
cp -R /System/Library/User\ Template/English.lproj /Users/{{ username }}
chown -R {{ username }}:staff /Users/{{ username }}

dscl . append /Groups/admin GroupMembership {{ username }}