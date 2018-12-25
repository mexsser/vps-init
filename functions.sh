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
	echo "   7) Mount Google Drive"
	echo "   8) Exit"
	until [[ "$MENU_OPTION" =~ ^[1-8]$ ]]; do
		read -rp "Select an option [1-8]: " MENU_OPTION
	done

	case $MENU_OPTION in
		1) addUser ;;
		2) installOpenVPN ;;
		3) installIPsec ;;
		4) installDocker ;;
		5) installCloudTorrent ;;
		6) installBaiduPCsGo ;;
		7) installRclone ;;
		8) exit 0
	esac
}

function addUser() {
	 clear
	 echo "Did you set your root password?[1/2]"
	 select op in "Yes" "NO"; do
		 case $op in
			 Yes ) break;;
			 NO ) passwd root;break;;
		 esac
	 done
   # change host name and welcome message
   echo "$HOST_NAME" > /etc/hostname
   cat $WELCOME_MESSAGE > /etc/motd

   # check if user already exists
	 apt-get remove --purge unscd
	 if grep -c "^$USERNAME:" /etc/passwd > /dev/null 2>&1; then
		 echo "User $USERNAME already exists. Delete $USERNAME or exit?[1/2]"
		 select op in "Delete" "Exit"; do
	       case $op in
	           Delete ) userdel -r $USERNAME;
						          sed -i "/AllowUsers $USERNAME/d" /etc/ssh/sshd_config;
											echo "Ok, User $USERNAME is deleted, will continue..."; break;;
	           Exit ) exit;;
	       esac
	   done
	 fi
	 # add user
	 apt-get install whois
   /usr/sbin/useradd -m -G users -s /bin/bash $USERNAME
   PASSWARD_EPT=$(mkpasswd $PASSWARD)
   usermod --password $PASSWARD_EPT $USERNAME
   if [ "$AS_SUDO_USER" = true ]; then
     usermod -aG sudo $USERNAME
   fi
   # add ssh key
   mkdir /home/$USERNAME/.ssh
   chmod 700 /home/$USERNAME/.ssh
   touch /home/$USERNAME/.ssh/authorized_keys
   cat $PUBLIC_SSH_KEY >> /home/$USERNAME/.ssh/authorized_keys
	 chmod 600 /home/$USERNAME/.ssh/authorized_keys
   chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh
   # change ssh settings
   sed -re 's@^(\#?)(PasswordAuthentication)([[:space:]]+)yes@\2\3no@' -i."$(echo 'old')" /etc/ssh/sshd_config
   sed -re 's@^(\#?)(PubkeyAuthentication)([[:space:]]+)(.*)@PubkeyAuthentication yes@' -i /etc/ssh/sshd_config
   sed -re 's@^(\#?)(RSAAuthentication)([[:space:]]+)(.*)@RSAAuthentication yes@' -i /etc/ssh/sshd_config
   sed -re 's@^(\#?)(AuthorizedKeysFile)([[:space:]]+)(.*)@AuthorizedKeysFile  %h/.ssh/authorized_keys@' -i /etc/ssh/sshd_config
   sed -re "s@^(\#?)(Port)([[:space:]]+)(.*)@Port $SSH_PORT@" -i /etc/ssh/sshd_config
   sed -re 's@^(\#?)(LoginGraceTime)([[:space:]]+)(.*)@LoginGraceTime 10@' -i /etc/ssh/sshd_config
   sed -re 's@^(\#?)(MaxAuthTries)([[:space:]]+)(.*)@MaxAuthTries 2@' -i /etc/ssh/sshd_config
   sed -re 's@^(\#?)(MaxSessions)([[:space:]]+)(.*)@MaxSessions 3@' -i /etc/ssh/sshd_config
	 echo "" >> /etc/ssh/sshd_config
	 echo "AllowUsers $USERNAME" >> /etc/ssh/sshd_config
	 #echo "RSAAuthentication yes" >> /etc/ssh/sshd_config
   service sshd restart
   # ask if the new user can successfully login using public key
   echo "Can you login ssh with the newly created user and its public key? [1/2]"
   select op in "Yes" "No"; do
       case $op in
           Yes ) echo "Ok, continue..."; break;;
           No ) echo "The created user will be deleted. Please modify this script and run it again.";
                userdel -r $USERNAME;
                sed -i "/AllowUsers $USERNAME/d" /etc/ssh/sshd_config;
                exit;;
       esac
   done
   # disable root login
   sed -re 's@^(\#?)(PermitRootLogin)([[:space:]]+)(.*)@PermitRootLogin no@' -i /etc/ssh/sshd_config
   # keep ssh sesion alive
   sed -re 's@^(\#?)(ClientAliveInterval)([[:space:]]+)(.*)@ClientAliveInterval 300@' -i /etc/ssh/sshd_config
	 echo "ClientAliveCountMax 2" >> /etc/ssh/sshd_config

   service sshd restart
   #install htop and slurm
   apt-get install htop slurm
   # add alias
   echo "alias ll='ls -lah'
	 alias disk='df -h'
	 alias clc='clear'
	 alias netuse='slurm -i eth0'
	 PS1='\[\e[1;91m\][\u@\h \w]\$\[\e[0m\]'" >> /home/$USERNAME/.bashrc
	 echo "alias ll='ls -lah'" >> /root/.bashrc
	 source /root/.bashrc
   # set up firewall
   apt-get install ufw
   echo "Disable IPv6 through Firewall? [1/2]"
   select yn in "Yes" "No"; do
       case $yn in
           Yes ) sed -re 's@^(\#?)(IPV6=yes)@IPV6=no@' -i /etc/default/ufw; break;;
           No ) break;;
       esac
   done
   ufw allow $SSH_PORT
   ufw --force enable
}

