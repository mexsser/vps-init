#!/bin/bash
set -e

# ======= Your Data =========
# host info
HOST_NAME="DOVPS"
# user info
USERNAME="test"
PASSWARD='k?j0r_g^39Ge2'
AS_SUDO_USER=false
# ssh info
SSH_PORT="2222"
# ============================

function getCurrentDir() {
    local current_dir="${BASH_SOURCE%/*}"
    if [[ ! -d "${current_dir}" ]]; then current_dir="$PWD"; fi
    echo "${current_dir}"
}

current_dir=$(getCurrentDir)
WELCOME_MESSAGE="${current_dir}/welcome_message"
PUBLIC_SSH_KEY="${current_dir}/publickey"
source $current_dir/functions.sh

# =========== action =========
# update system
apt-get update
apt-get upgrade -y

Menu
