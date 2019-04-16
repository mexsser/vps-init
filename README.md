# VPS Post-Install Script
**Tested Platform**
- Debian 8 or higher from Digital Ocean

**Attention: Before Execution**
- First download this project and make all .sh files executable:
```bash
git clone https://github.com/mexsser/vps-init.git
cd vps-init
chmod +x ./*.sh
```
- __Add your public key to ./publickey !!!__
- __Modify ./setup.sh to specify the new user name and password !!!__

**Execution**
- Run as __root__
```bash
./setup.sh
```

**Features available**
1. Add a non-root user(optional:add to sudo group) and set it as the only ssh login user
2. Add swap space to your VPS
3. Setup [OpenVPN server](https://github.com/angristan/openvpn-install)
4. Setup [IPsec/L2TP server](https://github.com/hwdsl2/setup-ipsec-vpn)
5. Install [Docker CE](https://docs.docker.com/install/linux/docker-ce/debian/)
6. Install [Cloud-Torrent](https://github.com/jpillora/cloud-torrent)
7. Install [BaiduPCS-Go](https://github.com/iikira/BaiduPCS-Go)
8. Install [rclone](https://rclone.org/) to mount Googel Drive as a local disk
9. Setup [Node.js reverse proxy](https://github.com/nondanee/UnblockNeteaseMusic) to use Netease Cloud Music out of China


**To Do**
1. Install [webhook](https://github.com/adnanh/webhook) to play with [IFTTT](https://ifttt.com/)
2. Setup Nginx server and cert-bot
3. Setup [v2ray server](https://github.com/v2ray/v2ray-core)
4. Setup a [mirror of google](https://lius.me/blog/2018/03/28/搭建Google镜像/) with ssl and basic authentication


**Inspired by**
1. [jasonheecs](https://github.com/jasonheecs/ubuntu-server-setup)
2. [slider23](https://gist.github.com/slider23/ecda99d7fe3b51e5b34d21f9312bb1df)
