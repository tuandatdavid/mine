# vim: set ft=make :

spicetify:
    #!/usr/bin/bash
    cd /var/tmp
    git clone https://github.com/boudywho/easy-spicetify-arch.git
    cd easy-spicetify-arch
    chmod +x spicetify.sh
    ./spicetify.sh
