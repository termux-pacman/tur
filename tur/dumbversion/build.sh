TERMUX_PKG_HOMEPAGE=https://github.com/thecatontheceiling/DumbVersion
TERMUX_PKG_DESCRIPTION="A high-performance binary diffing and patching engine for massive files"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-user-repository"
TERMUX_PKG_VERSION="1.2.1"
TERMUX_PKG_SRCURL=git+https://github.com/thecatontheceiling/DumbVersion
TERMUX_PKG_GIT_BRANCH="v${TERMUX_PKG_VERSION}"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_DEPENDS="dotnet-host, dotnet-runtime-10.0"
TERMUX_PKG_BUILD_DEPENDS="dotnet-targeting-pack-10.0"
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_EXCLUDED_ARCHES="arm"
TERMUX_DOTNET_VERSION=10.0
TERMUX_PKG_UPDATE_TAG_TYPE="latest-release-tag"
TERMUX_PKG_UPDATE_VERSION_SED_REGEXP='s/v//g'

termux_step_pre_configure() {
	termux_setup_dotnet
}

termux_step_make() {
	dotnet publish -c Release -r ${DOTNET_TARGET_NAME} /p:PublishAot=false -p:UseAppHost=false -p:DebugType=embedded --no-self-contained --output out
}

termux_step_make_install() {
	ls -l out

	find out -name "*.dll" -exec chmod 0644 "{}" \;

	rm out/LibDumbVersion.deps.json

	mkdir -p "${TERMUX_PREFIX}/lib"
	cp -r out "${TERMUX_PREFIX}/lib/${TERMUX_PKG_NAME}"

	cat <<- EOL > ${TERMUX_PREFIX}/bin/${TERMUX_PKG_NAME}creator
	#!${TERMUX_PREFIX}/bin/sh
	exec dotnet "${TERMUX_PREFIX}/lib/${TERMUX_PKG_NAME}/DumbVersionCreator.dll" "\$@"
	EOL
	chmod 0755 "${TERMUX_PREFIX}/bin/${TERMUX_PKG_NAME}creator"

	cat <<- EOL > ${TERMUX_PREFIX}/bin/${TERMUX_PKG_NAME}patcher
	#!${TERMUX_PREFIX}/bin/sh
	exec dotnet "${TERMUX_PREFIX}/lib/${TERMUX_PKG_NAME}/DumbVersionPatcher.dll" "\$@"
	EOL
	chmod 0755 "${TERMUX_PREFIX}/bin/${TERMUX_PKG_NAME}patcher"
}
