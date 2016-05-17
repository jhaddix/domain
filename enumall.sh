#!/bin/bash

# Subdomain enumeration script that creates/uses a dynamic resource script for recon-ng.
# The google site api module requires a API key (/api/google_site) to enter that you can find instructions for that on the recon-ng wiki.
# Or you can comment out that module. The Shodan module requires an API key as well, same deal. 
#
# Enumall.sh uses google scraping, bing scraping, baidu scraping, netcraft, and bruteforces for DNS subdomains.
# I use a custom DNS bruteforce list from the Seclists project (combines Knock, firece, recon-ng lists, ++) located here: 
# https://github.com/danielmiessler/SecLists/blob/master/Discovery/DNS/sorted_knock_dnsrecon_fierce_recon-ng.txt
# That file needs to be dropped in /usr/share/recon-ng/data/
# by @jhaddix

# input from command-line becomes domain to test
domain=$1

#run as bash enumall.sh paypal.com

#timestamp
stamp=$(date +"%m_%d_%Y")

#create rc file with workspace.timestamp and start enumerating hosts
touch $domain$stamp.resource
echo ""
echo $domain
echo ""
echo "workspaces select $domain$stamp" >> $domain$stamp.resource
echo ""
echo "set TIMEOUT 100" >> $domain$stamp.resource
echo "use recon/domains-hosts/baidu_site" >> $domain$stamp.resource
echo "set SOURCE $domain" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource
echo ""
echo "use recon/domains-hosts/bing_domain_web" >> $domain$stamp.resource
echo "set SOURCE $domain" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource
echo ""
echo "use recon/domains-hosts/google_site_web" >> $domain$stamp.resource
echo "set SOURCE $domain" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource
echo ""
echo "use recon/domains-hosts/netcraft" >> $domain$stamp.resource
echo "set SOURCE $domain" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource
echo ""
echo "use recon/domains-hosts/yahoo_domain" >> $domain$stamp.resource
echo "set SOURCE $domain" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource
echo ""
##echo "use recon/domains-hosts/google_site_api" >> $domain$stamp.resource
##echo "set SOURCE $domain" >> $domain$stamp.resource
##echo "run" >> $domain$stamp.resource
##echo ""
##echo "use recon/domains-hosts/vpnhunter" >> $domain$stamp.resource
##echo "set SOURCE $domain" >> $domain$stamp.resource
##echo "run" >> $domain$stamp.resource
echo ""
echo "use recon/domains-hosts/shodan_hostname" >> $domain$stamp.resource
echo "set SOURCE $domain" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource
echo ""
echo "use recon/domains-hosts/brute_hosts" >> $domain$stamp.resource
echo "set WORDLIST /usr/share/recon-ng/data/sorted_knock_dnsrecon_fierce_recon-ng.txt" >> $domain$stamp.resource
echo "set SOURCE $domain" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource
echo ""
echo "use recon/netblocks-companies/whois_orgs" >> $domain$stamp.resource
echo "set SOURCE $domain" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource
echo ""
echo "use recon/hosts-hosts/resolve" >> $domain$stamp.resource
echo "set SOURCE $domain" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource
echo ""
echo "use reporting/csv" >> $domain$stamp.resource
echo "set FILENAME /root/Desktop/$domain$stamp.csv" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource
echo ""
echo "use reporting/list" >> $domain$stamp.resource
echo "set FILENAME /root/Desktop/$domain$stamp.lst" >> $domain$stamp.resource
echo "set COLUMN host" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource
echo ""
echo "exit" >> $domain$stamp.resource
sleep 1
echo ""

# python was giving some weird errors when trying to call python /opt/recon-ng/recon-ng so this workaround worked.

path=$(pwd)
cd /usr/share/recon-ng
./recon-ng --no-check -r $path/$domain$stamp.resource
