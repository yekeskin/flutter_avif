ios:
	cargo rustc --release --target=aarch64-apple-ios --crate-type staticlib
	cargo rustc --release --target=x86_64-apple-ios --crate-type staticlib
	cargo rustc --release --target=aarch64-apple-ios-sim --crate-type staticlib
	lipo -create -output target/libflutter_avif.a target/x86_64-apple-ios/release/libflutter_avif.a target/aarch64-apple-ios-sim/release/libflutter_avif.a
	rm -rf target/FlutterAvif.xcframework
	rm -rf ../flutter_avif_ios/ios/FlutterAvif.xcframework.zip
	xcodebuild -create-xcframework -library target/aarch64-apple-ios/release/libflutter_avif.a -library target/libflutter_avif.a -output target/FlutterAvif.xcframework
	cd target && zip -r ../../flutter_avif_ios/ios/FlutterAvif.xcframework.zip FlutterAvif.xcframework

android:
	cargo ndk -t armeabi-v7a -t arm64-v8a -t x86 -t x86_64 -o ../flutter_avif_android/android/src/main/jniLibs build --release

macos:
	cargo build --release --target=x86_64-apple-darwin
	cargo build --release --target=aarch64-apple-darwin
	lipo -create -output target/libflutter_avif.a target/x86_64-apple-darwin/release/libflutter_avif.a target/aarch64-apple-darwin/release/libflutter_avif.a
	rm -rf target/FlutterAvif.xcframework
	rm -rf ../flutter_avif_macos/macos/FlutterAvif.xcframework.zip
	xcodebuild -create-xcframework -library target/libflutter_avif.a -output target/FlutterAvif.xcframework
	cd target && zip -r ../../flutter_avif_macos/macos/FlutterAvif.xcframework.zip FlutterAvif.xcframework

linux:
	cargo build --release
	cp target/release/libflutter_avif.so ../flutter_avif_linux/linux/libflutter_avif.so

windows:
	cargo build --release
	cp target/release/flutter_avif.dll ../flutter_avif_windows/windows/flutter_avif.dll

codegen:
	flutter_rust_bridge_codegen --rust-input src/api.rs --dart-output ../flutter_avif_platform_interface/lib/bridge_generated.io.dart --c-output ../flutter_avif_ios/ios/Classes/bridge_generated.h --extra-c-output-path ../flutter_avif_macos/macos/Classes/