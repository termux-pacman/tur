TERMUX_PKG_HOMEPAGE=https://github.com/jeessy2/ddns-go
TERMUX_PKG_DESCRIPTION="A simple, easy-to-use ddns service"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="6.6.0"
TERMUX_PKG_SRCURL=https://github.com/jeessy2/ddns-go/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=68949f25618f461a1a34ee0b3a2ae871071e1d22a7e47efd7763328c98e674f7
TERMUX_PKG_DEPENDS="libc++"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	termux_setup_golang
}

termux_step_make() {
	local _buildtime=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

	go build -ldflags="-X main.version=$TERMUX_PKG_VERSION -X main.buildTime=$_buildtime -extldflags -s -w" \
		-trimpath -buildmode=pie -o ddns-go .
}

termux_step_make_install() {
	install -Dm700 -t "${TERMUX_PREFIX}"/bin "$TERMUX_PKG_SRCDIR"/ddns-go
}
