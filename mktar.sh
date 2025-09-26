#!/bin/sh

if ! [ -d fedora-dns ]; then
	git clone --depth 1 https://infrastructure.fedoraproject.org/infra/dns.git/ fedora-dns
fi

sh mkldif.sh fedora-dns/built/DEFAULT
sh mkldif.sh fedora-dns/master
tar czf fedora-ldif.tar.gz fedora-dns/{built/DEFAULT,master}/*.{ldif,dnsperf}
