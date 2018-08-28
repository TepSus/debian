#!/bin/bash
# ***********************************************
# Program: AUTOSCRIPT INSTALL DEBIAN 7 [32/64Bit]
# Developer: Kaizen Apeach
# ***********************************************

myip=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0' | head -n1`;
myint=`ifconfig | grep -B1 "inet addr:$myip" | head -n1 | awk '{print $1}'`;

red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
echo "Connecting to KaizenApeach.net..."
sleep 0.5
echo "Checking Permision..."
sleep 0.5
echo -e "${green}Permission Accepted...${NC}"
sleep 1
	       
flag=0

clear

#Requirement
if [ ! -e /usr/bin/curl ]; then
    apt-get -y update && apt-get -y upgrade
	apt-get -y install curl
fi

#Requirement
if [ ! -e /usr/bin/curl ]; then
    apt-get -y update && apt-get -y upgrade
	apt-get -y install curl
fi

# initialisasi var
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;
MYIP=$(curl -4 icanhazip.com)
if [ $MYIP = "" ]; then
   MYIP=`ifconfig | grep 'inet addr:' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d: -f2 | awk '{ print $1}' | head -1`;
fi
MYIP2="s/xxxxxxxxx/$MYIP/g";


# go to root
cd

# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

#Add DNS Server ipv4
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf
sed -i '$ i\echo "nameserver 8.8.8.8" > /etc/resolv.conf' /etc/rc.local
sed -i '$ i\echo "nameserver 8.8.4.4" >> /etc/resolv.conf' /etc/rc.local

# install wget and curl
apt-get update;apt-get -y install wget curl;

# set time GMT +8
ln -fs /usr/share/zoneinfo/Asia/Kuala_Lumpur /etc/localtime

# set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
service ssh restart

# set repo
cat > /etc/apt/sources.list <<END2
deb http://cdn.debian.net/debian wheezy main contrib non-free
deb http://security.debian.org/ wheezy/updates main contrib non-free
deb http://packages.dotdeb.org wheezy all
END2
wget "http://www.dotdeb.org/dotdeb.gpg"
cat dotdeb.gpg | apt-key add -;rm dotdeb.gpg

# remove unused
apt-get -y --purge remove samba*;
apt-get -y --purge remove apache2*;
apt-get -y --purge remove sendmail*;
apt-get -y --purge remove bind9*;
apt-get -y purge sendmail*
apt-get -y remove sendmail*

# update
apt-get update; apt-get -y upgrade;

# install webserver
apt-get -y install nginx php5-fpm php5-cli

# install essential package
echo "mrtg mrtg/conf_mods boolean true" | debconf-set-selections
apt-get -y install bmon iftop htop nmap axel nano iptables traceroute sysv-rc-conf dnsutils bc nethogs openvpn vnstat less screen psmisc apt-file whois ptunnel ngrep mtr git zsh mrtg snmp snmpd snmp-mibs-downloader unzip unrar rsyslog debsums rkhunter
apt-get -y install build-essential

# disable exim
service exim4 stop
sysv-rc-conf exim4 off

# update apt-file
apt-file update

# setting vnstat
vnstat -u -i eth0
service vnstat restart

#Install Figlet
apt-get install figlet
echo "clear" >> .bashrc
echo 'echo -e ""' >> .bashr
echo 'echo -e ""' >> .bashrc
echo 'figlet -k "            Apeach"' >> .bashrc
echo 'echo -e ""' >> .bashrc
echo 'echo -e "     ========================================================="' >> .bashrc
echo 'echo -e "     *        Script By Kaizen Apeach | Tester Hacker        *"' >> .bashrc
echo 'echo -e "     ========================================================="' >> .bashrc
echo 'echo -e "     *                     Contact Me                        *"' >> .bashrc
echo 'echo -e "     *                Facebook: Al-hafiez Apeach             *"' >> .bashrc
echo 'echo -e "     *                Whatsapp: +60178958795                 *"' >> .bashrc
echo 'echo -e "     *                Telegram: @KaizenA                     *"' >> .bashrc
echo 'echo -e "     ========================================================="' >> .bashrc
echo 'echo -e "     *       Taip \033[1;32mmenu\033[0m untuk menampilkan senarai menu        *"' >> .bashrc
echo 'echo -e "     ========================================================="' >> .bashrc
echo 'echo -e ""' >> .bashrc

