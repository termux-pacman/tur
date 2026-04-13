TERMUX_PKG_HOMEPAGE=https://www.qt.io/
TERMUX_PKG_DESCRIPTION="Qt 5 QMake"
TERMUX_PKG_LICENSE="LGPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="5.15.18"
TERMUX_PKG_SRCURL="https://download.qt.io/archive/qt/${TERMUX_PKG_VERSION%.*}/${TERMUX_PKG_VERSION}/submodules/qtbase-everywhere-opensource-src-${TERMUX_PKG_VERSION}.tar.xz"
TERMUX_PKG_SHA256=7b632550ea1048fc10c741e46e2e3b093e5ca94dfa6209e9e0848800e247023b
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_DEPENDS="qt5-qtbase"
TERMUX_PKG_BUILD_DEPENDS="which"
TERMUX_PKG_BREAKS="qt5-qtbase (<< 5.15.7)"
TERMUX_PKG_REPLACES="qt5-qtbase (<< 5.15.7)"

termux_step_post_get_source() {
	# Version guard
	local ver_e=${TERMUX_PKG_VERSION#*:}
	local ver_x=$(. $TERMUX_SCRIPTDIR/x11-packages/qt5-qtbase/build.sh; echo ${TERMUX_PKG_VERSION#*:})
	if [ "${ver_e}" != "${ver_x}" ]; then
		termux_error_exit "Version mismatch between qt5-qtbase and qt5-qmake."
	fi

	local p
	for p in $TERMUX_SCRIPTDIR/x11-packages/qt5-qtbase/*.patch; do
		echo "Applying $(basename "${p}")"
		sed "s|@TERMUX_PREFIX@|${TERMUX_PREFIX}|g" "${p}" \
			| patch --silent -p1
	done
}

termux_step_configure () {
	export PKG_CONFIG_SYSROOT_DIR="${TERMUX_PREFIX}"

	./configure -v \
		-opensource \
		-confirm-license \
		-release \
		-platform termux \
		-shared \
		-no-rpath \
		-no-use-gold-linker \
		-prefix "${TERMUX_PREFIX}" \
		-docdir "${TERMUX_PREFIX}/share/doc/qt" \
		-archdatadir "${TERMUX_PREFIX}/lib/qt" \
		-datadir "${TERMUX_PREFIX}/share/qt" \
		-plugindir "${TERMUX_PREFIX}/libexec/qt" \
		-nomake examples \
		-no-pch \
		-no-accessibility \
		-no-glib \
		-icu \
		-system-pcre \
		-system-zlib \
		-system-freetype \
		-ssl \
		-openssl-linked \
		-no-system-proxies \
		-no-cups \
		-system-harfbuzz \
		-no-opengl \
		-no-vulkan \
		-qpa xcb \
		-no-eglfs \
		-no-gbm \
		-no-kms \
		-no-linuxfb \
		-no-libudev \
		-no-evdev \
		-no-libinput \
		-no-mtdev \
		-no-tslib \
		-xcb \
		-xcb-xlib \
		-gif \
		-system-libpng \
		-system-libjpeg \
		-system-sqlite \
		-sql-sqlite
}

termux_step_make() {
	pushd qmake
	## Bootstrap qmake.
	echo "[*] Bootstrapping qmake..."
	../bin/qmake -spec termux -o Makefile.qmake-aux qmake-aux.pro
	make -f Makefile.qmake-aux

	## Just verify.
	echo "[*] Verifying..."
	./qmake -spec termux -o Makefile.qmake-aux qmake-aux.pro
	make -f Makefile.qmake-aux
	popd
}

termux_step_make_install() {
	install \
		-Dm700 "${TERMUX_PKG_SRCDIR}/qmake/qmake" \
		"${TERMUX_PREFIX}/bin/qmake"
}
