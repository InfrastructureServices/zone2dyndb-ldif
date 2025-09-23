#!/bin/sh
#
INPUT=${1:-DEFAULT/fedoraproject.org}
: ${LDAP_SUFFIX:="dc=dns, dc=ipa, dc=test"}

ldap_name() {
	echo $1 | sed -e 's/^/dc=/' -e 's/\./,dc=/g'
}

make_ldif() {
	local ZONEFILE="${1}"
	local ZONE=${2:-$(basename "$ZONEFILE")}
	local LDAP_BASE="$(ldap_name $ZONE), ${LDAP_SUFFIX}"

	python3 ./zone2dyndb-ldif.py $ZONEFILE $ZONE "${LDAP_BASE}" > "$ZONEFILE.ldif"
}

make_dir() {
	local INPUT="$1"
	for FILE in $(ls -1 "$INPUT"/* | grep -vE '\.(ldif|signed)'); do
		[ -f "$FILE" ] && make_ldif "$FILE"
	done
}

if [ -d "$INPUT" ]; then
	make_dir "$INPUT"
else
	make_ldif "$@"
fi
