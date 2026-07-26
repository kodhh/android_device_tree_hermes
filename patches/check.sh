#!/bin/sh

rootdirectory="$PWD"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

dirs="bionic frameworks/av frameworks/base frameworks/native frameworks/opt/telephony hardware/interfaces packages/apps/FMRadio system/core system/netd"

RED='\033[0;31m'
NC='\033[0m'

for dir in $dirs ; do
	if [ ! -d "$rootdirectory/$dir" ]; then
		echo -e "\n${RED}Skipping ${NC}$dir ${RED}(directory not found)${NC}\n"
		continue
	fi
	cd $rootdirectory/$dir
	echo -e "${RED}Applying ${NC}$dir ${RED}patches...${NC}\n"
	for patch in $(ls "$SCRIPT_DIR/$dir/"*.patch 2>/dev/null | sort); do
		git apply "$patch" 2>&1
		if [ $? -ne 0 ]; then
			echo -e "${RED}FAILED:${NC} $patch"
			exit 1
		fi
		echo "  OK: $(basename $patch)"
	done
	git checkout -- . 2>/dev/null
	git clean -fd 2>/dev/null
done

# -----------------------------------
echo -e "Done !\n"
cd $rootdirectory

