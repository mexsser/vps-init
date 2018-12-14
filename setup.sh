#!/bin/bash
set -e

# ======= Your Data =========
# host info
HOST_NAME="DOBOX"
WELCOME_MESSAGE='./welcome_message'
# user info
USERNAME="inje"
PASSWARD='k?j0r_g^39Ge2'
AS_SUDO_USER=true
# ssh info
PUBLIC_SSH_KEY='ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAhi54eXlkwelbgsdOzKdaNkZZIvr1sFa0THwVVjVhx4d0UIi7E5D1R9ynIxwkkVHpdmOil7OEEB8hkR/LZcxD1s2XSCHJJIBL8DEllJYtR73ng3PU1tMdl+xj+wLa9GY+pg3ZuoU//uIizF5BW02XSFtsa60qbJ5dsJ3AcgCc5xrL0C5JZIqCAZauI0R/y+2NEEM43H8ifClohMDOJXYM0St1DizQgBA5VvtRLRyLXIpZjpMnvtks9iRrTRL5fW4jwVEroYkCNONYNwhyLIfRT6X+TBCQWxC1WkDMLyblb6+RnpXLQdsqGEDJUQvoHmybacw/2ScJyiQ04IxFYCdoHQ== rsa-key-20170824'
SSH_PORT="2020"
# ============================

# =========== action =========
# update system
apt-get update
apt-get upgrade -y
source ./functions.sh
Menu
