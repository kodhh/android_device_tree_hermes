#!/bin/sh

rootdirectory="$PWD"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

RED='\033[0;31m'
NC='\033[0m'

# Revert the obsolete libsuspend earlysuspend patch.
# On Android 10 the SystemSuspend service replaced libsuspend, so the
# libsuspend earlysuspend patch is dead code and its changes are dropped here.
if [ -d "$rootdirectory/system/core" ]; then
	cd "$rootdirectory/system/core"
	echo -e "\n${RED}Reverting${NC} libsuspend earlysuspend changes"

	git checkout -- libsuspend/Android.bp libsuspend/autosuspend.c libsuspend/autosuspend_ops.h
	rm -f libsuspend/autosuspend_earlysuspend.cpp

	echo -e "  system/core/libsuspend reverted to clean state\n"
else
	echo -e "\n${RED}Skipping system/core (directory not found)${NC}\n"
fi

# Apply the suspend fix: write "on" to /sys/power/state on display wake.
if [ -d "$rootdirectory/frameworks/base" ]; then
	cd "$rootdirectory/frameworks/base"

	patch="$SCRIPT_DIR/frameworks/base/0005-PowerManagerService-JNI-write-on-on-wake.patch"

	# Try git apply first
	if git apply -v "$patch" 2>/dev/null; then
		echo -e "${RED}Applied${NC} $(basename "$patch")"
	else
		# git apply failed -> checkout file, then patch -p1
		echo -e "${RED}Applied${NC} $(basename "$patch") (checkout + patch)"
		git checkout -- services/core/jni/com_android_server_power_PowerManagerService.cpp
		patch -p1 -r - < "$patch"
		if [ $? -ne 0 ]; then
			echo -e "${RED}FAILED:${NC} $patch"
			exit 1
		fi
	fi
else
	echo -e "\n${RED}Skipping frameworks/base (directory not found)${NC}\n"
fi
