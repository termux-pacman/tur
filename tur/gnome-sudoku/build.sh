TERMUX_PKG_HOMEPAGE="https://wiki.gnome.org/Apps(2f)Sudoku.html"
TERMUX_PKG_DESCRIPTION="GNOME Sudoku game"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="50.1"
TERMUX_PKG_SRCURL="https://download.gnome.org/sources/gnome-sudoku/${TERMUX_PKG_VERSION%.*}/gnome-sudoku-${TERMUX_PKG_VERSION}.tar.xz"
TERMUX_PKG_SHA256=0b06c9777ecdb35a0fcd92d1649642549de816629f489f5d933315a34dcc7be2
TERMUX_PKG_DEPENDS="glib, gtk4, json-glib, libadwaita, libcairo, libgee, opengl, qqwing"
TERMUX_PKG_BUILD_DEPENDS="blueprint-compiler, itstool, g-ir-scanner, gettext"
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	termux_setup_bpc
	termux_setup_gir
	termux_setup_glib_cross_pkg_config_wrapper
}
