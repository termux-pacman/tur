TERMUX_PKG_HOMEPAGE="https://wiki.gnome.org/Apps(2f)Sudoku.html"
TERMUX_PKG_DESCRIPTION="GNOME Sudoku game"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="50.0"
TERMUX_PKG_SRCURL="https://download.gnome.org/sources/gnome-sudoku/${TERMUX_PKG_VERSION%.*}/gnome-sudoku-${TERMUX_PKG_VERSION}.tar.xz"
TERMUX_PKG_SHA256=525fedff287c83e3fa73c5a474e1a49f0d0b8b588e3deb08ca341770c781425d
TERMUX_PKG_DEPENDS="glib, gtk4, json-glib, libadwaita, libcairo, libgee, opengl, qqwing"
TERMUX_PKG_BUILD_DEPENDS="blueprint-compiler, itstool, g-ir-scanner, gettext"
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	termux_setup_bpc
	termux_setup_gir
	termux_setup_glib_cross_pkg_config_wrapper
}
