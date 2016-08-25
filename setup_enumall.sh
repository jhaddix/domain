#!/bin/bash
#
# helps to setup domain, altdns, recon-ng tools 
# Author: coreb1t

VIRTENV=enumall
HOWTOFILE=how_to_use.txt

echo "please enter the absolute path to the directory where the enumall.py tool should be installed"
echo "  example: <path>/<to>/tools/enumall" 
read path

if [ ! -d $path ];then
    mkdir $path
    echo "[+] directory $path created"
else
    echo "[-] directory $path already exists"
    echo "[-] exit"
    exit 
fi

cd $path

echo -e "[+] cloning git repos\n"
git clone https://LaNMaSteR53@bitbucket.org/LaNMaSteR53/recon-ng.git
git clone https://github.com/infosec-au/altdns.git
git clone https://github.com/jhaddix/domain.git
wget https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/sorted_knock_dnsrecon_fierce_recon-ng.txt

cd domain 
pathSed=$(echo $path | sed s/'\/'/'\\\/'/g)
sed -i "s/^reconPath.*/reconPath = \"$pathSed\/recon-ng\/\"/g" enumall.py
sed -i "s/^altDnsPath.*/altDnsPath = \"$pathSed\/altdns\/\"/g" enumall.py

chmod 755 enumall.py

# write how-to file
echo -e "\nIf you are using python virtualenv, excute workon $VIRTENV before running the script\n" > $HOWTOFILE
echo "./enumall.py <domain> -a -p ../altdns/words.txt -w ../sorted_knock_dnsrecon_fierce_recon-ng.txt" >> $HOWTOFILE 

# install virtualenv
echo -e "\n[+] configure the virtual env"
echo "[+] execute the following command"
echo "    cd $path; mkvirtualenv $VIRTENV; pip install -r recon-ng/REQUIREMENTS; pip install -r altdns/requirements.txt"