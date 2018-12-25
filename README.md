# VPS Post-Install Script
**Tested Platform**
- Debian 8 or higher from Digital Ocean

**Usage**
- First download this project and make all .sh files executable:
```bash
git clone https://github.com/mexsser/vps-init.git
cd vps-init
chmod +x ./*.sh
```
- Add your public key to ./publickey
- Modify ./setup.sh to specify the new user name and password
- Then run as __root__
```bash
./setup.sh
```

**Features available**
1. Add a non-root user(optional:add to sudo group) and set it as the only ssh login user
2. Setup [OpenVPN server](https://github.com/angristan/openvpn-install)
3. Setup [IPsec/L2TP server](https://github.com/hwdsl2/setup-ipsec-vpn)
4. Install [Docker CE](https://docs.docker.com/install/linux/docker-ce/debian/)
5. Install [Cloud-Torrent](https://github.com/jpillora/cloud-torrent)
6. Install [BaiduPCS-Go](https://github.com/iikira/BaiduPCS-Go)
7. Install [rclone](https://rclone.org/) to mount Googel Drive as a local disk


**To Do**
1. Install [webhook](https://github.com/adnanh/webhook) to play with [IFTTT](https://ifttt.com/)
2. Setup Nginx server and cert-bot
3. Setup a [reverse server](https://jixun.moe/post/ymusic-hosts-fix/) to use Netease Cloud Music out of China

**Inspired by**
1. [jasonheecs](https://github.com/jasonheecs/ubuntu-server-setup)
2. [slider23](https://gist.github.com/slider23/ecda99d7fe3b51e5b34d21f9312bb1df)
