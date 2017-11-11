#!/bin/bash
# ******************************************
# Program: ออโต้สคิป VPS 2017
# ต้นฉบับ: อินโดทำมา 
# อัพเดท: แปลกๆไหม
# เมื่อ: 22 สิงหาคม 2560
# สำหรับ: debian 7,8,9 x64
# ******************************************

# initialisasi var
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;
MYIP=$(wget -qO- ipv4.icanhazip.com);
MYIP2="s/xxxxxxxxx/$MYIP/g";
echo "sudo su" >> .bashrc

# go to root
cd

# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

# install wget and curl
apt-get update;apt-get -y install wget curl;

# set time GMT +7
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
service ssh restart

# set repo
wget -O /etc/apt/sources.list "https://raw.githubusercontent.com/Wullop/DEBIANKGUZA/master/sources.list.debian8"
wget "https://raw.githubusercontent.com/Wullop/DEBIANKGUZA/master/dotdeb.gpg"
wget "https://raw.githubusercontent.com/Wullop/DEBIANKGUZA/master/jcameron-key.asc"
cat dotdeb.gpg | apt-key add -;rm dotdeb.gpg
cat jcameron-key.asc | apt-key add -;rm jcameron-key.asc

# update
apt-get update

# User Status
cd
wget https://raw.githubusercontent.com/auiyhyo/debian7/master/user-list
mv ./user-list /usr/local/bin/user-list
chmod +x /usr/local/bin/user-list

#screenfetch
cd
wget https://raw.githubusercontent.com/auiyhyo/debian7/master/screenfetch-dev
mv screenfetch-dev /usr/bin/screenfetch
chmod +x /usr/bin/screenfetch
echo "clear" >> .profile
echo "screenfetch" >> .profile

# limit
wget -O userexpired.sh "https://raw.githubusercontent.com/auiyhyo/debian7/master/userexpired.sh"
echo "@reboot root /root/userexpired.sh" > /etc/cron.d/userexpired
chmod +x userexpired.sh

# Install Monitor
cd
wget https://raw.githubusercontent.com/auiyhyo/debian7/master/monssh
mv monssh /usr/local/bin
chmod +x /usr/local/bin/monssh

# fail2ban & exim & protection
apt-get -y install fail2ban sysv-rc-conf dnsutils dsniff zip unzip;
wget https://github.com/auiyhyo/debian7/raw/master/ddos-deflate-master.zip;unzip ddos-deflate-master.zip;
cd ddos-deflate-master && ./install.sh
service exim4 stop;sysv-rc-conf exim4 off;

# webmin
wget http://www.webmin.com/jcameron-key.asc
apt-key add jcameron-key.asc
echo "deb http://download.webmin.com/download/repository sarge contrib" >> /etc/apt/sources.list
echo "deb http://webmin.mirror.somersettechsolutions.co.uk/repository sarge contrib" >> /etc/apt/sources.list
apt-get update
apt-get -y install webmin

#disable webmin https
sed -i "s/ssl=1/ssl=0/g" /etc/webmin/miniserv.conf
/etc/init.d/webmin restart
service vnstat restart

# ssh
sed -i 's/#Banner/Banner/g' /etc/ssh/sshd_config
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
wget -O /etc/issue.net "https://raw.githubusercontent.com/auiyhyo/debian7/master/banner"

# dropbear
apt-get -y install dropbear
wget -O /etc/default/dropbear "https://raw.githubusercontent.com/auiyhyo/debian7/master/dropbear"
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells

# squid3
apt-get -y install squid3
wget -O /etc/squid3/squid.conf "https://raw.githubusercontent.com/auiyhyo/debian7/master/squid.conf"
sed -i "s/ipserver/$myip/g" /etc/squid3/squid.conf

# nginx
apt-get -y install nginx php5-fpm php5-cli libexpat1-dev libxml-parser-perl
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/auiyhyo/debian7/master/nginx.conf"
mkdir -p /home/vps/public_html
echo "<pre>แก้เล่นๆ โดย กูเอง | แรงไม่แรงไม่เกี่ยวกับกู | ไปด่าคนทำเซิฟ</pre>" > /home/vps/public_html/index.php
echo "<?php phpinfo(); ?>" > /home/vps/public_html/info.php
wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/auiyhyo/debian7/master/vps.conf"
sed -i 's/listen = \/var\/run\/php5-fpm.sock/listen = 127.0.0.1:9000/g' /etc/php5/fpm/pool.d/www.conf

