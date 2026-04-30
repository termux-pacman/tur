TERMUX_PKG_HOMEPAGE=https://libdicom.readthedocs.io
TERMUX_PKG_DESCRIPTION="C library for reading DICOM files"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="1.2.1"
TERMUX_PKG_SRCURL=https://github.com/ImagingDataCommons/libdicom/releases/download/v$TERMUX_PKG_VERSION/libdicom-$TERMUX_PKG_VERSION.tar.xz
TERMUX_PKG_SHA256=7a448d295b179a4c0b311c09f5253655446a44bf66b3b7d2aa4c09d15f02f1f8
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-Dtests=false
"

termux_step_pre_configure() {
	export TERMUX_MESON_ENABLE_SOVERSION=1
}

termux_step_post_massage() {
	# Do not forget to bump revision of reverse dependencies and rebuild them
	# after SOVERSION is changed.
	local _SOVERSION_GUARD_FILES="
lib/libdicom.so.1
"
	local f
	for f in ${_SOVERSION_GUARD_FILES}; do
		if [ ! -e "${f}" ]; then
			termux_error_exit "SOVERSION guard check failed."
		fi
	done
}
