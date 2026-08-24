#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
    cmake      \
    libvpx     \
    sdl2_mixer

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano libdecor-mini sdl2_image-mini

echo "Building Akhenaten..."
echo "---------------------------------------------------------------"
REPO="https://github.com/dalerank/Akhenaten"
if [ "${DEVEL_RELEASE-}" = 1 ]; then
    echo "Making nightly build of Akhenaten..."
    echo "---------------------------------------------------------------"
    VERSION="$(git ls-remote "$REPO" HEAD | cut -c 1-9 | head -1)"
    git clone "$REPO" ./Akhenaten
else
    echo "Making stable build of Akhenaten..."
    echo "---------------------------------------------------------------"
    VERSION=$(git ls-remote --tags --refs --sort='v:refname' "$REPO" "refs/tags/ra*" | tail -n1 | cut -d/ -f3)
    git clone --branch "$VERSION" --single-branch "$REPO" ./Akhenaten
fi
echo "$VERSION" > ~/version

mkdir -p ./AppDir/bin
cd ./Akhenaten
cp -r data mods ../AppDir/bin
cp res/akhenaten.desktop ../AppDir
mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
mv -v akhenaten ../../AppDir/bin
