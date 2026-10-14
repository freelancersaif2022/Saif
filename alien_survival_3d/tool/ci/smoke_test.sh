#!/usr/bin/env bash
# Installs the APK on a running emulator with the real package manager, launches
# it, taps PLAY then DEPLOY to start the 3D game, and checks the app is alive.
# Writes install output, screenshots and logcat to ci-out/.
set -u
APK="$1"
PKG=com.alienforest.alien_survival_3d
mkdir -p ci-out
adb wait-for-device
adb shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 1; done'
adb install -r "$APK" 2>&1 | tee ci-out/install.txt
if ! grep -q "Success" ci-out/install.txt; then echo "INSTALL FAILED"; exit 1; fi
adb shell dumpsys package $PKG | grep -E "versionName|versionCode|signatures" | tee -a ci-out/install.txt
adb logcat -c
adb shell am start -W -n $PKG/.MainActivity | tee ci-out/start.txt
sleep 25
adb shell screencap -p /sdcard/s1.png; adb pull /sdcard/s1.png ci-out/1_menu.png
SIZE=$(adb shell wm size | grep -o '[0-9]*x[0-9]*' | tail -1)
W=${SIZE%x*}; H=${SIZE#*x}
if [ "$W" -lt "$H" ]; then T=$W; W=$H; H=$T; fi
adb shell input tap $((W * 85 / 100)) $((H * 35 / 100))   # PLAY
sleep 6
adb shell screencap -p /sdcard/s2.png; adb pull /sdcard/s2.png ci-out/2_loadout.png
adb shell input tap $((W * 87 / 100)) $((H * 91 / 100))   # DEPLOY
sleep 60
adb shell screencap -p /sdcard/s3.png; adb pull /sdcard/s3.png ci-out/3_game.png
adb logcat -d > ci-out/logcat.txt
grep -i "chromium\|CONSOLE" ci-out/logcat.txt | tail -60 > ci-out/webview_console.txt || true
PID=$(adb shell pidof $PKG | tr -d '\r')
echo "pid=$PID"
grep -n -A40 "FATAL EXCEPTION\|Fatal signal" ci-out/logcat.txt | head -200 || true
if [ -z "$PID" ] || grep -q "FATAL EXCEPTION" ci-out/logcat.txt || grep -q "Fatal signal" ci-out/logcat.txt; then
  echo "SMOKE TEST FAILED: app crashed or is not running"
  exit 1
fi
echo "SMOKE TEST PASSED: installed, launched and still running"
