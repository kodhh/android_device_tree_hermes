export ANDROID_TOP=$(gettop)
export MKE2FS_CONFIG=$ANDROID_TOP/device/xiaomi/hermes/mke2fs.conf

# Pre-create real-mbt-bin-* symlinks for the Mediatek kernel build.
# The Python GCC wrapper checks os.path.islink(argv0):
#   - Symlink: resolves via the link target to find real-*
#   - Copy:    looks for real-<basename-of-argv0>
# The Soong kernel module copies the wrapper to mbt-bin-* (not a symlink),
# so it looks for real-mbt-bin-*. We pre-create those as symlinks to the
# actual real-* binaries so the fallback path succeeds.
AARCH64_BIN=$ANDROID_TOP/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin
ARM_BIN=$ANDROID_TOP/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/bin

if [ -d "$AARCH64_BIN" ]; then
  [ -f "$AARCH64_BIN/real-aarch64-linux-android-gcc" ] && ln -sf real-aarch64-linux-android-gcc "$AARCH64_BIN/real-mbt-bin-aarch64-linux-android-gcc"
  [ -f "$AARCH64_BIN/real-aarch64-linux-android-g++" ] && ln -sf real-aarch64-linux-android-g++ "$AARCH64_BIN/real-mbt-bin-aarch64-linux-android-g++"
fi

if [ -d "$ARM_BIN" ]; then
  [ -f "$ARM_BIN/real-arm-linux-androideabi-gcc" ] && ln -sf real-arm-linux-androideabi-gcc "$ARM_BIN/real-mbt-bin-arm-linux-androideabi-gcc"
  [ -f "$ARM_BIN/real-arm-linux-androideabi-g++" ] && ln -sf real-arm-linux-androideabi-g++ "$ARM_BIN/real-mbt-bin-arm-linux-androideabi-g++"
fi
