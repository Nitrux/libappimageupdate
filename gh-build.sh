#! /bin/bash

set -xe

### Basic packages

DEBIAN_FRONTEND=noninteractive apt -qq update
DEBIAN_FRONTEND=noninteractive apt -qq -yy install --no-install-recommends \
	ca-certificates \
	curl \
	gnupg2 \
	wget

### Update sources

wget -qO /etc/apt/sources.list.d/nitrux-main-compat-repo.list https://raw.githubusercontent.com/Nitrux/iso-tool/development/configs/files/sources.list.nitrux

wget -qO /etc/apt/sources.list.d/nitrux-testing-repo.list https://raw.githubusercontent.com/Nitrux/iso-tool/development/configs/files/sources.list.nitrux.testing

curl -L https://packagecloud.io/nitrux/repo/gpgkey | apt-key add -;
curl -L https://packagecloud.io/nitrux/compat/gpgkey | apt-key add -;
curl -L https://packagecloud.io/nitrux/testing/gpgkey | apt-key add -;

DEBIAN_FRONTEND=noninteractive apt -qq update

#	Upgrade dpkg for zstd support.

DEBIAN_FRONTEND=noninteractive apt -qq -yy install --only-upgrade --allow-downgrades \
	dpkg=1.20.9ubuntu2 \
	libc-bin=2.33-0ubuntu5 \
	libc6=2.33-0ubuntu5 \
	locales=2.33-0ubuntu5

### Upgrade Glib

DEBIAN_FRONTEND=noninteractive apt -qq -yy install --only-upgrade \
	libc6

### Install Package Build Dependencies #1

DEBIAN_FRONTEND=noninteractive apt -qq -yy install --no-install-recommends \
	automake \
	checkinstall \
	cmake \
	g++ \
	git \
	libtool \
	pkg-config \
	python3-dev

### Install Package Build Dependencies #2

DEBIAN_FRONTEND=noninteractive apt -qq -yy install --no-install-recommends --allow-downgrades \
	argagg-dev \
	desktop-file-utils \
	gir1.2-freedesktop/trixie \
	gir1.2-glib-2.0/trixie \
	libcairo2-dev \
	libcurl4-nss-dev \
	libfuse-dev \
	libgcrypt20-dev \
	libgirepository-1.0-1/trixie \
	libglib2.0-0/trixie \
	libglib2.0-bin/trixie \
	libglib2.0-dev-bin/trixie \
	libglib2.0-dev/trixie \
	librsvg2-dev \
	libssh2-1-dev \
	libssl-dev \
	xxd \
	zlib1g-dev

### Clone repo.

git clone --single-branch --branch main https://github.com/AppImage/AppImageUpdate.git
git clone --single-branch --branch master https://github.com/AppImage/zsync2.git
git clone --single-branch --branch master https://github.com/arsenm/sanitizers-cmake.git
git clone --single-branch --branch master https://github.com/AppImage/libappimage.git
git clone --single-branch --branch master https://github.com/libcpr/cpr.git
git clone --single-branch --branch main https://github.com/google/googletest.git
git clone --single-branch --branch master https://github.com/Taywee/args.git

mv AppImageUpdate/ libappimageupdate/

cp -r zsync2/* libappimageupdate/lib/zsync2/
cp -r sanitizers-cmake/* libappimageupdate/lib/sanitizers-cmake/
cp -r libappimage/* libappimageupdate/lib/libappimage/

cp -r cpr/* libappimageupdate/lib/zsync2/lib/cpr
cp -r googletest/* libappimageupdate/lib/zsync2/lib/gtest
cp -r args/* libappimageupdate/lib/zsync2/lib/args

rm -rf zsync2/ sanitizers-cmake/ libappimage/ cpr/ googletest/

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

mkdir -p /usr/lib/cmake/AppImageUpdate

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
