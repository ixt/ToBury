#!/usr/bin/env bash
# 2017-02-21 15:33:03

INTERACTIVE=True

enable_ssh(){
    if [ -e /var/log/regen_ssh_keys.log ] && ! grep -q "^finished" /var/log/regen_ssh_keys.log; then
        whiptail --msgbox "Initial ssh key generation still running. Please wait and try again." 20 60 2
        return 1
    fi
    update-rc.d ssh enable
    invoke-rc.d ssh start
    systemctl enable ssh.service
    systemctl start ssh.service
}

do_upgrade(){
    sudo apt update && sudo apt upgrade --yes
}

# Function taken from https://github.com/RPi-Distro/raspi-config why rewrite if there is a one that works out there?
calc_wt_size() {
    # NOTE: it's tempting to redirect stderr to /dev/null, so surpress error 
    # output from tput. However in this case, tput detects neither stdout or 
    # stderr is a tty and so only gives default 80, 24 values
    WT_HEIGHT=17
    WT_WIDTH=$(tput cols)

    if [ -z "$WT_WIDTH" ] || [ "$WT_WIDTH" -lt 60 ]; then
        WT_WIDTH=80
    fi
    if [ "$WT_WIDTH" -gt 178 ]; then
        WT_WIDTH=120
    fi
    WT_MENU_HEIGHT=$(($WT_HEIGHT-7))
}

do_about() {
    whiptail --msgbox "\
    To Bury is a command-line utility to use setup Tor Hidden Services,
    To Bury stands for The One (you) Bury.
        " 20 70 1
}

install_base() {
    #RET=$(whiptail --yesno 
    # TODO: Add better TUI to this.

    sudo apt update 
    sudo apt install tor torsocks --yes
    echo "HiddenServiceDir /var/lib/tor/toBury" >> /etc/tor/torrc
    echo "HiddenServicePort 22 localhost:22" >> /etc/tor/torrc
    echo "HiddenServicePort 80 localhost:80" >> /etc/tor/torrc
    sudo service tor reload
    sleep 30
    while [ ! -e "/var/lib/tor/toBury/hostname"]; do
        sleep 1
    done
    HOSTNAME=$(cat /var/lib/tor/toBury/hostname)
    sudo -u pi mkdir ~pi/.ssh -p

    # We use a ed25519 key because its better than rsa, less weak to 
    # classical computing attacks and smaller keysizes.

    sudo -u pi ssh-keygen -t ed25519 -N "" -f "$HOSTNAME.key"
    cat $HOSTNAME.key.pub >> ~pi/.ssh/authorized_keys
    ### TODO: Add a script for easy setup of keys and hosts.
    
    # This will delete the keys when you connect the first time
    echo "sudo rm ~pi/$HOSTNAME*; sudo shred /var/www/keys.tar.gz; sudo rm /var/www/keys.tar.gz; sudo rm ~pi/.ssh/rc" > ~pi/.ssh/rc
    
    ### TODO: Add in the success/setup page. 

    # This is for hosting a website that holds the keys. 
    # We could switch to Onionshare which has a lot of features built in
    # for destroying files that are temporary (and is pretty)

    sudo torsocks apt install nginx --yes
    rm /var/www/* -rf
    tar cvfz /var/www/keys.tar.gz $HOSTNAME* 
    chmod 644 /var/www/keys.tar.gz
    sudo cp ~pi/.tobury/config/nginx.conf /etc/nginx/sites-enabled/default
    service nginx reload
    
    echo "sshd: localhost" >> /etc/hosts.allow
    echo "ALL: ALL" >> /etc/hosts.deny
    sudo cp ~pi/.tobury/config/ssh.conf /etc/ssh/sshd_config
    enable_ssh
    whiptail --msgbox "\
        go to $HOSTNAME and download keys.tar.gz on your laptop \
        \"cd ~amnesia/.ssh\" \
        \"tar xvf ~/Tor\ Browser/keys.tar.gz\" \
        use \"ssh pi@$HOSTNAME -i $HOSTNAME.key\" to connect \
        after first connection you wont be able to redownload the keys so back them up \
    " $WT_HEIGHT $WT_WIDTH
    
    # TODO: This is an unacceptable UX currently and needs to be resolved. 
    # todo's mentioned before this are suggestions for fixes to this issue
    # but there are also issues with that too. For instance is onion share 
    # even in support of ARM / Pi, is it in the repos? how large is it?
    # As it fails closed, I would assume that the attack vector is probably 
    # Even less than using NGINX and the usability is by far better. 
}

calc_wt_size

if [ "$INTERACTIVE" == "True" ]; then
    while true; do
    FUN=$(whiptail --title "This One you Bury" --menu "Options" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT --cancel-button Finish --ok-button Select \
    "1 Upgrade" "Updates all software on the Pi using APT" \
    "2 Base" "Installs Tor, Enables SSH and generates keys for access (and URLs)" \
    3>&1 1>&2 2>&3)
        RET=$?
        if [ $RET -eq 1 ]; then
            exit 0
        elif [ $RET -eq 0 ]; then
            case "$FUN" in
                1\ *) do_upgrade;;
                2\ *) install_base;;
                *) whiptail --msgbox "Programming error: no option for that!" 20 60 1;;
            esac || whiptail --msgbox "There was an error running option $FUN" 20 60 1
        else 
            exit 1
        fi
    done
fi
