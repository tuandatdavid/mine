# vim: set ft=make :

spicetify:
    #!/usr/bin/bash
    cd /tmp
    git clone https://github.com/boudywho/easy-spicetify-linux.git
    cd easy-spicetify-arch
    chmod +x universal-spicetify.sh
    ./universal-spicetify.sh
