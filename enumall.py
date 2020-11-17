#!/usr/bin/env python3
# enumall
#   Authored by: @jhaddix and @leifdreizler
#   Updated 2020-11: @bynx
from recon.core import base
from multiprocessing import Pool
import argparse
import datetime
import os
import sys

def run_altdns(domains):
    """Run altDNS with the given args."""

    altCmd = "altdns"
    subdomains = "altdns.in.tmp"
    permList = "words.txt"
    output = "altdns.out"

    with open(subdomains,"w") as f:
        for domain in domains:
            f.write(domain)

    print("[+] Running alt-dns...")
    # python altdns.py -i subdomainsList -o data_output -w permutationsList -r -s results_output.txt
    os.system(f"{altCmd} -i {subdomains} -o data_output -w {permList} -r -s {output}")
    return

def install_modules(reconBase, modules):
    """Install required modules via recon-ng marketplace."""
    for module in modules:
        reconBase._do_marketplace_install(module)
    return

def run_module(reconBase, module, domain):
    """Run the passed module with options set."""
    try:
        m = reconBase._do_modules_load(module)
        m.options['source'] = domain
        m.do_run(None)
    except Exception as e:
        print(f"[-] Exception hit: {e}")
        raise
    return

def run_recon(domains, bf_wordlist, is_altdns_set, out_file):
    """Initialize recon-ng base class and run core of script."""
    stamp = datetime.datetime.now().strftime('%M:%H-%m_%d_%Y')
    wspace = domains[0]+stamp

    reconb = base.Recon(base.Mode.CLI)
    reconb.start(base.Mode.CLI)
    reconb._init_workspace(wspace)

    report_module = "reporting/list"
    bf_module = "recon/domains-hosts/brute_hosts"
    module_list = ["recon/hosts-hosts/resolve", "recon/domains-hosts/bing_domain_web", "recon/domains-hosts/google_site_web",
                   "recon/domains-hosts/shodan_hostname", "recon/netblocks-companies/whois_orgs", "recon/domains-hosts/netcraft"]
    install_modules(reconb, module_list + [f"{bf_module}",f"{report_module}"])

    pool = Pool()
    procs = []
    for domain in domains:
        for module in module_list:
            p = pool.apply_async(run_module, args=(reconb, module, domain))
            procs.append(p)

        # subdomain bruteforcing if wordlist set
        m = reconb._do_modules_load(bf_module)
        m.options['wordlist'] = bf_wordlist
        m.options['source'] = domain
        m.do_run(None)

        # Export results if output file given
        if out_file:
            m = reconb._do_modules_load(report_module)
            m.options['filename'] = out_file
            m.options['column'] = "host"
            m.do_run(None)

    if is_altdns_set:
        run_altdns(domains)
    return

def main(argv):
    domains = argv.domains
    if argv.in_file:
        try:
            with argv.in_file as f:
                domains += f.read()
        except Exception as e:
            print(f"[-] Exception hit: {e}")

    if not domains:
        print("[-] No domain passed. Exiting...")
        sys.exit(1)
    run_recon(domains, argv.wordlist, argv.runAltDns, argv.out_file)
    return

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-a', dest='runAltDns', action='store_true',
                         help="After recon, run AltDNS? (this requires alt-dns)")

    parser.add_argument("-i", dest="in_file", type=argparse.FileType('r'),
                         help="input file of domains (one per line)", default=None)

    parser.add_argument("-o", dest="out_file", type=str,
                         help="output file for recon-ng results. if none specified, results not exported.", default=None)

    parser.add_argument("domains", help="one or more domains", nargs="*", default=None)

    parser.add_argument("-w", dest="wordlist", type=str,
                         help="wordlist file for subdomain brute forcing. if none specified defaults to $RECON_HOME/data/hostnames.txt",
                         default="words.txt")

    parser.add_argument("-p", dest="permlist", type=argparse.FileType('r'),
                         help="input file of permutations for alt-dns. if none specified will use default list.", default=None)

    main(parser.parse_args())
