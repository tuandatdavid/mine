# vim: set ft=make :

spicetify:
    #!/usr/bin/bash
    cd /tmp
    git clone https://github.com/boudywho/easy-spicetify-linux.git
    cd /tmp/easy-spicetify-arch
    chmod +x spicetify-universal.sh
    ./spicetify-universal.sh
