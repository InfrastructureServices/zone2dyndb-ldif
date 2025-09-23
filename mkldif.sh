#!/bin/sh
#
INPUT=${1:-DEFAULT/fedoraproject.org}
: ${LDAP_SUFFIX:="cn=dns, dc=ipa, dc=test"}

ldap_name() {
	echo $1 | sed -e 's/^/dc=/' -e 's/\./,dc=/g'
}

make_ldif() {
	local ZONEFILE="${1}"
	local ZONE=${2:-$(basename "$ZONEFILE")}
#	local LDAP_BASE="$(ldap_name $ZONE), ${LDAP_SUFFIX}"
	local LDAP_BASE="${LDAP_SUFFIX}"

	echo "# $ZONE from $ZONEFILE"
	python3 ./zone2dyndb-ldif.py $ZONEFILE $ZONE "${LDAP_BASE}" > "$ZONEFILE.ldif"
}

make_dnsperf() {
	local ZONEFILE="${1}"
	local ZONE=${2:-$(basename "$ZONEFILE")}
	local TMPZONE="$(mktemp --tmpdir XXXXXXXX.zone)"
	local PERFFILE="$ZONEFILE.dnsperf"

	named-compilezone -s full -o "$TMPZONE" "$ZONE" "$ZONEFILE"
	awk '{print $1, $4}' "$TMPZONE" | uniq > "$PERFFILE"
	rm -f "$TMPZONE"
}

make_dir() {
	local INPUT="$1"
	for FILE in $(ls -1 "$INPUT"/* | grep -vE '\.(ldif|signed|dnsperf)'); do
		if [ -f "$FILE" ]; then
			make_ldif "$FILE"
			make_dnsperf "$FILE"
		fi
	done
}

if [ -d "$INPUT" ]; then
	make_dir "$INPUT"
	sort --random-sort "$INPUT"/*.dnsperf > $INPUT.dnsperf
else
	[ $# -gt 1 ] && shift
	make_ldif "$INPUT" "$@"
	make_dnsperf "$FILE" "$@"
fi
