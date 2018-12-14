#!/bin/bash
function Menu () {
	clear
	echo "Welcome to VPS-Init!"
	echo "What do you want to do?"
	echo "   1) Add a new user"
	echo "   2) Setup OpenVPN"
	echo "   3) Setup IPsec/L2TP"
	echo "   4) Install Docker"
	echo "   5) Install Cloud-Torrent"
	echo "   6) Install BaiduPCS-Go"
	echo "   7) Exit"
	until [[ "$MENU_OPTION" =~ ^[1-7]$ ]]; do
		read -rp "Select an option [1-7]: " MENU_OPTION
	done

	case $MENU_OPTION in
		1) addUser ;;
		2) installOpenVPN ;;
		3) installIPsec ;;
		4) installDocker ;;
		5) installCloudTorrent ;;
		6) installBaiduPCsGo ;;
		7) exit 0
	esac
}

function addUser(){
   # change host name and welcome message
   echo "$HOST_NAME" > /etc/hostname
   cat $WELCOME_MESSAGE > /etc/motd

   # add user
	 apt-get install whois
   /usr/sbin/useradd -m -G users -s /bin/bash $USERNAME
   PASSWARD_EPT=$(mkpasswd $PASSWARD)
   usermod --password $PASSWARD_EPT $USERNAME
   if [$AS_SUDO_USER = true]; then
     usermod -aG sudo $USERNAME
   fi
   # add ssh key
   mkdir /home/$USERNAME/.ssh
   chmod 700 /home/$USERNAME/.ssh
   touch /home/$USERNAME/.ssh/authorized_keys
   echo "$PUBLIC_SSH_KEY" >> /home/$USERNAME/.ssh/authorized_keys

   # change ssh settings
   sed -re 's/^(\#?)(PasswordAuthentication)([[:space:]]+)yes/\2\3no/' -i."$(echo 'old')" /etc/ssh/sshd_config
   sed -re 's/^(\#?)(Port)([[:space:]]+)(.*)/Port $SSH_PORT/' -i /etc/ssh/sshd_config
   sed -re 's/^(\#?)(LoginGraceTime)([[:space:]]+)(.*)/LoginGraceTime 10/' -i /etc/ssh/sshd_config
   sed -re 's/^(\#?)(MaxAuthTries)([[:space:]]+)(.*)/MaxAuthTries 2/' -i /etc/ssh/sshd_config
   sed -re 's/^(\#?)(MaxSessions)([[:space:]]+)(.*)/MaxSessions 2/' -i /etc/ssh/sshd_config
   echo "AllowUsers $USERNAME" >> /etc/ssh/sshd_config
   service ssh restart
   # ask if the new user can successfully login using public key
   echo "Can you login ssh with the newly created user and its public key? [1/2]"
   select yn in "Yes" "No"; do
       case $yn in
           Yes ) echo "Ok, continue..."; break;;
           No ) echo "The created user will be deleted. Please modify this script and run it again.";
                userdel -r $USERNAME;
                sed -i "/AllowUsers $USERNAME/d" /etc/ssh/sshd_config;
                exit;;
       esac
   done
   # disable root login
   sed -re 's/^(\#?)(PermitRootLogin)([[:space:]]+)(.*)/PermitRootLogin no/' -i /etc/ssh/sshd_config
   # keep ssh session alive
   cat "ClientAliveInterval 300
	 ClientAliveCountMax 2" >> /etc/ssh/sshd_config

   service ssh restart
   #install htop and slurm
   apt-get install htop slurm
   # add alias
   cat "alias ll='ls -lah'
	 alias disk='df -h'
	 alias clc='clear'
	 alias netuse='slurm -i eth0'
	 PS1='\[\e[1;91m\][\u@\h \w]\$\[\e[0m\]'" >> /home/$USERNAME/.bashrc

   # set up firewall
   apt-get install ufw
   echo "Disable IPv6 through Firewall? [1/2]"
   select yn in "Yes" "No"; do
       case $yn in
           Yes ) sed -re 's/^(\#?)(IPV6=yes)/IPV6=no/' -i /etc/default/ufw; break;;
           No ) break;;
       esac
   done
   ufw allow $SSH_PORT
   ufw --force enable
}

function installOpenVPN(){
   echo "########## OpenVPN Installation ##########"
   echo "Please specify the port you want for OpenVPN, and later you will be asked again"
   read -p "Port number: " port
   ufw allow $port
   curl -O https://raw.githubusercontent.com/Angristan/openvpn-install/master/openvpn-install.sh
   chmod +x openvpn-install.sh
   ./openvpn-install.sh
}

function installIPsec(){
   ufw allow 500
   ufw allow 1701
   ufw allow 4500
   wget https://git.io/vpnsetup -O vpnsetup.sh && sh vpnsetup.sh
}

function installDocker(){
   echo "########## Docker Installation ##########"
   # uninstall old versions
   apt-get remove docker docker-engine docker.io
   apt-get install \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg2 \
        software-properties-common
   curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
   add-apt-repository \
      "deb [arch=amd64] https://download.docker.com/linux/debian \
      $(lsb_release -cs) \
      stable"
   apt-get update
   apt-get install docker-ce
   # run docker as non-root
   groupadd docker
   usermod -aG docker $USERNAME
}

function installCloudTorrent(){
   echo "########## Cloud-Torrent Installation ##########"
   local username=${1}
   local password=${2}
   local port=${3}
   mkdir /home/$USERNAME/download
   chown -R $USERNAME:users /home/$USERNAME/download
   docker run --user $(id -u $USERNAME):$(id -g $USERNAME) -d -p $port:$port \
   -v /home/$USERNAME/download:/downloads jpillora/cloud-torrent --port $port -a "$username:$password"
   ufw allow 21 # use port 21 for
}

function installBaiduPCsGo(){
   apt-get install p7zip-full
   mkdir /home/$USERNAME/baidupcs
   chown -R $USERNAME:users /home/$USERNAME/baidupcs
   cd /home/$USERNAME/baidupcs
   wget https://github.com/iikira/BaiduPCS-Go/releases/download/v3.5.6/BaiduPCS-Go-v3.5.6-linux-amd64.zip
   7z e *.zip
   rm -r ./BaiduPCS-Go-v*
   ./BaiduPCS-Go config set -appid 265486
   ./BaiduPCS-Go config set -enable_https=true
   ./BaiduPCS-Go config set -cache_size 100000 -max_parallel 300 -savedir /home/$USERNAME/download
}

#function installWebhook(){
   # will add this later
#}