function installOpenVPN() {
	clear
	echo "########## OpenVPN Installation ##########"
	echo "Please specify the port you want for OpenVPN, and later you will be asked again"
	read -p "Port number: " port
	ufw allow $port
	apt-get install curl
	curl -O https://raw.githubusercontent.com/Angristan/openvpn-install/master/openvpn-install.sh
	chmod +x openvpn-install.sh
	./openvpn-install.sh && \
	rm ./openvpn-install.sh
}

function installIPsec() {
	clear
	echo "########## IPsec/L2TP Installation ##########"
	ufw allow 500
	ufw allow 1701
	ufw allow 4500
	wget https://git.io/vpnsetup -O vpnsetup.sh && sh vpnsetup.sh && \
	rm vpnsetup.sh
}

function installDocker() {
	clear
	echo "########## Docker Installation ##########"
	#uninstall old versions
	# apt-get remove docker docker-engine docker.io
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
	if ! grep -q "^docker:" /etc/group > /dev/null 2>&1;
  	then groupadd docker
	fi
	usermod -aG docker $USERNAME
}

function installCloudTorrent() {
	clear
	echo "########## Cloud-Torrent Installation ##########"
	read -p "Please enter web auth user name: " username
	read -p "Please enter web auth user password: " password
	read -p "Please enter web port: " port
	mkdir /home/$USERNAME/download
	chown -R $USERNAME:users /home/$USERNAME/download
	docker run --user $(id -u $USERNAME):$(id -g $USERNAME) -d -p $port:$port \
	-v /home/$USERNAME/download:/downloads jpillora/cloud-torrent --port $port -a "$username:$password"
	#ufw allow 50007 # incoming port
}

function installBaiduPCsGo() {
	clear
	echo "########## BaiduPCS-Go Installation ##########"
	apt-get install p7zip-full
	mkdir /home/$USERNAME/baidupcs
	cd /home/$USERNAME/baidupcs
	wget https://github.com/iikira/BaiduPCS-Go/releases/download/v3.5.6/BaiduPCS-Go-v3.5.6-linux-amd64.zip
	7z e *.zip
	rm -r ./BaiduPCS-Go-v*
	chown -R $USERNAME:users /home/$USERNAME/baidupcs
	./BaiduPCS-Go config set -appid 265486
	./BaiduPCS-Go config set -enable_https=true
	./BaiduPCS-Go config set -cache_size 100000 -max_parallel 300 -savedir /home/$USERNAME/download
}

#function installWebhook() {
   # will add this later
#}

function installRclone() {
	apt-get install -y nload fuse p7zip-full
	KernelBit="$(getconf LONG_BIT)"
	[[ "$KernelBit" == '32' ]] && KernelBitVer='i386'
	[[ "$KernelBit" == '64' ]] && KernelBitVer='amd64'
	[[ -z "$KernelBitVer" ]] && exit 1
	cd /tmp
	wget -O '/tmp/rclone.zip' "https://downloads.rclone.org/rclone-current-linux-$KernelBitVer.zip"
	7z x /tmp/rclone.zip
	cd rclone-*
	cp -raf rclone /usr/bin/
	chown root:root /usr/bin/rclone
	chmod 755 /usr/bin/rclone
	mkdir -p /usr/local/share/man/man1
	cp -raf rclone.1 /usr/local/share/man/man1/
	mandb
	rm -rf /tmp/rclon*
	clear
	rclone config
	su -c "mkdir -p /home/$USERNAME/GDrive" $USERNAME
	read -p "Please re-enter the remote drive name: " drivename
	read -p "Please enter the remote folder name in your google drive: " foldername
	mountrc="rclone mount $drivename:$foldername /home/$USERNAME/GDrive --copy-links --no-gzip-encoding --no-check-certificate --allow-other --allow-non-empty --umask 000 &"
	eval $mountrc
	crontab -l | { cat; echo "@reboot $mountrc"; } | crontab -
	echo "### Now Google Drive is mounted at /home/$USERNAME/GDrive ###"
	echo ""
	echo "--- Disk Info ---"
	df -h
}
