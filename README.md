# Info

Recon-ng and Alt-DNS are awesome. This script combines the power of these tools with the ability to run multiple domains within the same session.

TLDR; I just want to do my subdomain discovery via ONE command and be done with it.

Only 2 module needs api keys (`/api/google_site`, `/api/shodan`); find instructions for that on the recon-ng wiki.

Script to enumerate subdomains, leveraging recon-ng. Uses google scraping, bing scraping, baidu scraping, yahoo scraping, netcraft, and bruteforces to find subdomains. Plus resolves to IP.

# Pre-Requisites

Installation recon-ng from Source

1. Clone the Recon-ng repository

    `git clone https://github.com/lanmaster53/recon-ng`

1. Change into the Recon-ng directory.

    `cd recon-ng`

1. Install dependencies in a virtual environment:

    ```python
    python3 -m pip install --upgrade pip setuptools wheel
    python3 -m pip install venv
    python3 -m venv .venv
  
    source .venv/bin/activate
    python3 -m pip install --upgrade pip setuptools wheel
    python3 -m pip install -r REQUIREMENTS
    ```

1. Symlink the `recon` lib and recon-ng `VERSION` from our clone to this repository:

    ```python
    ln -s /path/to/recon-ng/recon ./recon
    ln -s /path/to/recon-ng/VERSION ./VERSION
    ```

1. Optionally (highly recommended) download: 
    - [Alt-DNS][alt-dns] (`git clone https://github.com/infosec-au/altdns && python3 -m pip install altdns/`)
    - and a good subdomain [bruteforce list][dns-wl] (`git clone https://github.com/danielmiessler/SecLists`)


[alt-dns]: https://github.com/infosec-au/altdns
[dns-wl]: https://github.com/danielmiessler/SecLists/blob/master/Discovery/DNS/sorted_knock_dnsrecon_fierce_recon-ng.txt

# Usage

```
(.venv) ➜ ./enumall.py -h
usage: enumall.py [-h] [-a] [-i IN_FILE] [-o OUT_FILE] [-w WORDLIST] [-p PERMLIST] [domains ...]

positional arguments:
  domains      one or more domains

optional arguments:
  -h, --help   show this help message and exit
  -a           After recon, run AltDNS? (this requires alt-dns)
  -i IN_FILE   input file of domains (one per line)
  -o OUT_FILE  output file for recon-ng results. if none specified, results not exported.
  -w WORDLIST  wordlist file for subdomain brute forcing. if none specified defaults to $RECON_HOME/data/hostnames.txt
  -p PERMLIST  input file of permutations for alt-dns. if none specified will use default list.

```

## Docker
```
docker build . -t domain:enumall
docker run -v ${PWD}:/out domain:enumall [-h]
```
