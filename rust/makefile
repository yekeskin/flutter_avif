ios:
	cargo lipo --release
	cp target/universal/release/libflutter_avif.a ../flutter_avif_ios/ios/libflutter_avif.a

android:
	ANDROID_NDK_HOME="${ANDROID_NDK_HOME}" cargo ndk -t armeabi-v7a -t arm64-v8a -t x86 -t x86_64 -o ../flutter_avif_android/android/src/main/jniLibs build --release

macos:
	MACOSX_DEPLOYMENT_TARGET=10.11 cargo build --release
	cp target/release/libflutter_avif.dylib ../flutter_avif_macos/macos/libflutter_avif.dylib

linux:
	cargo build --release
	cp target/release/libflutter_avif.so ../flutter_avif_linux/linux/libflutter_avif.so

windows:
	cargo build --release
	cp target/release/flutter_avif.dll ../flutter_avif_windows/windows/flutter_avif.dll
