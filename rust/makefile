ANDROID_NDK_HOME=/Users/yunus/Library/Android/sdk/ndk/21.4.7075529/

ios:
	cargo lipo --release
	cp target/universal/release/libflutter_avif.a ../ios/libflutter_avif.a

android:
	ANDROID_NDK_HOME="${ANDROID_NDK_HOME}" cargo ndk -t armeabi-v7a -t arm64-v8a -t x86 -t x86_64 -o ../android/src/main/jniLibs build --release

macos:
	MACOSX_DEPLOYMENT_TARGET=10.11 cargo build --release
	cp target/release/libflutter_avif.dylib ../macos/libflutter_avif.dylib