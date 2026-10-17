#!/usr/bin/env bash
# Installs the APK on the emulator, launches it, taps through onboarding and
# records screenshots + logcat into ci_out/. Fails if the app process dies.
set -x
# Every adb call is time-limited so a frozen emulator can never hang the job.
A() { timeout 60 adb "$@"; }
PKG=com.voicebeast.arena
OUT=ci_out
mkdir -p $OUT
timeout 300 adb wait-for-device
A shell wm size > $OUT/screen_size.txt
timeout 240 adb install -r -g VoiceBeastArena.apk 2>&1 | tee $OUT/install.txt
A logcat -c
A shell monkey -p $PKG -c android.intent.category.LAUNCHER 1
sleep 25
A exec-out screencap -p > $OUT/01_launch.png
SIZE=$(A shell wm size | grep -oE '[0-9]+x[0-9]+' | tail -1)
W=${SIZE%x*}; H=${SIZE#*x}
X=$((W / 2)); Y=$((H * 93 / 100))
for i in 1 2 3; do
  A shell input tap $X $Y   # "Next"
  sleep 3
done
A exec-out screencap -p > $OUT/02_onboarding_last.png
A shell input tap $X $Y     # "Let's Roar!"
sleep 5
A exec-out screencap -p > $OUT/03_summon.png
A shell input tap $X $((H * 46 / 100))   # big mic button
sleep 6
A exec-out screencap -p > $OUT/04_after_mic.png
PID=$(A shell pidof $PKG | tr -d '\r')
echo "PID=$PID" | tee $OUT/result.txt
A logcat -d > $OUT/logcat_full.txt
grep -E "AndroidRuntime|FATAL|flutter|DartVM|Exception|Error|libc|DEBUG" $OUT/logcat_full.txt | grep -vE "chatty|GoogleApiManager|Finsky" | head -400 > $OUT/logcat_errors.txt
if [ -z "$PID" ]; then echo "APP NOT RUNNING" | tee -a $OUT/result.txt; exit 1; fi
if grep -q "FATAL EXCEPTION" $OUT/logcat_full.txt; then echo "FATAL EXCEPTION FOUND" | tee -a $OUT/result.txt; exit 1; fi
echo "APP RUNNING OK" | tee -a $OUT/result.txt
