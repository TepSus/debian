#! / bin / ทุบตี
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


"
apt-get -y --purge remove samba*;
apt-get -y --purge remove apache2*;
apt-get -y --purge remove sendmail*;
apt-get -y --purge remove postfix*;
apt-get -y --purge remove bind*;
clear

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

# setting port ssh
cd
sed -i 's/Port 22/Port 22/g' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 143' /etc/ssh/sshd_config
service ssh restart

# install dropbear
apt-get -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=443/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 443 -p 80"/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
service ssh restart
service dropbear restart

# install squid3
cd
apt-get -y install squid3
wget -O /etc/squid3/squid.conf "https://raw.githubusercontent.com/Wullop/DEBIANKGUZA/master/squid3.conf"
sed -i $MYIP2 /etc/squid3/squid.conf;
service squid3 restart

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

# download script
cd /usr/bin
wget -O menu "https://raw.githubusercontent.com/Wullop/DEBIANKGUZA/master/menu.sh"
wget -O 1 "https://raw.githubusercontent.com/Wullop/DEBIANKGUZA/master/adduser.sh"
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
chmod +x 1
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

# finishing
cd
chown -R www-data:www-data /home/vps/public_html
service nginx start
service openvpn restart
service cron restart
service ssh restart
service dropbear restart
service squid3 restart
service webmin restart
rm -rf ~/.bash_history && history -c
echo "Canceled HISTFILE" >> /etc/profile

# info
clear
echo " =============
 Tepsua figther
 =============
 Service 
 ---------------------------------------------
 OpenSSH  : 22, 143 
 Dropbear : 80, 443 
 Squid3   : 8080, 3128 (limit to IP SSH) 
 ===========Detail OpenVPN Account 
 Config OpenVPN (TCP 1194)
 Download File
 http://$MYIP:81/True-Dtac.ovpn
 =============================================
 badvpn   : badvpn-udpgw port 7300 
 nginx    : 81 
 Webmin   : http://$MYIP:10000/ 
 Timezone : Asia/Thailand (GMT +7) 
 IPv6     : [off] 
  ============================================="
echo " VPS AUTO REBOOT 00.00"
echo " «««««««««««««««»»»»»»»»»»»»»»»» " 
echo " พิมพ์ menu [enter] เบาๆคำสั่งเซิพพี่เทพจะเเสดง >> บางคำสั่งใช้ไม่ได้ดิ้นเอาหน่อย << "
echo " «««««««««««««««»»»»»»»»»»»»»»»» " 
echo " Vnstat     :  http://$MYIP:81/vnstat"
echo " »»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»" 
cd
rm -f /root/Tepsus-scrip.sh



















