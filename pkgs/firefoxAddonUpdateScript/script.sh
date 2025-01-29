# shellcheck shell=bash

readonly AMO_API="https://addons.mozilla.org/api/v5"
readonly ADDON_ENDPOINT="/addons/addon"

attribute="${1:-}"
addon_ref="${2:-}"

usage() {
	echo "
usage: $0 <attribute> <addon_ref>
"
}

bail() {
	usage
	exit 1
}

if [[ -z $attribute ]] || [[ -z $addon_ref ]]; then
	bail
fi

data="$(curl -sSL "$AMO_API/$ADDON_ENDPOINT/$addon_ref")"

url="$(jq -r '.current_version.file.url' <<<"$data")"
version="$(jq -r '.current_version.version' <<<"$data")"

update-source-version "$attribute" "$version" "" "$url"
