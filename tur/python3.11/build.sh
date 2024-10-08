TERMUX_PKG_HOMEPAGE=https://python.org/
TERMUX_PKG_DESCRIPTION="Python programming language intended to enable clear programs (version 3.11)"
# License: PSF-2.0
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="LICENSE"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=3.11.10
TERMUX_PKG_SRCURL=https://www.python.org/ftp/python/${TERMUX_PKG_VERSION}/Python-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=07a4356e912900e61a15cb0949a06c4a05012e213ecd6b4e84d0f67aabbee372
TERMUX_PKG_AUTO_UPDATE=false
TERMUX_PKG_DEPENDS="gdbm, libandroid-posix-semaphore, libandroid-support, libbz2, libcrypt, libexpat, libffi, liblzma, libsqlite, ncurses, ncurses-ui-libs, openssl, readline, zlib"
TERMUX_PKG_BUILD_DEPENDS="tk"
TERMUX_PKG_SUGGESTS="python3.11-tkinter"
TERMUX_PKG_MAKE_INSTALL_TARGET=altinstall
TERMUX_PKG_HOSTBUILD=true

# https://github.com/termux/termux-packages/issues/15908
TERMUX_PKG_MAKE_PROCESSES=1

_MAJOR_VERSION="${TERMUX_PKG_VERSION%.*}"

# Set ac_cv_func_wcsftime=no to avoid errors such as "character U+ca0025 is not in range [U+0000; U+10ffff]"
# when executing e.g. "from time import time, strftime, localtime; print(strftime(str('%Y-%m-%d %H:%M'), localtime()))"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="ac_cv_file__dev_ptmx=yes ac_cv_file__dev_ptc=no ac_cv_func_wcsftime=no"
# Avoid trying to include <sys/timeb.h> which does not exist on android-21:
TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" ac_cv_func_ftime=no"
# Avoid trying to use AT_EACCESS which is not defined:
TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" ac_cv_func_faccessat=no"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" --build=$TERMUX_BUILD_TUPLE --with-system-ffi --with-system-expat --without-ensurepip"
# Hard links does not work on Android 6:
TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" ac_cv_func_linkat=no"
# Do not assume getaddrinfo is buggy when cross compiling:
TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" ac_cv_buggy_getaddrinfo=no"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" --enable-loadable-sqlite-extensions"
# Fix https://github.com/termux/termux-packages/issues/2236:
TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" ac_cv_little_endian_double=yes"
# Force enable posix semaphores.
TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" ac_cv_posix_semaphores_enabled=yes"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" ac_cv_func_sem_open=yes"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" ac_cv_func_sem_timedwait=yes"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" ac_cv_func_sem_getvalue=yes"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" ac_cv_func_sem_unlink=yes"
# Force enable posix shared memory.
TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" ac_cv_func_shm_open=yes"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" ac_cv_func_shm_unlink=yes"

TERMUX_PKG_RM_AFTER_INSTALL="
lib/python${_MAJOR_VERSION}/test
lib/python${_MAJOR_VERSION}/*/test
lib/python${_MAJOR_VERSION}/*/tests
lib/python${_MAJOR_VERSION}/site-packages/*/
"

TERMUX_PKG_EXTRA_HOSTBUILD_CONFIGURE_ARGS="
--prefix=$TERMUX_PREFIX/opt/python$_MAJOR_VERSION/cross
"

TERMUX_PKG_UNDEF_SYMBOLS_FILES="
./opt/python$_MAJOR_VERSION/cross/lib/python$_MAJOR_VERSION/lib-dynload/*.so
"

termux_step_host_build() {
	$TERMUX_PKG_SRCDIR/configure $TERMUX_PKG_EXTRA_HOSTBUILD_CONFIGURE_ARGS
	make -j $TERMUX_PKG_MAKE_PROCESSES
	make altinstall
}

termux_step_pre_configure() {
	# Remove this marker all the time.
	rm -rf $TERMUX_HOSTBUILD_MARKER

	export PATH="$TERMUX_PREFIX/opt/python$_MAJOR_VERSION/cross/bin:$PATH"
	# -O3 gains some additional performance on at least aarch64.
	CFLAGS="${CFLAGS/-Oz/-O3}"

	# Needed when building with clang, as setup.py only probes
	# gcc for include paths when finding headers for determining
	# if extension modules should be built (specifically, the
	# zlib extension module is not built without this):
	CPPFLAGS+=" -I$TERMUX_STANDALONE_TOOLCHAIN/sysroot/usr/include"
	LDFLAGS+=" -L$TERMUX_STANDALONE_TOOLCHAIN/sysroot/usr/lib"
	if [ $TERMUX_ARCH = x86_64 ]; then LDFLAGS+=64; fi

	if [ "$TERMUX_ON_DEVICE_BUILD" = "true" ]; then
		# Python's configure script fails with
		#    Fatal: you must define __ANDROID_API__
		# if __ANDROID_API__ is not defined.
		CPPFLAGS+=" -D__ANDROID_API__=$(getprop ro.build.version.sdk)"
	else
		TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" --with-build-python=python$_MAJOR_VERSION"
	fi

	export LIBCRYPT_LIBS="-lcrypt"
}

termux_step_post_make_install() {
	ln -sfr $TERMUX_PREFIX/bin/python$_MAJOR_VERSION $TERMUX_PREFIX/bin/python
	ln -sfr $TERMUX_PREFIX/bin/python$_MAJOR_VERSION $TERMUX_PREFIX/bin/python3
}

termux_step_post_massage() {
	# Verify that desired modules have been included:
	for module in _bz2 _curses _lzma _sqlite3 _ssl _tkinter zlib; do
		if [ ! -f "${TERMUX_PREFIX}/lib/python${_MAJOR_VERSION}/lib-dynload/${module}".*.so ]; then
			termux_error_exit "Python module library $module not built"
		fi
	done
}

termux_step_create_debscripts() {
	# Post-installation script for setting up pip.
	cat <<- POSTINST_EOF > ./postinst
	#!$TERMUX_PREFIX/bin/sh

	echo "Setting up pip..."

	cd ${TERMUX_PREFIX}/tmp
	${TERMUX_PREFIX}/bin/python${_MAJOR_VERSION} -m ensurepip --altinstall --upgrade

	exit 0
	POSTINST_EOF

	# Pre-rm script to cleanup runtime-generated files.
	cat <<- PRERM_EOF > ./prerm
	#!$TERMUX_PREFIX/bin/sh

	if [ "$TERMUX_PACKAGE_FORMAT" != "pacman" ] && [ "\$1" != "remove" ]; then
	    exit 0
	fi

	echo "Uninstalling python modules..."
	cd ${TERMUX_PREFIX}/tmp
	pip${_MAJOR_VERSION} freeze 2>/dev/null | xargs pip${_MAJOR_VERSION} uninstall -y >/dev/null 2>/dev/null
	rm -f $TERMUX_PREFIX/bin/pip${_MAJOR_VERSION} $TERMUX_PREFIX/bin/easy_install-${_MAJOR_VERSION}

	echo "Deleting remaining files from site-packages..."
	rm -Rf $TERMUX_PREFIX/lib/python${_MAJOR_VERSION}/site-packages/*

	exit 0
	PRERM_EOF

	chmod 0755 postinst prerm
}
