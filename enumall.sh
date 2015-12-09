#!/bin/bash

# Subdomain enumeration script that creates/uses a dynamic resource script for recon-ng.
# only 1 module needs api’s (/api/google_site) find instructions for that on the wiki.
# Or you can comment out that module.
# uses google scraping, bing scraping, baidu scraping, netcraft, and bruteforces to find subdomains.
# by @jhaddix
# contributions: @reapzor
# input from command-line becomes domain to test
DOMAINS=()
STAMP=$(date +"%m_%Y")
CURRENT_PATH=$(pwd)
MODULES=(
"recon/domains-hosts/brute_hosts"
"recon/domains-hosts/baidu_site"
"recon/domains-hosts/bing_domain_web"
"recon/domains-hosts/google_site_api"
"recon/domains-hosts/yahoo_domain"
"recon/domains-hosts/shodan_hostname"
"recon/domains-hosts/ssl_san"
"recon/domains-hosts/vpnhunter"
"recon/hosts-hosts/bing_ip"
"recon/hosts-hosts/freegeoip"
"recon/hosts-hosts/resolve"
"recon/hosts-hosts/reverse_resolve"
"recon/domains-vulnerabilities/punkspider"
"recon/domains-contacts/pgp_search"
"recon/domains-contacts/salesmaple"
)
#------------------------------------------------------------------------------------------------
if [ $# -eq 0 ]
  then
    echo "enumall.sh -n <name> domain [domain2 domain3 ...]"
    exit 1
fi

while [[ $# > 0 ]]
do
KEY="$1"

case $KEY in
    -n|--name)
    NAME="$2"
    shift # begone argument!
    ;;

    *)
    DOMAINS+=($KEY) 
          #no predefined parameter, so assuming it's a domain 
    ;;
esac

shift #onto the next!

done

if [ -z "$NAME" ]
 then
    echo "no name, no game"
    exit 1
fi
echo "Initializing recon-ng with folowing parameters:"
echo "Workspace name: $NAME"
echo "Current Path: $PATH"
echo "Timestamp: $STAMP"
echo "Domains: ${DOMAINS[@]}"
echo "Modules: ${MODULES[@]}"

#create rc file with workspace.timestamp and start enumerating hosts
touch $NAME_$STAMP.resource

echo "workspaces select $NAME" > $NAME_$STAMP.resource #first one cleans up if there was already a resource file

for DOMAIN in "${DOMAINS[@]}"
do
    echo "add domains $DOMAIN" >> $NAME_$STAMP.resource
done

for MODULE in "${MODULES[@]}"
do
    echo "use $MODULE" >> $NAME_$STAMP.resource
    echo "run" >> $NAME_$STAMP.resource
done

sleep 1
# python was giving some weird errors when trying to call python /opt/recon-ng/recon-ng so this workaround worked.

cd /usr/share/recon-ng/
./recon-ng --no-check -r $CURRENT_PATH/$NAME_$STAMP.resource

# now just run "show hosts" or use a report module in recon-ng prompt
