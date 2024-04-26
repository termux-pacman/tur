TERMUX_PKG_HOMEPAGE=http://site.icu-project.org/home
TERMUX_PKG_DESCRIPTION='International Components for Unicode library'
TERMUX_PKG_LICENSE="BSD"
# We override TERMUX_PKG_SRCDIR termux_step_post_get_source so need to do
# this hack to be able to find the license file.
TERMUX_PKG_LICENSE_FILE="../LICENSE"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION=69.1
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://github.com/unicode-org/icu/releases/download/release-${TERMUX_PKG_VERSION//./-}/icu4c-${TERMUX_PKG_VERSION//./_}-src.tgz
TERMUX_PKG_SHA256=4cba7b7acd1d3c42c44bb0c14be6637098c7faf2b330ce876bc5f3b915d09745
TERMUX_PKG_DEPENDS="libc++"
TERMUX_PKG_HOSTBUILD=true
TERMUX_PKG_EXTRA_HOSTBUILD_CONFIGURE_ARGS="--disable-samples --disable-tests"
_INSTALL_PREFIX="$TERMUX_PREFIX/opt/$TERMUX_PKG_NAME"
TERMUX_PKG_STATICSPLIT_EXTRA_PATTERNS="$_INSTALL_PREFIX/lib/**/*.a $_INSTALL_PREFIX/lib/**/*.la"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--disable-samples
--disable-tests
--disable-tools
--disable-extra
--prefix=$_INSTALL_PREFIX
--libdir=$_INSTALL_PREFIX/lib
--sbindir=$_INSTALL_PREFIX/bin
--with-library-suffix=${TERMUX_PKG_VERSION%%.*}
--with-cross-build=$TERMUX_PKG_HOSTBUILD_DIR
"

termux_step_post_get_source() {
	TERMUX_PKG_SRCDIR+="/source"
	find . -type f | xargs touch
}

termux_step_post_make_install() {
	find "$_INSTALL_PREFIX/lib" -name "*.so*" -exec ln -sfr "{}" "$TERMUX_PREFIX/lib" \;
}
