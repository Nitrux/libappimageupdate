#!/bin/bash

set -x

### Add Sources

wget -qO /etc/apt/sources.list.d/neon-user-repo.list https://raw.githubusercontent.com/Nitrux/iso-tool/development/configs/files/sources.list.neon.user

wget -qO /etc/apt/sources.list.d/nitrux-main-compat-repo.list https://raw.githubusercontent.com/Nitrux/iso-tool/development/configs/files/sources.list.nitrux

wget -qO /etc/apt/sources.list.d/nitrux-testing-repo.list https://raw.githubusercontent.com/Nitrux/iso-tool/development/configs/files/sources.list.nitrux.testing

DEBIAN_FRONTEND=noninteractive apt-key adv --keyserver keyserver.ubuntu.com --recv-keys \
	55751E5D > /dev/null

curl -L https://packagecloud.io/nitrux/repo/gpgkey | apt-key add -;
curl -L https://packagecloud.io/nitrux/compat/gpgkey | apt-key add -;
curl -L https://packagecloud.io/nitrux/testing/gpgkey | apt-key add -;

DEBIAN_FRONTEND=noninteractive apt -qq update

### Install Build Tools #1

DEBIAN_FRONTEND=noninteractive apt -qq -yy install --no-install-recommends \
	 git \
	 cmake \
	 checkinstall \
	 g++

### Install Package Build Dependencies #2

DEBIAN_FRONTEND=noninteractive apt -qq -yy install --no-install-recommends \
	argagg-dev \
	libcurl4-nss-dev \
	libgcrypt20-dev
	libssh2-1-dev \
	libssl-dev \
	zlib1g-dev

### Clone repo.

git clone --single-branch --branch main https://github.com/AppImage/AppImageUpdate.git
git clone --single-branch --branch master https://github.com/AppImage/zsync2.git
git clone --single-branch --branch master https://github.com/arsenm/sanitizers-cmake.git
git clone --single-branch --branch master https://github.com/AppImage/libappimage.git

mv AppImageUpdate/ libappimageupdate/

cp -r zsync2/* libappimageupdate/lib/zsync2/
cp -r sanitizers-cmake/* libappimageupdate/lib/sanitizers-cmake/
cp -r libappimage/* libappimageupdate/lib/libappimage/

rm -rf zsync2/ sanitizers-cmake/ libappimage/

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
