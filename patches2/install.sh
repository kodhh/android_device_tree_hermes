#!/bin/sh

rootdirectory="$PWD"
P2="$rootdirectory/device/xiaomi/hermes/patches2"

echo "==> patches2/install.sh"

for dir in frameworks/av system/netd; do
  patchdir="$P2/$dir"
  [ -d "$patchdir" ] || continue

  target="$rootdirectory/$dir"
  cd "$target" || continue

  for patch in "$patchdir"/*.patch; do
    [ -f "$patch" ] || continue
    name="$(basename $patch)"

    # Checkout files this patch touches, then apply
    files=$(grep '^--- a/' "$patch" | sed 's/^--- a\///')
    for f in $files; do
      if [ -f "$target/$f" ]; then
        git checkout -- "$f" 2>/dev/null
      fi
    done

    echo "  $name"
    patch -p1 < "$patch"
    if [ $? -ne 0 ]; then
      echo "  FAILED: $name"
      exit 1
    fi
  done
done

cd "$rootdirectory"
echo "==> Done"
