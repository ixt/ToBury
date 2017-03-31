#The One you Bury
---

The one you bury is a script for an automated setup of a Tor Hidden Service on Raspbian (may also work on other Debian based Distrobutions but support is not garunteed). Run as root. 

## .tobury/
Inside the dot folder there are two folders, one which contains scripts for setting up various Web Services and hardening the Pi (/scripts) and the other (/secrets) which can be used for storing individual secrets for the services if you want to keep a copy of this repo as a backup for your whole service

## Recommendations:
You can run multiple services on a single Pi, if you do that, only run 2-3 and only if its a Pi 3, you don't want to be spending your time maintaining the serivce all the time nor do you want it to crash and not be available. 

Always keep backups, if you don't then be happy with losing data, Remember: one is none, two is one. (With regards to Guns and backups). 
We recommend running one serivce on a Pi especially if the Pi is not a Pi 3.

When the base service is installed (Tor, NGINX and a SSH Service) the script will generate a keypair for the main user and then share it as an archive on the webservice until it is logged in for the first time with that key then the private key is deleted from the Pi, so make sure to keep care of the keypair and make a backup. Instructions for TailsOS are provided.  

## TODO:
    + Make script for setup on Tails (or as cross-linux as possible)
        + Must not be destructive, this is to protect when being used with multiple ToBury instances
    + (?) Add OnionShare as main provider for serving first files
    + (?) Disk encryption or container for filesystem
    + Add Gobby server 
    + (?) Add a Futaba style message board
    + Add perminent file storage / sharing (Read-Only)
        + Perhaps webserved or sshfs based?? (Would require a special user) 
