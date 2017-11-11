#!/bin/bash
#================================
echo "========script กากๆ ============="
echo "ใช้สำหรับ server ส่วนตัว ไม่เหมาะกับการทำให้เช่า"
echo "สำหรับ linux debian 7 8 9 64 bit"
echo "แหล่งที่มา ของคอนฟิก  กูเกิ้ล ไง"
echo ""
#===============================

# ใช้สิทธิ์ root ในการรันคอมมาน ปิดไอพีวี6,ติดตั้ง wget curl, อัพเดท
cd
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local
apt-get update
apt-get -y install wget curl

# ตั้งค่าเขตเวลา, โลคอล ssh รีสตาร์ท บริการ ssh 
ln -fs /usr/share/zoneinfo/Asia/Bangkok /etc/localtime
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
service ssh restart

# ลบแพคเก็จไม่จำเป็น,อัพเดท อัพเกรด แพคเก็จในเซอร์เวอร์
apt-get -y --purge remove samba*;
apt-get -y --purge remove apache2*;
apt-get -y --purge remove sendmail*;
apt-get -y --purge remove bind9*;
apt-get update 
apt-get -y upgrade

# ติดตั้ง/หยุด แพคเก็จที่ที่จำเป็นเกี่ยวเกี่ยวกับ เว็ปเซอร์เวอร์,อัพเดทไฟล์ เอพีที แพคเก็จ
apt-get -y install nginx php5-fpm php5-cli
apt-get -y install nmap nano iptables sysv-rc-conf openvpn vnstat apt-file
apt-get -y install libexpat1-dev libxml-parser-perl
apt-get -y install build-essential
apt-get -y install mysql-server mysql_secure_installation
chown -R mysql:mysql /var/lib/mysql/
chmod -R 755 /var/lib/mysql/ 
apt-get -y install nginx php5 php5-fpm php5-cli php5-mysql php5-mcrypt
apt-get -y install git
service exim4 stop
sysv-rc-conf exim4 off
apt-file update

# ตั้งค่า Vnstat
vnstat -u -i eth0
chown -R vnstat:vnstat /var/lib/vnstat
service vnstat restart

# ติดตั้ง screenfetch โลโก้ที่แสดงเวลาใช้ SSH remote หรือ vnc
cd
wget https://raw.githubusercontent.com/auiyhyo/deb8/master/screenfetch-dev
mv screenfetch-dev /usr/bin/screenfetch
chmod +x /usr/bin/screenfetch
echo "clear" >> .profile
echo "screenfetch" >> .profile

# ติดตั้ง Web Server และ config ต่างๆ
cd
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.old

wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/auiyhyo/deb8/master/nginx.conf"
wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/auiyhyo/deb8/master/vps.conf"
sed -i 's/cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php5/fpm/php.ini
sed -i 's/listen = \/var\/run\/php5-fpm.sock/listen = 127.0.0.1:9000/g' /etc/php5/fpm/pool.d/www.conf
echo "<pre>ติดตั้งโดย มึงแหล่ะ</pre>" > /home/vps/public_html/index.html
useradd -m vps
mkdir -p /home/vps/public_html
echo "<?php phpinfo(); ?>" > /home/vps/public_html/info.php
chown -R www-data:www-data /home/vps/public_html chmod -R g+rw /home/vps/public_html
service php5-fpm restart
service nginx restart

# ติดตั้งแพคเก็จ openvpn และตั้งค่าคอนฟิกที่เกี่ยวข้อง
wget -O /etc/openvpn/openvpn.tar "https://raw.githubusercontent.com/Wullop/DEBIANKGUZA/master/openvpn-debian.tar"
cd /etc/openvpn/
tar xf openvpn.tar
wget -O /etc/openvpn/1194.conf "https://raw.githubusercontent.com/Wullop/DEBIANKGUZA/master/1194.conf"
service openvpn restart
sysctl -w net.ipv4.ip_forward=1
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
wget -O /etc/iptables.up.rules "https://raw.githubusercontent.com/auiyhyo/deb8/master/iptables.up.rules"
sed -i '$ i\iptables-restore < /etc/iptables.up.rules' /etc/rc.local
sed -i $MYIP2 /etc/iptables.up.rules;
iptables-restore < /etc/iptables.up.rules
service openvpn restart
iptables -t nat -I POSTROUTING -s 192.168.100.0/24 -o eth0 -j MASQUERADE
iptables-save > /etc/iptables_yg_baru_dibikin.conf
wget -O /etc/network/if-up.d/iptables "https://raw.githubusercontent.com/auiyhyo/deb8/master/iptables"
chmod +x /etc/network/if-up.d/iptables
service openvpn restart
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

# ตั้งค่า port ssh 
sed -i '/Port 22/a Port 143' /etc/ssh/sshd_config
sed -i 's/Port 22/Port  22/g' /etc/ssh/sshd_config
service ssh restart

