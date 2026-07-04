#!/bin/sh

rootdirectory="$PWD"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

dirs="frameworks/av frameworks/base frameworks/native frameworks/opt/telephony hardware/interfaces packages/apps/FMRadio system/core system/netd"

# red + nocolor
RED='\033[0;31m'
NC='\033[0m'

for dir in $dirs ; do
	if [ ! -d "$rootdirectory/$dir" ]; then
		echo -e "\n${RED}Skipping ${NC}$dir ${RED}(directory not found)${NC}\n"
		continue
	fi

	cd $rootdirectory/$dir
	echo -e "\n${RED}Applying ${NC}$dir${NC}\n"

	for patch in $(ls "$SCRIPT_DIR/$dir/"*.patch 2>/dev/null | sort); do
		name="$(basename $patch)"

		# Try git apply first (sequential, builds on previous patches)
		if git apply -v "$patch" 2>/dev/null; then
			echo "  $name"
		else
			# git apply failed → checkout files, then patch -p1
			echo "  $name (checkout + patch)"

			# Delete files the patch creates (--- /dev/null)
			old=""
			while IFS= read -r line; do
				case "$line" in
					'--- /dev/null')  old="/dev/null"  ;;
					'+++ b/'*)
						[ "$old" = "/dev/null" ] && rm -f "${line#+++ b/}"
						old=""
						;;
				esac
			done < "$patch"

			# Checkout modified files to clean state
			while IFS= read -r line; do
				case "$line" in
					'--- a/'*)
						f="${line#--- a/}"
						[ -f "$f" ] && git checkout -- "$f" 2>/dev/null
						;;
				esac
			done < "$patch"

			patch -p1 -r - < "$patch"
			if [ $? -ne 0 ]; then
				echo -e "${RED}FAILED:${NC} $patch"
				exit 1
			fi
		fi
	done
done

# -----------------------------------
echo -e "\nDone !\n"
cd $rootdirectory