# install webserver
apt-get -y install nginx php5-fpm php5-cli
cd
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/0613561761za/nginx.conf"
mkdir -p /home/vps/public_html
echo "<pre>Setup by Chayanin Laoha[A]</pre>" > /home/vps/public_html/index.html
echo "<?php phpinfo(); ?>" > /home/vps/public_html/info.php
wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/0613561761za/vps.conf"
sed -i 's/listen = \/var\/run\/php5-fpm.sock/listen = 127.0.0.1:9000/g' /etc/php5/fpm/pool.d/www.conf
service php5-fpm restart
service nginx restart

#install OpenVPN
apt-get -y install openvpn iptables openssl
cp -R /usr/share/doc/openvpn/examples/easy-rsa/ /etc/openvpn
# easy-rsa
if [[ ! -d /etc/openvpn/easy-rsa/2.0/ ]]; then
	wget --no-check-certificate -O ~/easy-rsa.tar.gz https://github.com/0613561761za/sshpanel/raw/master/easy-rsa-2.2.0_master.tar.gz
    tar xzf ~/easy-rsa.tar.gz -C ~/
    mkdir -p /etc/openvpn/easy-rsa/2.0/
    cp ~/easy-rsa-2.2.0_master/easy-rsa/2.0/* /etc/openvpn/easy-rsa/2.0/
    rm -rf ~/easy-rsa-2.2.2
    rm -rf ~/easy-rsa.tar.gz
fi
cd /etc/openvpn/easy-rsa/2.0/
# benarkan errornya
cp -u -p openssl-1.0.0.cnf openssl.cnf
# ganti bits
sed -i 's|export KEY_SIZE=1024|export KEY_SIZE=2048|' /etc/openvpn/easy-rsa/2.0/vars
sed -i 's|export KEY_COUNTRY="US"|export KEY_COUNTRY="MY"|' /etc/openvpn/easy-rsa/2.0/vars
sed -i 's|export KEY_PROVINCE="CA"|export KEY_PROVINCE="M"|' /etc/openvpn/easy-rsa/2.0/vars
sed -i 's|export KEY_CITY="SanFrancisco"|export KEY_CITY="Krungtep"|' /etc/openvpn/easy-rsa/2.0/vars
sed -i 's|export KEY_ORG="Fort-Funston"|export KEY_ORG="Chayanin"|' /etc/openvpn/easy-rsa/2.0/vars
sed -i 's|export KEY_EMAIL="me@myhost.mydomain"|export KEY_EMAIL="0646363362za@gmail.com"|' /etc/openvpn/easy-rsa/2.0/vars
sed -i 's|export KEY_EMAIL=mail@host.domain|export KEY_EMAIL=0646363362za@gmail.com|' /etc/openvpn/easy-rsa/2.0/vars
sed -i 's|export KEY_CN=changeme|export KEY_CN="Chayanin"|' /etc/openvpn/easy-rsa/2.0/vars
sed -i 's|export KEY_NAME=changeme|export KEY_NAME="Chayanin"|' /etc/openvpn/easy-rsa/2.0/vars
sed -i 's|export KEY_OU=changeme|export KEY_OU=Chayanin|' /etc/openvpn/easy-rsa/2.0/vars
# Buat PKI
. /etc/openvpn/easy-rsa/2.0/vars
. /etc/openvpn/easy-rsa/2.0/clean-all
# Buat Sertifikat
export EASY_RSA="${EASY_RSA:-.}"
"$EASY_RSA/pkitool" --initca $*
# buat key server
export EASY_RSA="${EASY_RSA:-.}"
"$EASY_RSA/pkitool" --server server
# seting KEY CN
export EASY_RSA="${EASY_RSA:-.}"
"$EASY_RSA/pkitool" client
# DH params
. /etc/openvpn/easy-rsa/2.0/build-dh
# Setting Server
cat > /etc/openvpn/server.conf <<-END
port 1194
proto tcp
dev tun
tun-mtu 1500
tun-mtu-extra 32
mssfix 1450
ca /etc/openvpn/ca.crt
cert /etc/openvpn/server.crt
key /etc/openvpn/server.key
dh /etc/openvpn/dh2048.pem
plugin /usr/lib/openvpn/openvpn-auth-pam.so /etc/pam.d/login
client-cert-not-required
username-as-common-name
server 192.168.100.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
push "route-method exe"
push "route-delay 2"
keepalive 5 30
cipher AES-128-CBC
comp-lzo
persist-key
persist-tun
status server-vpn.log
verb 3
END
cd /etc/openvpn/easy-rsa/2.0/keys
cp ca.crt ca.key dh2048.pem server.crt server.key /etc/openvpn
cd /etc/openvpn/

#Create OpenVPN Config
mkdir -p /home/vps/public_html
cat > /home/vps/public_html/client.ovpn <<-END
# OpenVPN Configuration Created By Chayanin
client
proto tcp
persist-key
persist-tun
dev tun
pull
comp-lzo
ns-cert-type server
verb 3
mute 2
mute-replay-warnings
auth-user-pass
redirect-gateway def1
script-security 2
route 0.0.0.0 0.0.0.0
route-method exe
route-delay 2
remote $MYIP 1194
cipher AES-128-CBC
END
echo '<ca>' >> /home/vps/public_html/client.ovpn
cat /etc/openvpn/ca.crt >> /home/vps/public_html/client.ovpn
echo '</ca>' >> /home/vps/public_html/client.ovpn
cd /home/vps/public_html/
tar -czf /home/vps/public_html/openvpn.tar.gz client.ovpn
tar -czf /home/vps/public_html/client.tar.gz client.ovpn
cd

# set ipv4 forward
echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|' /etc/sysctl.conf
sed -i 's|net.ipv4.ip_forward=0|net.ipv4.ip_forward=1|' /etc/sysctl.conf

# Restart openvpn
/etc/init.d/openvpn restart

#install PPTP
apt-get -y install pptpd
cat > /etc/ppp/pptpd-options <<END
name pptpd
refuse-pap
refuse-chap
refuse-mschap
require-mschap-v2
require-mppe-128
ms-dns 8.8.8.8
ms-dns 8.8.4.4
proxyarp
nodefaultroute
lock
nobsdcomp
END
echo "option /etc/ppp/pptpd-options" > /etc/pptpd.conf
echo "logwtmp" >> /etc/pptpd.conf
echo "localip 10.1.0.1" >> /etc/pptpd.conf
echo "remoteip 10.1.0.5-100" >> /etc/pptpd.conf
cat >> /etc/ppp/ip-up <<END
ifconfig ppp0 mtu 1400
END
mkdir /var/lib/premium-script
/etc/init.d/pptpd restart

# install badvpn
wget -O /usr/bin/badvpn-udpgw "https://github.com/0613561761za/sshpanel/raw/master/badvpn-udpgw"
if [ "$OS" == "x86_64" ]; then
  wget -O /usr/bin/badvpn-udpgw "https://github.com/0613561761za/sshpanel/raw/master/badvpn-udpgw64"
fi
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300' /etc/rc.local
chmod +x /usr/bin/badvpn-udpgw
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300

# install mrtg
wget -O /etc/snmp/snmpd.conf "https://raw.githubusercontent.com/0613561761za/sshpanel/master/snmpd.conf"
wget -O /root/mrtg-mem.sh "https://raw.githubusercontent.com/0613561761za/sshpanel/master/mrtg-mem.sh"
chmod +x /root/mrtg-mem.sh
cd /etc/snmp/
sed -i 's/TRAPDRUN=no/TRAPDRUN=yes/g' /etc/default/snmpd
service snmpd restart
snmpwalk -v 1 -c public localhost 1.3.6.1.4.1.2021.10.1.3.1
mkdir -p /home/vps/public_html/mrtg
cfgmaker --zero-speed 100000000 --global 'WorkDir: /home/vps/public_html/mrtg' --output /etc/mrtg.cfg public@localhost
curl "https://raw.githubusercontent.com/0613561761za/sshpanel/master/mrtg.conf" >> /etc/mrtg.cfg
sed -i 's/WorkDir: \/var\/www\/mrtg/# WorkDir: \/var\/www\/mrtg/g' /etc/mrtg.cfg
sed -i 's/# Options\[_\]: growright, bits/Options\[_\]: growright/g' /etc/mrtg.cfg
indexmaker --output=/home/vps/public_html/mrtg/index.html /etc/mrtg.cfg
if [ -x /usr/bin/mrtg ] && [ -r /etc/mrtg.cfg ]; then mkdir -p /var/log/mrtg ; env LANG=C /usr/bin/mrtg /etc/mrtg.cfg 2>&1 | tee -a /var/log/mrtg/mrtg.log ; fi
if [ -x /usr/bin/mrtg ] && [ -r /etc/mrtg.cfg ]; then mkdir -p /var/log/mrtg ; env LANG=C /usr/bin/mrtg /etc/mrtg.cfg 2>&1 | tee -a /var/log/mrtg/mrtg.log ; fi
if [ -x /usr/bin/mrtg ] && [ -r /etc/mrtg.cfg ]; then mkdir -p /var/log/mrtg ; env LANG=C /usr/bin/mrtg /etc/mrtg.cfg 2>&1 | tee -a /var/log/mrtg/mrtg.log ; fi
cd

# setting port ssh
sed -i '/Port 22/a Port 143' /etc/ssh/sshd_config
sed -i '/Port 22/a Port  90' /etc/ssh/sshd_config
sed -i 's/Port 22/Port  22/g' /etc/ssh/sshd_config
service ssh restart

# install dropbear
apt-get -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=443/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 109 -p 110"/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
service ssh restart
service dropbear restart

#Upgrade to Dropbear 2017
cd
apt-get install zlib1g-dev
wget https://github.com/0613561761za/sshpanel/raw/master/dropbear-2017.75.tar.bz2
bzip2 -cd dropbear-2017.75.tar.bz2 | tar xvf -
cd dropbear-2017.75
./configure
make && make install
mv /usr/sbin/dropbear /usr/sbin/dropbear.old
ln /usr/local/sbin/dropbear /usr/sbin/dropbear
cd && rm -rf dropbear-2017.75 && rm -rf dropbear-2017.75.tar.bz2
service dropbear restart

# install vnstat gui
cd /home/vps/public_html/
wget https://github.com/0613561761za/sshpanel/raw/master/vnstat_php_frontend-1.5.1.tar.gz
tar xf vnstat_php_frontend-1.5.1.tar.gz
rm vnstat_php_frontend-1.5.1.tar.gz
mv vnstat_php_frontend-1.5.1 vnstat
cd vnstat
sed -i "s/\$iface_list = array('eth0', 'sixxs');/\$iface_list = array('eth0');/g" config.php
sed -i "s/\$language = 'nl';/\$language = 'en';/g" config.php
sed -i 's/Internal/Internet/g' config.php
sed -i '/SixXS IPv6/d' config.php
cd

# install fail2ban
apt-get -y install fail2ban;service fail2ban restart

# Instal DDOS Flate
if [ -d '/usr/local/ddos' ]; then
	echo; echo; echo "Please un-install the previous version first"
	exit 0
else
	mkdir /usr/local/ddos
fi
clear
echo; echo 'Installing DOS-Deflate 0.6'; echo
echo; echo -n 'Downloading source files...'
wget -q -O /usr/local/ddos/ddos.conf http://www.inetbase.com/scripts/ddos/ddos.conf
echo -n '.'
wget -q -O /usr/local/ddos/LICENSE http://www.inetbase.com/scripts/ddos/LICENSE
echo -n '.'
wget -q -O /usr/local/ddos/ignore.ip.list http://www.inetbase.com/scripts/ddos/ignore.ip.list
echo -n '.'
wget -q -O /usr/local/ddos/ddos.sh http://www.inetbase.com/scripts/ddos/ddos.sh
chmod 0755 /usr/local/ddos/ddos.sh
cp -s /usr/local/ddos/ddos.sh /usr/local/sbin/ddos
echo '...done'
echo; echo -n 'Creating cron to run script every minute.....(Default setting)'
/usr/local/ddos/ddos.sh --cron > /dev/null 2>&1
echo '.....done'
echo; echo 'Installation has completed.'
echo 'Config file is at /usr/local/ddos/ddos.conf'
echo 'Please send in your comments and/or suggestions to zaf@vsnl.com'

# install squid3
apt-get -y install squid3
cat > /etc/squid3/squid.conf <<-END
acl manager proto cache_object
acl localhost src 127.0.0.1/32 ::1
acl to_localhost dst 127.0.0.0/8 0.0.0.0/32 ::1
acl SSL_ports port 443
acl Safe_ports port 80
acl Safe_ports port 21
acl Safe_ports port 443
acl Safe_ports port 70
acl Safe_ports port 210
acl Safe_ports port 1025-65535
acl Safe_ports port 280
acl Safe_ports port 488
acl Safe_ports port 591
acl Safe_ports port 777
acl CONNECT method CONNECT
acl SSH dst xxxxxxxxx-xxxxxxxxx/32
http_access allow SSH
http_access allow manager localhost
http_access deny manager
http_access allow localhost
http_access deny all
http_port 8080
http_port 8000
http_port 3128
coredump_dir /var/spool/squid3
refresh_pattern ^ftp: 1440 20% 10080
refresh_pattern ^gopher: 1440 0% 1440
refresh_pattern -i (/cgi-bin/|\?) 0 0% 0
refresh_pattern . 0 20% 4320
visible_hostname Chayanin
END
sed -i $MYIP2 /etc/squid3/squid.conf;
service squid3 restart

# install webmin
cd
wget "https://github.com/0613561761za/sshpanel/raw/master/webmin_1.801_all.deb"
dpkg --install webmin_1.801_all.deb;
apt-get -y -f install;
sed -i 's/ssl=1/ssl=0/g' /etc/webmin/miniserv.conf
rm /root/webmin_1.801_all.deb
service webmin restart
service vnstat restart
apt-get -y --force-yes -f install libxml-parser-perl

#Setting IPtables
cat > /etc/iptables.up.rules <<-END
*filter
:FORWARD ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A FORWARD -i eth0 -o ppp0 -m state --state RELATED,ESTABLISHED -j ACCEPT
-A FORWARD -i ppp0 -o eth0 -j ACCEPT
-A OUTPUT -d 23.66.241.170 -j DROP
-A OUTPUT -d 23.66.255.37 -j DROP
-A OUTPUT -d 23.66.255.232 -j DROP
-A OUTPUT -d 23.66.240.200 -j DROP
-A OUTPUT -d 128.199.213.5 -j DROP
-A OUTPUT -d 128.199.149.194 -j DROP
-A OUTPUT -d 128.199.196.170 -j DROP
COMMIT

*nat
:PREROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -o eth0 -j MASQUERADE
-A POSTROUTING -s 192.168.100.0/24 -o eth0 -j MASQUERADE
-A POSTROUTING -s 10.1.0.0/24 -o eth0 -j MASQUERADE
COMMIT
END
sed -i '$ i\iptables-restore < /etc/iptables.up.rules' /etc/rc.local
sed -i $MYIP2 /etc/iptables.up.rules;
iptables-restore < /etc/iptables.up.rules

# download script
cd
wget https://raw.githubusercontent.com/0613561761za/sshpanel/master/update.sh -O - -o /dev/null|sh
wget https://raw.githubusercontent.com/0613561761za/sshpanel/master/update2 -O - -o /dev/null|sh

#install stunnel4
cd
apt-get update
apt-get upgrade
apt-get install stunnel4
wget -O /etc/stunnel/stunnel.conf "https://raw.githubusercontent.com/0613561761za/sshpanel/master/stunnel.conf"
openssl genrsa -out key.pem 2048
openssl req -new -x509 -key key.pem -out cert.pem -days 1095
cat key.pem cert.pem >> /etc/stunnel/stunnel.pem
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
/etc/init.d/stunnel4 restart

# finalisasi
apt-get -y autoremove
chown -R www-data:www-data /home/vps/public_html
service nginx start
service php5-fpm start
service vnstat restart
service openvpn restart
service snmpd restart
service ssh restart
service dropbear restart
service fail2ban restart
service squid3 restart
service webmin restart
service pptpd restart
sysv-rc-conf rc.local on

#clearing history
history -c

# info
clear
echo " "
echo "Installation Process Is 100% Done . Please Read Rule Server!"
echo " "
echo "     ========================================================="
echo "     *                   Info Setup Server                   *"
echo "     ========================================================="
echo "     *                Copyright Kaizen Apeach                *"
echo "     *                Whatsapp: +60178958795                 *"
echo "     *                Telegram: @KaizenA                     *"
echo "     ========================================================="
echo ""  | tee -a log-install.txt
echo "Maklumat Server"  | tee -a log-install.txt
echo "---------------"  | tee -a log-install.txt
echo "   - Timezone     : Asia/KualaLumpur (GMT +8)"  | tee -a log-install.txt
echo "   - Fail2Ban     : [on]"  | tee -a log-install.txt
echo "   - Anti DDoS    : [on]"  | tee -a log-install.txt
echo "   - Anti Torrent : [on]"  | tee -a log-install.txt
echo "   - Auto-Reboot  : [off]"  | tee -a log-install.txt
echo "   - IPv6         : [off]"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Maklumat Applikasi dan Port"  | tee -a log-install.txt
echo "---------------------------"  | tee -a log-install.txt
echo "   - OpenVPN     : TCP 1194 "  | tee -a log-install.txt
echo "   - OpenSSH     : 22, 143"  | tee -a log-install.txt
echo "   - Dropbear    : 109, 110, 443"  | tee -a log-install.txt
echo "   - Squid Proxy : 80, 3128, 8000, 8080 (limit to IP Server)"  | tee -a log-install.txt
echo "   - Badvpn      : 7300"  | tee -a log-install.txt
echo "   - Nginx       : 81"  | tee -a log-install.txt
echo "   - PPTP VPN    : 1732"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Maklumat Script"  | tee -a log-install.txt
echo "---------------"  | tee -a log-install.txt
echo "   Sila taip: menu"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Senarai link sistem"  | tee -a log-install.txt
echo "-------------------"  | tee -a log-install.txt
echo "   - Download Config OpenVPN : http://$MYIP:81/client.ovpn"  | tee -a log-install.txt
echo "     Mirror (*.tar.gz)       : http://$MYIP:81/openvpn.tar.gz"  | tee -a log-install.txt
echo "   - Webmin                  : http://$MYIP:10000/"  | tee -a log-install.txt
echo "   - Vnstat                  : http://$MYIP:81/vnstat/"  | tee -a log-install.txt
echo "   - MRTG                    : http://$MYIP:81/mrtg/"  | tee -a log-install.txt
echo "   - Log Installation        : cat /root/log-install.txt"  | tee -a log-install.txt
echo "     PS: User & Password Webmin adalah sama dengan User & Password root"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "-------------------------------------------------------------------------------"
echo "                   Taip ${green}menu ${NC}untuk menampilkan senarai menu                    "
echo "-------------------------------------------------------------------------------"
rm deb7.sh
