#!/bin/bash

set -x

### Update Sources

DEBIAN_FRONTEND=noninteractive apt -qq update

### Install Build Tools #1

DEBIAN_FRONTEND=noninteractive apt -qq -yy install --no-install-recommends \
	 git \
	 cmake \
	 checkinstall \
	 g++

### Install Package Build Dependencies #2

DEBIAN_FRONTEND=noninteractive apt -qq -yy install --no-install-recommends \
	zlib1g-dev \
	argagg-dev

### Clone repo.

git clone --single-branch --branch main https://github.com/AppImage/AppImageUpdate.git
git submodule update --init --recursive

mv AppImageUpdate/ libappimageupdate/

ls -l libappimageupdate/

### Compile Source

mkdir -p libappimageupdate/build && cd libappimageupdate/build

cmake \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_SYSCONFDIR=/etc \
	-DCMAKE_INSTALL_LOCALSTATEDIR=/var \
	-DCMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY=ON \
	-DCMAKE_INSTALL_RUNSTATEDIR=/run "-GUnix Makefiles" \
	-DCMAKE_VERBOSE_MAKEFILE=ON \
	-DCMAKE_INSTALL_LIBDIR=lib/x86_64-linux-gnu ..

make -j$(nproc)

### Run checkinstall and Build Debian Package
### DO NOT USE debuild, screw it

>> description-pak printf "%s\n" \
	'AppImageUpdate lets you update AppImages.' \
	'' \
	'Update AppImage using information embedded in the AppImage itself.' \	
	'' \
	''

checkinstall -D -y \
	--install=no \
	--fstrans=yes \
	--pkgname=libappimageupdate \
	--pkgversion=2.0.0-alpha-1-20220124 \
	--pkgarch=amd64 \
	--pkgrelease="1" \
	--pkglicense=LGPL-3 \
	--pkggroup=libs \
	--pkgsource=libappimageupdate \
	--pakdir=../.. \
	--maintainer=uri_herrera@nxos.org \
	--provides=libappimageupdate \
	--requires="libc6,zlib1g" \
	--nodoc \
	--strip=no \
	--stripso=yes \
	--reset-uids=yes \
	--deldesc=yes
