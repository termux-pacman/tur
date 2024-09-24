TERMUX_PKG_HOMEPAGE="https://playit.gg"
TERMUX_PKG_DESCRIPTION="playit is a global proxy that allows anyone to host a server without port forwarding."
TERMUX_PKG_LICENSE="BSD 2-Clause"
TERMUX_PKG_MAINTAINER="@nisheri-ascar"
TERMUX_PKG_VERSION="0.15.25"
TERMUX_PKG_SRCURL=https://github.com/playit-cloud/playit-agent/archive/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=3e037e9ddcbe599c48090a489b7be5fcbf4bd4a4c7b9367b3eb7b1c6784c6c6c
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_pre_configure() {
	termux_setup_rust
}

termux_step_make() {
	cargo build --jobs $TERMUX_PKG_MAKE_PROCESSES --target $CARGO_TARGET_NAME --release
}

termux_step_make_install() {
	install -Dm755 -t $TERMUX_PREFIX/bin target/${CARGO_TARGET_NAME}/release/playit-cli
}
