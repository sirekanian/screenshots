#!/usr/bin/env bash

set -e

if [ "$#" -ne 1 ] || [ ! -f "$1" ]; then
  echo "Usage: $0 FILE"
  exit 1
fi

if [ "${1##*.}" != "apk" ]; then
  echo "[ERROR] Not an apk file: $1"
  echo "Usage: $0 FILE"
  exit 1
fi

INPUT="$1"
PROJECT="${INPUT%%-*}"
mkdir -p "$PROJECT"

if [ -z "$PROJECT" ]; then
  echo "[ERROR] Project name is not specified"
  echo "Usage: $0 FILE"
  exit 1
fi

PACKAGE="com.sirekanian.$PROJECT"
counter=0

setup() {
  ./setup.sh "$1"
  adb uninstall "$PACKAGE" || true
  adb install "$INPUT"
  adb install "clipboard.apk"
  adb shell am start -n "$PACKAGE/.MainActivity"
  adb shell am broadcast -n com.sirekanian.clipboard/.MainBroadcast -e "text" "путин"
  sleep 30
}

screenshot() {
  counter=$((counter + 1))
  adb exec-out screencap -p | convert - -resize 300x "$PROJECT/$counter.png"
}

swipe() {
  case "$1" in
    slightly) swipe="500 500 400 500 50" ;;
    right) swipe="500 500 100 500 50" ;;
    *) swipe="100 500 500 500 50" ;;
  esac
  adb shell input swipe "$swipe"
  sleep 3
}

tap() {
  case "$1" in
    search) tap="540 1900" ;;
    tag) tap="300 300" ;;
    *) tap="540 1110" ;;
  esac
  adb shell input tap "$tap"
  sleep 3
}

keycode() {
  adb shell input keyevent "KEYCODE_$1"
}

case "$PROJECT" in
  spacetime)
    setup light
    swipe slightly && screenshot
    swipe right && screenshot
    swipe right && screenshot
    swipe right && sleep 10 && screenshot
    ;;
  warmongr)
    for i in light dark; do
      setup "$i"
      screenshot && tap tag
      screenshot && tap tag
      tap search
      keycode PASTE
      keycode BACK
      keycode SPACE
      sleep 3
      keycode SPACE
      keycode DEL
      screenshot
    done
    ;;
  *)
    screenshot
    ;;
esac

play() {
  alt="Get it on Google Play"
  href="https://play.google.com/store/apps/details?id=$1"
  src="https://play.google.com/intl/en_us/badges/images/generic/en_badge_web_generic.png"
  echo "<a href='$href'><img height='100' alt='$alt' src='$src'/></a>"
}

{
  echo "# $PROJECT" && echo
  for i in $(seq 1 "$counter"); do
    echo "<picture><img src='$i.png'></picture>"
  done
  echo && play "$PACKAGE"
} >"$PROJECT/README.md"
