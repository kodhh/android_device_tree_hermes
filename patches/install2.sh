#!/bin/sh
#
# Re-apply the 0004 patch (dlopen libdpframework) to frameworks/av.
# First reverses the old 0004 if present, then applies the current version.
#
# Usage (from Android source root):
#   bash device/xiaomi/hermes/patches/install2.sh
#
# Usage (from frameworks/av):
#   bash /path/to/patches/install2.sh
#

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PATCH="$SCRIPT_DIR/frameworks/av/0004-Add-support-of-YUV-color-profiles.patch"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

if [ ! -f "$PATCH" ]; then
    echo -e "${RED}Patch not found: $PATCH${NC}"
    exit 1
fi

# Detect: are we inside frameworks/av or at the source root?
if [ -f "media/libstagefright/ACodec.cpp" ] && [ -f "media/libstagefright/colorconversion/ColorConverter.cpp" ]; then
    AV_ROOT="$PWD"
elif [ -f "frameworks/av/media/libstagefright/ACodec.cpp" ] && [ -f "frameworks/av/media/libstagefright/colorconversion/ColorConverter.cpp" ]; then
    AV_ROOT="$PWD/frameworks/av"
else
    echo -e "${RED}Cannot find frameworks/av (run from source root or from frameworks/av)${NC}"
    exit 1
fi

cd "$AV_ROOT" || exit 1

echo -e "${RED}Step 1: Reverse old 0004 patch (if applied)${NC}"
git apply -R "$PATCH" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "  Old patch reversed."
else
    echo "  No previous patch to reverse (or it was a different version)."
fi

# Clean up new files from old patch versions (in case -R didn't remove them)
NEW_FILES=$(grep '^--- /dev/null' -A1 "$PATCH" | grep '^+++ b/' | sed 's|+++ b/||')
for f in $NEW_FILES; do
    if [ -f "$f" ]; then
        rm -f "$f"
        echo "  removed: $f"
    fi
done

echo ""
echo -e "${RED}Step 2: Apply 0004 patch${NC}"
git apply -v "$PATCH" 2>&1
if [ $? -ne 0 ]; then
    echo -e "${RED}git apply failed, falling back to patch -p1${NC}"
    patch -p1 -r - --force < "$PATCH"
    if [ $? -ne 0 ]; then
        echo -e "${RED}FAILED: $PATCH${NC}"
        exit 1
    fi
fi

echo ""
echo -e "${GREEN}Done! 0004 patch re-applied.${NC}"
