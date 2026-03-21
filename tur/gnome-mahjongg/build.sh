TERMUX_PKG_HOMEPAGE="https://wiki.gnome.org/Apps/Mahjogg"
TERMUX_PKG_DESCRIPTION="GNOME Mahjongg game"
TERMUX_PKG_LICENSE="GPL-2.0-or-later"
TERMUX_PKG_MAINTAINER="@lunsokhasovan, @termux-user-repository"
TERMUX_PKG_VERSION="49.1.1"
TERMUX_PKG_SRCURL="https://download.gnome.org/sources/gnome-mahjongg/${TERMUX_PKG_VERSION%%.*}/gnome-mahjongg-${TERMUX_PKG_VERSION}.tar.xz"
TERMUX_PKG_SHA256=e9edd31ac2698b8d9a5be1d11c60d43450a889f8769cca0bef3395a11a5d5fd1
TERMUX_PKG_DEPENDS="glib, gtk4, libadwaita, libcairo, librsvg, opengl"
TERMUX_PKG_BUILD_DEPENDS="g-ir-scanner, gettext, itstool"
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	termux_setup_gir
	termux_setup_glib_cross_pkg_config_wrapper
}
