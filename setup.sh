#!/usr/bin/env bash
# 2017-02-21 15:33:03

INTERACTIVE=True

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

if [ "$INTERACTIVE" == "True" ]; then
    while true; do
    FUN=$(whiptail --title "This One you Bury" --menu "Options" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT --cancel-button Finish --ok-button Select \
    "1 Upgrade" "Updates all software on the Pi using APT" \
    3>&1 1>&2 2>&3)
        RET=$?
        if [ $RET -eq 1 ]; then
            exit 0
        elif [ $RET -eq 0 ]; then
            case "$FUN" in
                1\ *) do_upgrade;;
                *) whiptail --msgbox "Programming error: no option for that!" 20 60 1;;
            esac || whiptail --msgbox "There was an error running option $FUN" 20 60 1
        else 
            exit 1
        fi
    done
fi
