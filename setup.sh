#!/usr/bin/env bash

setup() {
  adb shell settings put global sysui_demo_allowed 1
  adb shell am broadcast -a com.android.systemui.demo -e command clock -e hhmm 1000
  adb shell am broadcast -a com.android.systemui.demo -e command network -e wifi show -e mobile hide -e level 4 -e datatype false
  adb shell am broadcast -a com.android.systemui.demo -e command notifications -e visible false
  adb shell am broadcast -a com.android.systemui.demo -e command battery -e plugged false -e level 100
  adb shell settings put system pointer_location 0
  adb shell settings put global window_animation_scale 0
  adb shell settings put global transition_animation_scale 0
  adb shell settings put global animator_duration_scale 0
  if [ "$1" = "dark" ]; then
    adb shell cmd uimode night yes
  fi
  sleep 10
}

setup "$1"
setup "$1"
