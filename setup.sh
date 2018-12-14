#!/bin/bash
set -e
current_dir=$(getCurrentDir)
source $current_dir/functions.sh
# ======= Your Data =========
# host info
HOST_NAME="DOVPS"
# user info
USERNAME="test"
PASSWARD='k?j0r_g^39Ge2'
AS_SUDO_USER=false
# ssh info
SSH_PORT="2020"
# ============================

WELCOME_MESSAGE="${current_dir}/welcome_message"
PUBLIC_SSH_KEY="${current_dir}/publickey"

# =========== action =========
# update system
apt-get update
apt-get upgrade -y

Menu
