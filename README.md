#The One you Bury
---

The one you bury is a script for an automated setup of a Tor Hidden Service on Raspbian (may also work on other Debian based Distrobutions but support is not garunteed). Run as root. 

## .tobury/
Inside the dot folder there are two folders, one which contains scripts for setting up various Web Services and hardening the Pi (/scripts) and the other (/secrets) which can be used for storing individual secrets for the services if you want to keep a copy of this repo as a backup for your whole service

## Recommendations:
You can run multiple services on a single Pi, if you do that, only run 2-3 and only if its a Pi 3, you don't want to be spending your time maintaining the serivce all the time nor do you want it to crash and not be available. 

Always keep backups, if you don't then be happy with losing data, Remember: one is none, two is one. (With regards to Guns and backups). 

We recommend running one serivce on a Pi especially if the Pi is not a Pi 3.

# WARNING: Pi's are pretty physically insecure and cannot boot encrypted partitions (and they would suck if they could) this is why we suggest keeping the Pi in a place you can keep physically secure, in the future we may think of a work around that is suitable to fix this issue (which could leak data and provide an adversary with the keys to immitate the services) in the meantime don't use this if you don't know what you're doing or don't think you can keep the Pi in a reasonably secure location 

