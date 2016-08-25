#!/usr/bin/python

# enumall is a refactor of enumall.sh providing a script to identify subdomains using several techniques and tools.
# Relying heavily on the stellar Recon-NG framework and Alt-DNS, enumall will identify subdomains via search engine
# scraping (yahoo, google, bing, baidu), identify subdomains using common OSINT sites (shodan, netcraft), identify
# concatenated subdomains (altDNS), and brute-forces with a stellar subdomain list (formed from Bitquark's subdomain
# research, Seclists, Knock, Fierce, Recon-NG, and more) located here:
# https://github.com/danielmiessler/SecLists/blob/master/Discovery/DNS/sorted_knock_dnsrecon_fierce_recon-ng.txt
# 
# Alt-DNS Download: https://github.com/infosec-au/altdns
#
# by @jhaddix and @leifdreizler

import argparse
import re
import sys
import datetime
import time
import os
import sys

reconPath = "/usr/share/recon-ng/"
altDnsPath = "/root/Desktop/altdns-master/"

sys.path.insert(0,reconPath)
from recon.core import base
from recon.core.framework import Colors

if altDnsPath:
	sys.path.insert(1, altDnsPath)

def run_module(reconBase, module, domain):
    x = reconBase.do_load(module)
    x.do_set("SOURCE " + domain)
    x.do_run(None)


def run_recon(domains, bruteforce):
	stamp = datetime.datetime.now().strftime('%M:%H-%m_%d_%Y')
	wspace = domains[0]+stamp

	reconb = base.Recon(base.Mode.CLI)
	reconb.init_workspace(wspace)
	reconb.onecmd("TIMEOUT=100")
	module_list = ["recon/domains-hosts/bing_domain_web", "recon/domains-hosts/google_site_web", "recon/domains-hosts/netcraft", "recon/domains-hosts/shodan_hostname", "recon/netblocks-companies/whois_orgs", "recon/hosts-hosts/resolve"]
	
	for domain in domains:
		for module in module_list:
	    		run_module(reconb, module, domain)
	
	#subdomain bruteforcing
	if bruteforce:
		x = reconb.do_load("recon/domains-hosts/brute_hosts")
		x.do_set("WORDLIST /usr/share/recon-ng/data/banner.txt")
		x.do_set("SOURCE bugcrowd.com")
		x.do_run(None)
	
	#reporting output
	outFile = "FILENAME "+os.getcwd()+"/"+domains[0]
	x = reconb.do_load("reporting/csv")
	x.do_set(outFile+".csv")
	x.do_run(None)

	x = reconb.do_load("reporting/list")
	x.do_set(outFile+".lst")
	x.do_set("COLUMN host")
	x.do_run(None)

parser = argparse.ArgumentParser()
parser.add_argument('-a', dest='runAltDns', action='store_true', help="After recon, run AltDNS? (this requires alt-dns)")
parser.add_argument("-i", dest="filename", type=argparse.FileType('r'), help="input file of domains (one per line)", default=None)
parser.add_argument("domains", help="one or more domains", nargs="*", default=None)
parser.add_argument("-w", dest="wordlist", type=argparse.FileType('r'), help="input file of subdomain wordlist. must be in same directory as this file, or give full path", default=None)
parser.add_argument("-p", dest="permlist", type=argparse.FileType('r'), help="input file of permutations for alt-dns. if none specified will use default list.", default=None)
args = parser.parse_args()

if args.runAltDns and not altDnsPath:
	print "Error: no altDns path specified, please download from: https://github.com/infosec-au/altdns"
	exit(0)

domainList = []

if args.domains:
	domainList+=args.domains

if args.filename:
	lines = args.filename.readlines()
	lines = [line.rstrip('\n') for line in lines]
	domainList+=lines

bruteforceList = args.wordlist.name if args.wordlist else ""	

run_recon(domainList, bruteforceList)

if args.runAltDns:
	workspace = domainList[0]
	altCmd="python "+os.path.join(altDnsPath,"altdns.py")
	subdomains = os.path.join(os.getcwd(), workspace+".lst")
	permList = args.permlist.name if args.permlist else os.path.join(altDnsPath,"words.txt")
	output = os.path.join(os.getcwd(),workspace+"_output.txt")
	print "running alt-dns... please be patient :) results will be displayed in "+output
	# python altdns.py -i subdomainsList -o data_output -w permutationsList -r -s results_output.txt
	os.system('%s -i %s -o data_output -w %s -r -s %s' % (altCmd, subdomains, permList,output))
