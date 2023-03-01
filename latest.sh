#!/usr/bin/env bash

set -e
set -o pipefail

if [ "$#" -eq 0 ]; then
  echo "Usage: $0 [PROJECT]"
  exit 1
fi

REPO="sirekanian/$1"
OUTPUT="$1-latest.apk"

rm -f "$OUTPUT"

case "$1" in
  spacetime) url="https://github.com/sirekanian/$1/releases/download/v0.8.2/com.sirekanian.$1-0.8.2-22-release.apk" ;;
  warmongr) url="https://github.com/sirekanian/$1/releases/download/v0.5.15/com.sirekanian.$1-0.5.15-30-release.apk" ;;
  *) exit 1 ;;
esac

wget "$url" -q --show-progress -O "$OUTPUT"

exit # todo remove

wget -qO- "https://api.github.com/repos/$REPO/releases/latest" |
  jq -r '.["assets"][]["browser_download_url"]' |
  grep "\.apk$" |
  xargs wget -q --show-progress -O "$OUTPUT"

exit $(test -f "$OUTPUT")
