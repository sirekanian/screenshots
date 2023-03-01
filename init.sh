#!/usr/bin/env bash

set -e

export ANDROID_HOME=".AndroidSdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"

mkdir -p "$ANDROID_HOME"

case "$(uname -s)" in
  Linux*) machine=linux ;;
  *) machine=mac ;;
esac

filename="commandlinetools-$machine-9477386_latest.zip"
if [ ! -f "$filename" ]; then
  wget "https://dl.google.com/android/repository/$filename"
fi

TOOLS="$ANDROID_HOME/cmdline-tools/latest"
if [ ! -d "$TOOLS" ]; then
  unzip -oq "$filename"
  mkdir -p "$ANDROID_HOME/cmdline-tools"
  mv "cmdline-tools" "$TOOLS"
fi

SDKM="$TOOLS/bin/sdkmanager"
AVDM="$TOOLS/bin/avdmanager"

yes | $SDKM --licenses

PACKAGE="system-images;android-31;default;x86_64"
$SDKM "platform-tools" "platforms;android-31"
$SDKM "$PACKAGE"

killall "qemu-system-x86_64" "qemu-system-x86_64-headless" || true

NAME="MyPixel3a"
$AVDM create avd -f -n "$NAME" -b "default/x86_64" -k "$PACKAGE" -d pixel_3a

EMU="$ANDROID_HOME/emulator/emulator -no-audio -no-snapshot -gpu swiftshader_indirect -no-boot-anim"

if [ "$1" != "window" ]; then
  EMU="$EMU -no-window"
fi

echo "Waiting for a device..."
grep -q 'Boot completed' <($EMU -avd "$NAME")
echo "Boot completed!"