# ติดตั้ง dropbear
apt-get -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=443/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 109 -p 110"/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
service ssh restart
service dropbear restart

# install vnstat gui
cd /home/vps/public_html/
wget http://www.sqweek.com/sqweek/files/vnstat_php_frontend-1.5.1.tar.gz
tar xf vnstat_php_frontend-1.5.1.tar.gz
rm vnstat_php_frontend-1.5.1.tar.gz
mv vnstat_php_frontend-1.5.1 vnstat
cd vnstat
sed -i "s/\$iface_list = array('eth0', 'sixxs');/\$iface_list = array('eth0');/g" config.php
sed -i "s/\$language = 'nl';/\$language = 'en';/g" config.php
sed -i 's/Internal/Internet/g' config.php
sed -i '/SixXS IPv6/d' config.php
sed -i "s/\$locale = 'en_US.UTF-8';/\$locale = 'en_US.UTF+8';/g" config.php
cd

# ติดตั้ง fail2ban ตั้งค่า squid3
apt-get -y install fail2ban;
service fail2ban restart
apt-get -y install squid3
wget -O /etc/squid3/squid.conf "https://raw.githubusercontent.com/jhelson15/re-construction/master/conf/squid.conf"
sed -i $MYIP2 /etc/squid3/squid.conf;
service squid3 restart


# ติดตั้ง webmin และเริ่มการทำงาน
 cd
 wget -O webmin-current.deb "http://www.webmin.com/download/deb/webmin-current.deb"
 dpkg -i --force-all webmin-current.deb;
 apt-get -y -f install;
 rm /root/webmin-current.deb
 service webmin restart
 service vnstat restart

#ระบบddosป้องป้องกันเซิฟ
cd
apt-get -y install dnsutils dsniff
https://github.com/auiyhyo/deb8/raw/master/ddos-deflate-master.zip
unzip master.zip
cd ddos-deflate-master
./install.sh

# ติดตั้ง autokick ของ ssh
cd
wget https://raw.githubusercontent.com/auiyhyo/deb8/master/Autokick-debian.sh
bash Autokick-debian.sh

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

# Restart Service
chown -R www-data:www-data /home/vps/public_html
service nginx start
service php-fpm start
service vnstat restart
service openvpn restart
service ssh restart
service dropbear restart
service fail2ban restart
service squid3 restart
service webmin restart

echo "ติดตั้ง ocs test"
echo "แพเก็จที่จำเป็นได้ติดตั้งไว้แล้ว ทดสอบการที่"
echo "http://$MYIP:81/info.php :ถ้าเข้าได้ถือว่าใกล้และ"
 
#ocs
echo "เรียกใช้ mysql ด้วยรูท และใส่พาสเพื่อไปต่อ"
mysql -u root -p

echo "จากนั้นใส่ CREATE DATABASE IF NOT EXISTS OCSREBORN;EXIT; ตัวอย่าง mysql >CREATE DATABASE IF NOT EXISTS OCSREBORN;EXIT;"

#ยาวไป
cd /home/vps/public_html
git init
git remote add origin https://github.com/rzengineer/Ocs-Panel-Reborns.git
git pull origin master
chmod 777 /home/vps/public_html/application/config/database.php

echo "แก้ไข ฐานข้อมูล เช่น ชื่อ พาส"
nano /home/vps/public_html/application/config/database.php

echo "แก้คอนฟิก php แบบนี้ Cari $config[‘base_url’] = $root; -> ????? -> $config[‘base_url’] = “http://ไอพีเซิฟ:81"
nano /home/vps/public_html/application/config/config.php


# สรุป
clear
echo ""
echo "==============================================="
echo "สรุปและผลการติดตั้ง"
echo "ไฟล์คอนฟิกสำหรับ openVPN  : TCP 1194 (client config : http://$MYIP:80/$NAME.ovpn)"
echo "OpenSSH  : 22, 143"
echo "Dropbear : 109, 110, 443"
echo "port สำหรับ proxy   : 8080, 808, 3128 (ใช้ $MYIP)"
echo "ใช้งาน Webmin ผ่าน   : http://$MYIP:10000/"
echo "vnstat   : http://$MYIP:80/vnstat/"
echo "Timezone : ประเทศไทย กทม."
echo "Fail2Ban : [เปิด]"
echo "IPv6     : [ปิด]"
echo "เช็คสถานะผู้ใช้งาน  : พิมพ์ ./status"
echo "Dos Deflate  : ถอนการติดตั้งได้โดย ./uninstall.sh "
echo "เรียกใช้ เมนู พิมพ์ bash menu หรือ ./menu"
echo "ocs เริ่มใช้  : http://$MYIP:81/install/"
echo "Reboot VPS ซักทีก่อนก่อนใช้ พิมพ์ reboot"
echo "เอาไว้ลงเซอร์ ส่วนส่วนตัว"
echo "ตั้งตั้งค่า พร๊อกซี่  พิมพ์ SQ"
echo "==============================================="
echo ""
