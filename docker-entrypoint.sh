#!/bin/bash

# launch the emulator
exec /opt/adk/tools/emulator -avd Android -no-boot-anim -no-snapshot-save -no-audio -no-window &

# Originally written by Ralf Kistner <ralf@embarkmobile.com>, but placed in the public domain
# https://raw.githubusercontent.com/travis-ci/travis-cookbooks/0f497eb71291b52a703143c5cd63a217c8766dc9/community-cookbooks/android-sdk/files/default/android-wait-for-emulator
set +e

bootanim=""
failcounter=0
timeout_in_sec=360

until [[ "$bootanim" =~ "stopped" ]]; do
  bootanim=`adb -e shell getprop init.svc.bootanim 2>&1 &`
  if [[ "$bootanim" =~ "device not found" || "$bootanim" =~ "device offline"
    || "$bootanim" =~ "running" ]]; then
    let "failcounter += 1"
    echo "Waiting for emulator to start"
    if [[ $failcounter -gt timeout_in_sec ]]; then
      echo "Timeout ($timeout_in_sec seconds) reached; failed to start emulator"
      exit 1
    fi
  fi
  sleep 1
done

# setup appium
while [ -z $udid ]; do
    udid=`adb devices | grep emulator | cut -f 1`
done

# http://appium.io/docs/en/writing-running-appium/server-args/
exec appium -p 4723 -bp 2251 --default-capabilities '{"udid":"'${udid}'"}' &
