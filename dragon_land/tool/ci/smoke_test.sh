#!/usr/bin/env bash
# Installs the APK on the running emulator, launches it, and verifies the app
# is still alive and has not crashed. Writes logcat + a screenshot to ci-out/.
set -u
APK="$1"
PKG=com.moixlimited.dragonland
mkdir -p ci-out
adb wait-for-device
adb shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 1; done'
adb install -r "$APK" | tee ci-out/install.txt
adb logcat -c
adb shell am start -W -n $PKG/.MainActivity | tee ci-out/start.txt
sleep 30
adb shell screencap -p /sdcard/shot1.png; adb pull /sdcard/shot1.png ci-out/after_30s.png
# tap the PLAY area (bottom-right) to start gameplay and let it run
SIZE=$(adb shell wm size | grep -o '[0-9]*x[0-9]*' | tail -1)
W=${SIZE%x*}; H=${SIZE#*x}
if [ "$W" -lt "$H" ]; then T=$W; W=$H; H=$T; fi
adb shell input tap $((W * 86 / 100)) $((H * 85 / 100))
sleep 20
adb shell screencap -p /sdcard/shot2.png; adb pull /sdcard/shot2.png ci-out/gameplay.png
adb logcat -d > ci-out/logcat.txt
PID=$(adb shell pidof $PKG | tr -d '\r')
echo "pid=$PID"
grep -n -A40 "FATAL EXCEPTION\|Fatal signal\|E/flutter" ci-out/logcat.txt | head -200 || true
if [ -z "$PID" ] || grep -q "FATAL EXCEPTION" ci-out/logcat.txt || grep -q "Fatal signal" ci-out/logcat.txt; then
  echo "SMOKE TEST FAILED: app crashed or is not running"
  grep -n "AndroidRuntime\|DEBUG   :\|libc    :" ci-out/logcat.txt | head -120 || true
  exit 1
fi
echo "SMOKE TEST PASSED: app is running"
