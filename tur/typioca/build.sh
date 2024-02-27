TERMUX_PKG_HOMEPAGE=https://github.com/bloznelis/typioca
TERMUX_PKG_DESCRIPTION="Cozy typing speed tester"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="2.10.0"
TERMUX_PKG_SRCURL=https://github.com/bloznelis/typioca/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=444dbb145a862b45a8342104d428e6d13bb7089ee5bb8531ddd87d33045079db
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true
termux_step_pre_configure() {
	termux_setup_golang

	go mod init || :
	go mod tidy
}

termux_step_make() {
	go build -o typioca -ldflags="-w -s -X 'github.com/bloznelis/typioca/internal/base.Version=${TERMUX_PKG_VERSION}'"
}

termux_step_make_install() {
	install -Dm700 -t "${TERMUX_PREFIX}"/bin "$TERMUX_PKG_SRCDIR"/typioca
}
