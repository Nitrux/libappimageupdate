#! /bin/bash

set -x

### Update sources

wget -qO /etc/apt/sources.list.d/nitrux.list https://raw.githubusercontent.com/Nitrux/iso-tool/development/configs/files/sources.list.nitrux

curl -L https://packagecloud.io/nitrux/repo/gpgkey | apt-key add -;
curl -L https://packagecloud.io/nitrux/compat/gpgkey | apt-key add -;

DEBIAN_FRONTEND=noninteractive apt -qq update

#	Upgrade dpkg for zstd support.

DEBIAN_FRONTEND=noninteractive apt -qq -yy install --only-upgrade --allow-downgrades \
	dpkg=1.20.9ubuntu2 \
	libc-bin=2.33-0ubuntu5 \
	libc6=2.33-0ubuntu5 \
	locales=2.33-0ubuntu5

### Upgrade GNU LibC

DEBIAN_FRONTEND=noninteractive apt -qq -yy install --only-upgrade \
	libc6
	
### Download Source

git clone --single-branch --branch $LIBAPPIMAGEUPDATE_BRANCH https://github.com/AppImage/AppImageUpdate.git
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

mkdir -p build && cd build

cmake \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DENABLE_BSYMBOLICFUNCTIONS=OFF \
	-DQUICK_COMPILER=ON \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_SYSCONFDIR=/etc \
	-DCMAKE_INSTALL_LOCALSTATEDIR=/var \
	-DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON \
	-DCMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY=ON \
	-DCMAKE_INSTALL_RUNSTATEDIR=/run "-GUnix Makefiles" \
	-DCMAKE_VERBOSE_MAKEFILE=ON \
	-DCMAKE_INSTALL_LIBDIR=lib/x86_64-linux-gnu ../libappimageupdate/

make -j$(nproc)

mkdir -p /usr/lib/cmake/AppImageUpdate

### Run checkinstall and Build Debian Package

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
	--pkgversion=$PACKAGE_VERSION \
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