# install openvpn
wget -O /etc/openvpn/openvpn.tar "https://raw.githubusercontent.com/Wullop/DEBIANKGUZA/master/openvpn-debian.tar"
cd /etc/openvpn/
tar xf openvpn.tar
wget -O /etc/openvpn/1194.conf "https://raw.githubusercontent.com/Wullop/DEBIANKGUZA/master/1194.conf"
service openvpn restart
sysctl -w net.ipv4.ip_forward=1
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
iptables -t nat -I POSTROUTING -s 192.168.100.0/24 -o eth0 -j MASQUERADE
iptables-save > /etc/iptables_yg_baru_dibikin.conf
wget -O /etc/network/if-up.d/iptables "https://raw.githubusercontent.com/Wullop/DEBIANKGUZA/master/iptables"
chmod +x /etc/network/if-up.d/iptables
service openvpn restart

# config openvpn
cd /etc/openvpn/
wget -O /etc/openvpn/True-Dtac.ovpn "https://raw.githubusercontent.com/Wullop/DEBIANKGUZA/master/client-1194.conf"
sed -i $MYIP2 /etc/openvpn/True-Dtac.ovpn;
cp True-Dtac.ovpn /home/vps/public_html/

# install badvpn
cd
wget -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/Wullop/DEBIANKGUZA/master/badvpn-udpgw"
if [ "$OS" == "x86_64" ]; then
  wget -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/Wullop/DEBIANKGUZA/master/badvpn-udpgw64"
fi
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300' /etc/rc.local
chmod +x /usr/bin/badvpn-udpgw
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300

# download script
cd /usr/bin
wget -O menu "https://raw.githubusercontent.com/Wullop/DEBIANKGUZA/master/menu.sh"
wget -O addkguza "https://raw.githubusercontent.com/Wullop/DEBIANKGUZA/master/adduser.sh"
wget -O 2 "https://raw.githubusercontent.com/Wullop/DEBIANKGUZA/master/testuser.sh"
wget -O 3 "https://raw.githubusercontent.com/Wullop/DEBIANKGUZA/master/rename.sh"
wget -O 4 "https://raw.githubusercontent.com/Wullop/DEBIANKGUZA/master/repass.sh"
wget -O 5 "https://raw.githubusercontent.com/Wullop/DEBIANKGUZA/master/delet.sh"
wget -O 6 "https://raw.githubusercontent.com/Wullop/DEBIANKGUZA/master/deletuserxp.sh"
wget -O 7 "https://raw.githubusercontent.com/Wullop/DEBIANKGUZA/master/viewuser.sh"
wget -O 8 "https://raw.githubusercontent.com/Wullop/DEBIANKGUZA/master/restart.sh"
wget -O 9 "https://raw.githubusercontent.com/Wullop/DEBIANKGUZA/master/speedtest.py"
wget -O 10 "https://raw.githubusercontent.com/Wullop/DEBIANKGUZA/master/online.sh"
wget -O 11 "https://raw.githubusercontent.com/Wullop/DEBIANKGUZA/master/viewlogin.sh"
wget -O 12 "https://raw.githubusercontent.com/Wullop/DEBIANKGUZA/master/aboutsystem.sh"
wget -O 13 "https://raw.githubusercontent.com/Wullop/DEBIANKGUZA/master/aboutscrip.sh"

echo "0 0 * * * root /sbin/reboot" > /etc/cron.d/reboot

chmod +x menu
chmod +x addkguza
chmod +x 2
chmod +x 3
chmod +x 4
chmod +x 5
chmod +x 6
chmod +x 7
chmod +x 8
chmod +x 9
chmod +x 10
chmod +x 11
chmod +x 12
chmod +x 13

# restart service
service ssh restart
service openvpn restart
service dropbear restart
service nginx restart
service php5-fpm restart
service webmin restart
service squid3 restart
service fail2ban restart
clear
# info
clear
echo " =============
 Kguza figther
 =============
 Service 
 ---------------------------------------------
 OpenSSH  : 22, 143 
 Dropbear : 80, 443 
 Squid3   : 8080, 3128 (limit to IP SSH) 
 ===========Detail OpenVPN Account ===========
 Download App
 http://$MYIP:81/kguza.html
 *********************************************
 Config OpenVPN (TCP 1194)
 Download File
 http://$MYIP:81/True-Dtac.ovpn
 =============================================
 badvpn   : badvpn-udpgw port 7300 
 nginx    : 81 
 Webmin   : http://$MYIP:10000/ 
 Timezone : Asia/Thailand (GMT +7) 
 IPv6     : [off] 
 =============================================
echo " VPS AUTO REBOOT 00.00"
echo " «««««««««««««««»»»»»»»»»»»»»»»» " 
echo " prin { menu } show list on menu "
echo " «««««««««««««««»»»»»»»»»»»»»»»» " 
echo " Vnstat     :  http://$MYIP:81/vnstat"
echo " »»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»" 
cd
rm -f /root/kguza-scrip.sh
