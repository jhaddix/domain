# Info

Recon-ng and Alt-DNS are awesome. This script combines the power of these tools with the ability to run multiple domains within the same session.

TLDR; I just want to do my subdomain discovery via ONE command and be done with it.

Only 1 module needs an api key (/api/google_site) find instructions for that on the recon-ng wiki.

Script to enumerate subdomains, leveraging recon-ng. Uses google scraping, bing scraping, baidu scraping, yahoo scraping, netcraft, and bruteforces to find subdomains. Plus resolves to IP.

# Pre-Requisites

Installation recon-ng from Source

1. Clone the Recon-ng repository

    `git clone https://LaNMaSteR53@bitbucket.org/LaNMaSteR53/recon-ng.git`
2. Change into the Recon-ng directory.

    `cd recon-ng`

3. Install dependencies.

    `pip install -r REQUIREMENTS`

4. Eventually link the installation directory to /usr/share/recon-ng

    `ln -s /$recon-ng_path /usr/share/recon-ng`

5. Optionally (highly recommended) download: 

    + Alt-DNS (https://github.com/infosec-au/altdns)
    + and a good subdomain bruteforce list (https://github.com/danielmiessler/SecLists/blob/master/Discovery/DNS/sorted_knock_dnsrecon_fierce_recon-ng.txt)

6. Create config.py file and specify the path to recon-ng and allDNS as it showed in config_sample.py

# Basic Usage

`./enumall.py domain.com`

also supports:
+ -w to run a custom wordlist with recon-ng
+ -a to use alt-dns
+ -p to feed a custom permutations list to alt-dns (requires -a flag)
+ -i to feed a list of domains (can also type extra domains into the original command)

# Advanced Usage

`./enumall.py domain1.com domain2.com domain3.com -i domainlist.txt -a -p permutationslist.txt -w wordlist.com`

Output from recon-ng will be in `.lst` and `.csv` files, output from alt-dns will be in a `.txt` file


by @jhaddix and @leifdreizler
