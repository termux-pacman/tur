TERMUX_PKG_HOMEPAGE=https://developer.android.com/tools/sdk/ndk/index.html
TERMUX_PKG_DESCRIPTION="System header and library files from the Android NDK needed for compiling C programs, compact with GNU Compiler Collection"
TERMUX_PKG_LICENSE="NCSA"
TERMUX_PKG_MAINTAINER="@licy183"
# Version should be equal to TERMUX_NDK_{VERSION_NUM,REVISION} in
# scripts/properties.sh
TERMUX_PKG_VERSION=27b
TERMUX_PKG_REVISION=3
TERMUX_PKG_SRCURL=https://dl.google.com/android/repository/android-ndk-r${TERMUX_PKG_VERSION}-linux.zip
TERMUX_PKG_SHA256=33e16af1a6bbabe12cad54b2117085c07eab7e4fa67cdd831805f0e94fd826c1
# This package has taken over <pty.h> from the previous libutil-dev
# and iconv.h from libandroid-support-dev:
TERMUX_PKG_CONFLICTS="libutil-dev, libandroid-support-dev, ndk-sysroot"
TERMUX_PKG_REPLACES="libutil-dev, libandroid-support-dev, ndk-stl, ndk-sysroot"
TERMUX_PKG_PROVIDES="ndk-sysroot"
TERMUX_PKG_NO_STATICSPLIT=true
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_RM_AFTER_INSTALL="
include/EGL
include/GLES
include/GLES2
include/GLES3
include/KHR/khrplatform.h
include/execinfo.h
include/glob.h
include/iconv.h
include/spawn.h
include/sys/capability.h
include/sys/sem.h
include/sys/shm.h
include/unicode
include/vk_video
include/vulkan
include/zconf.h
include/zlib.h
"

termux_step_get_source() {
	mkdir -p "$TERMUX_PKG_SRCDIR"
	if [ "$TERMUX_ON_DEVICE_BUILD" = "true" ]; then
		termux_download_src_archive
		cd $TERMUX_PKG_TMPDIR
		termux_extract_src_archive
	else
		local lib_path="toolchains/llvm/prebuilt/linux-x86_64/sysroot"
		mkdir -p "$TERMUX_PKG_SRCDIR"/"$lib_path"
		cp -fr "$NDK"/"$lib_path"/* "$TERMUX_PKG_SRCDIR"/"$lib_path"/
		lib_path="toolchains/llvm/prebuilt/linux-x86_64/lib"
		mkdir -p "$TERMUX_PKG_SRCDIR"/"$lib_path"
		cp -fr "$NDK"/"$lib_path"/* "$TERMUX_PKG_SRCDIR"/"$lib_path"/
	fi
}

termux_step_post_get_source() {
	pushd toolchains/llvm/prebuilt/linux-x86_64/sysroot/
	for patch in $TERMUX_SCRIPTDIR/ndk-patches/$TERMUX_PKG_VERSION/*.patch; do
		echo "Applying ndk patch: $(basename $patch)"
		test -f "$patch" && sed \
			-e "s%\@TERMUX_APP_PACKAGE\@%${TERMUX_APP_PACKAGE}%g" \
			-e "s%\@TERMUX_BASE_DIR\@%${TERMUX_BASE_DIR}%g" \
			-e "s%\@TERMUX_CACHE_DIR\@%${TERMUX_CACHE_DIR}%g" \
			-e "s%\@TERMUX_HOME\@%${TERMUX_ANDROID_HOME}%g" \
			-e "s%\@TERMUX_PREFIX\@%${TERMUX_PREFIX}%g" \
			"$patch" | patch --silent -p1
	done
	sed -i "s/define __ANDROID_API__ __ANDROID_API_FUTURE__/define __ANDROID_API__ $TERMUX_PKG_API_LEVEL/" \
		usr/include/android/api-level.h
	grep -lrw usr/include/c++/v1 -e '<version>' | xargs -n 1 sed -i 's/<version>/\"version\"/g'
	popd
}

termux_step_make_install() {
	mkdir -p $TERMUX_PKG_MASSAGEDIR/$TERMUX_PREFIX/lib \
		$TERMUX_PKG_MASSAGEDIR/$TERMUX_PREFIX/include

	cp -Rf toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/include/* \
		$TERMUX_PKG_MASSAGEDIR/$TERMUX_PREFIX/include

	find $TERMUX_PKG_MASSAGEDIR/$TERMUX_PREFIX/include -name \*.orig -delete

	cp $TERMUX_SCRIPTDIR/ndk-patches/{langinfo,libintl}.h $TERMUX_PKG_MASSAGEDIR/$TERMUX_PREFIX/include/

	cp toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/$TERMUX_HOST_PLATFORM/$TERMUX_PKG_API_LEVEL/*.o \
		$TERMUX_PKG_MASSAGEDIR/$TERMUX_PREFIX/lib

	cp toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/$TERMUX_HOST_PLATFORM/libcompiler_rt-extras.a \
		$TERMUX_PKG_MASSAGEDIR/$TERMUX_PREFIX/lib/

	NDK_ARCH=$TERMUX_ARCH
	test $NDK_ARCH == 'i686' && NDK_ARCH='i386'

	# clang 13 requires libunwind on Android.
	cp toolchains/llvm/prebuilt/linux-x86_64/lib/clang/*/lib/linux/$NDK_ARCH/libatomic.a \
		$TERMUX_PKG_MASSAGEDIR/$TERMUX_PREFIX/lib
	cp toolchains/llvm/prebuilt/linux-x86_64/lib/clang/*/lib/linux/$NDK_ARCH/libunwind.a \
		$TERMUX_PKG_MASSAGEDIR/$TERMUX_PREFIX/lib

	# librt and libpthread are built into libc on android, so setup them as symlinks
	# to libc for compatibility with programs that users try to build:
	for lib in librt.so libpthread.so libutil.so; do
		echo 'INPUT(-lc)' > $TERMUX_PKG_MASSAGEDIR/$TERMUX_PREFIX/lib/$lib
	done
	unset lib

	# Dummy libstdc++ as libc++
	echo "INPUT(-lc++_shared)" > $TERMUX_PKG_MASSAGEDIR/$TERMUX_PREFIX/lib/libstdc++.so
	echo "INPUT(-lc++_static -lc++abi)" > $TERMUX_PKG_MASSAGEDIR/$TERMUX_PREFIX/lib/libstdc++.a
}
