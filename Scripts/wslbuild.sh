#!/bin/bash
#
# wslbuild.sh
# ONScripter-RU
#
# Cross-compiles the Windows engine from WSL (or any Linux host) without
# touching the Windows working tree, which usually has CRLF line endings
# and a non-ASCII path that old autotools scripts dislike.
#
# The script clones the Windows repository into a native Linux directory,
# applies the uncommitted changes, then runs configure and make there.
#
# Prerequisites on Ubuntu 22.04 (install once):
#   sudo apt-get install gcc-mingw-w64-x86-64 g++-mingw-w64-x86-64 \
#     gcc-mingw-w64-i686 g++-mingw-w64-i686 yasm nasm autoconf automake \
#     libtool pkg-config cmake python3-pip python-is-python3 zip unzip
#   pip3 install meson ninja
#
# Run from Windows (Git Bash or PowerShell) in the repository root:
#   git diff HEAD --binary > DerivedData/wsl.patch
#   wsl -d Ubuntu -- bash Scripts/wslbuild.sh [arch] [configure options...]
#
# arch is x86_64 (default) or i686. Further arguments go to configure,
# for example --release-build --strip-binary --with-discord.
#
# Output goes to DerivedData/MinGW-dist:
#   onscripter-ru_x64.exe  discord_game_sdk_x64.dll   (x86_64)
#   onscripter-ru_x86.exe  discord_game_sdk_x86.dll   (i686)
#

set -euo pipefail

SRC=$(cd "$(dirname "$0")/.." && pwd)
ARCH=${1:-x86_64}
if [ $# -gt 0 ]; then
    shift
fi
case "$ARCH" in
    x86_64) SUFFIX=x64 ;;
    i686)   SUFFIX=x86 ;;
    *) echo "Unsupported arch '$ARCH', use x86_64 or i686" >&2; exit 1 ;;
esac
TRIPLE="${ARCH}-w64-mingw32"
DST="${WSLBUILD_DIR:-$HOME/build/onscripter-ru-w}"
PATCH="$SRC/DerivedData/wsl.patch"

if [ ! -d "$DST/.git" ]; then
    git clone -q "$SRC" "$DST"
fi

cd "$DST"
git fetch -q "$SRC" HEAD
git reset -q --hard FETCH_HEAD
git clean -qfd -e DerivedData -e ciout
if [ -s "$PATCH" ]; then
    git apply --whitespace=nowarn "$PATCH"
fi
echo "Synced $(git rev-parse --short HEAD) plus local changes"

export CC="${TRIPLE}-gcc"
export CXX="${TRIPLE}-g++"
export LD="${TRIPLE}-ld"
export AR="${TRIPLE}-ar"
export RANLIB="${TRIPLE}-ranlib"
export AS="${TRIPLE}-as"

./configure --cross="$TRIPLE" "$@"

# make only runs the dependency builder when this marker is missing, so a
# changed pkgver or pkgrel would go unnoticed. build.sh skips packages that are
# already up to date, so removing the marker is cheap.
rm -f "DerivedData/MinGW-${ARCH}/Dependencies/onscrlib/.pkgs/onscrlib"

make -j"$(nproc)"

# Both architectures go to one folder with suffixed names, so they can be
# copied side by side into a game directory.
OUT="$SRC/DerivedData/MinGW-dist"
mkdir -p "$OUT"
cp "DerivedData/MinGW-${ARCH}/onscripter-ru.exe" "$OUT/onscripter-ru_${SUFFIX}.exe"
echo "Copied engine to $OUT/onscripter-ru_${SUFFIX}.exe"

# Optional DLLs, laid out like the release zips: dlls/ for x86, dlls/x64/ for x64.
mkdir -p "$OUT/dlls"
if [ "$ARCH" == "x86_64" ]; then
    rm -rf "$OUT/dlls/x64"
    cp -r Resources/Windows/dlls/x64 "$OUT/dlls/x64"
else
    find Resources/Windows/dlls -mindepth 1 -maxdepth 1 ! -name x64 -exec cp -r {} "$OUT/dlls/" \;
fi

# Discord builds import discord_game_sdk_<suffix>.dll, which must sit next to the exe.
DISCORD_DLL="DerivedData/MinGW-${ARCH}/Dependencies/onscrlib/lib/discord_game_sdk_${SUFFIX}.dll"
if [[ " $* " == *" --with-discord "* ]]; then
    cp "$DISCORD_DLL" "$OUT/"
    echo "Copied discord_game_sdk_${SUFFIX}.dll to $OUT"
fi
