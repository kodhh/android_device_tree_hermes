#!/bin/sh
#
# install3.sh — Re-apply hardware/interfaces patches (incl. the GNSS fix)
#
# What it does:
#   1. Reset every file that the hardware/interfaces patches touch back
#      to HEAD (removes previously applied patch content)
#   2. Re-apply ALL hardware/interfaces patches in order via git apply
#
# The GNSS patch fixes a system_server soft-reboot caused by the MTK
# gps.mt6795.so HAL passing an NMEA length that may include or exclude the
# trailing NUL terminator (buffer not reliably NUL-terminated): Android 10's
# hidl_string::setToExternal() enforces CHECK(data[size]=='\0') and aborts in
# Gnss::nmeaCb. The sentence is copied into a NUL-terminated local buffer and
# passed with the reported length.
#
# Usage:
#   cd <ANDROID_ROOT>
#   bash device/xiaomi/hermes/patches/install3.sh
#
# Simulate (print what would be done, no changes):
#   bash device/xiaomi/hermes/patches/install3.sh --simulate
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ANDROID_ROOT="${PWD}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()   { echo -e "${RED}[ERR]${NC} $1"; }

SIMULATE=0
[ "$1" = "--simulate" ] && SIMULATE=1

MODULE="hardware/interfaces"

info "===== install3.sh: reset + re-apply $MODULE patches ====="
echo ""

AV="$ANDROID_ROOT/$MODULE"
if [ ! -d "$AV" ]; then
    err "Directory not found: $AV"
    err "Run install.sh first (or clone LineageOS 17.1 source)"
    exit 1
fi

cd "$AV"

# ---------------------------------------------------------
# 1. Reset every file modified by any $MODULE patch to HEAD,
#    and delete every file created by a patch (--- /dev/null).
# ---------------------------------------------------------
info "Resetting files touched by $MODULE patches ..."

FILES=""
for patch in "$SCRIPT_DIR/$MODULE/"*.patch; do
    [ -f "$patch" ] || continue

    # collect modified files
    while IFS= read -r line; do
        case "$line" in
            '--- a/'*)
                f="${line#--- a/}"
                FILES="$FILES $f"
                ;;
        esac
    done < "$patch"

    # delete files the patch creates
    old=""
    while IFS= read -r line; do
        case "$line" in
            '--- /dev/null') old="/dev/null" ;;
            '+++ b/'*)
                f="${line#+++ b/}"
                [ "$old" = "/dev/null" ] && { [ $SIMULATE -eq 1 ] && echo "  rm -f $f" || rm -f "$f" 2>/dev/null || true; }
                old=""
                ;;
        esac
    done < "$patch"
done

for f in $FILES; do
    [ $SIMULATE -eq 1 ] && { echo "  git checkout -- $f"; continue; }
    [ -f "$f" ] && git checkout -- "$f" 2>/dev/null || true
done

# ---------------------------------------------------------
# 2. Re-apply ALL $MODULE patches in order via git apply.
# ---------------------------------------------------------
info "Re-applying patches ..."
for patch in $(ls "$SCRIPT_DIR/$MODULE/"*.patch | sort); do
    name="$(basename "$patch")"
    if [ $SIMULATE -eq 1 ]; then
        echo "  git apply $name"
        continue
    fi
    if git apply "$patch" 2>/dev/null; then
        echo "  $name"
    else
        err "FAILED: $name (git apply)"
        exit 1
    fi
done

echo ""
info "Done. $MODULE patches re-applied."
