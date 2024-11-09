ios:
	cargo rustc --release --target=aarch64-apple-ios
	cargo rustc --release --target=x86_64-apple-ios
	cargo rustc --release --target=aarch64-apple-ios-sim

	rm -rf target/ios-frameworks

	mkdir -p target/ios-frameworks/ios-arm64_x86_64-simulator/FlutterAvif.framework/Headers
	mkdir -p target/ios-frameworks/ios-arm64_x86_64-simulator/FlutterAvif.framework/Modules
	lipo -create -output target/ios-frameworks/ios-arm64_x86_64-simulator/FlutterAvif.framework/FlutterAvif target/x86_64-apple-ios/release/libflutter_avif.dylib target/aarch64-apple-ios-sim/release/libflutter_avif.dylib
	cp ../flutter_avif_platform_interface/headers/flutter_avif.h target/ios-frameworks/ios-arm64_x86_64-simulator/FlutterAvif.framework/Headers
	cp darwin/Info.plist target/ios-frameworks/ios-arm64_x86_64-simulator/FlutterAvif.framework/Info.plist
	cp darwin/module.modulemap target/ios-frameworks/ios-arm64_x86_64-simulator/FlutterAvif.framework/Modules/module.modulemap
	cp darwin/Export.h target/ios-frameworks/ios-arm64_x86_64-simulator/FlutterAvif.framework/Headers/Export.h

	mkdir -p target/ios-frameworks/ios-arm64/FlutterAvif.framework/Headers
	mkdir -p target/ios-frameworks/ios-arm64/FlutterAvif.framework/Modules
	cp target/aarch64-apple-ios/release/libflutter_avif.dylib target/ios-frameworks/ios-arm64/FlutterAvif.framework/FlutterAvif
	cp ../flutter_avif_platform_interface/headers/flutter_avif.h target/ios-frameworks/ios-arm64/FlutterAvif.framework/Headers
	cp darwin/Info.plist target/ios-frameworks/ios-arm64/FlutterAvif.framework/Info.plist
	cp darwin/module.modulemap target/ios-frameworks/ios-arm64/FlutterAvif.framework/Modules/module.modulemap
	cp darwin/Export.h target/ios-frameworks/ios-arm64/FlutterAvif.framework/Headers/Export.h

	rm -rf target/FlutterAvif.xcframework
	rm -rf ../flutter_avif_ios/ios/FlutterAvif.xcframework.zip
	xcodebuild -create-xcframework -framework target/ios-frameworks/ios-arm64/FlutterAvif.framework -framework target/ios-frameworks/ios-arm64_x86_64-simulator/FlutterAvif.framework -output target/FlutterAvif.xcframework
	cd target && zip -r ../../flutter_avif_ios/ios/FlutterAvif.xcframework.zip FlutterAvif.xcframework

android:
	cargo ndk -t armeabi-v7a -t arm64-v8a -t x86 -t x86_64 -o ../flutter_avif_android/android/src/main/jniLibs build --release

macos:
	MACOSX_DEPLOYMENT_TARGET=10.11 cargo build --release --target=x86_64-apple-darwin
	MACOSX_DEPLOYMENT_TARGET=10.11 cargo build --release --target=aarch64-apple-darwin

	rm -rf target/macos-frameworks

	mkdir -p target/macos-frameworks/macos-arm64_x86_64/FlutterAvif.framework/Headers
	mkdir -p target/macos-frameworks/macos-arm64_x86_64/FlutterAvif.framework/Modules

	lipo -create -output target/macos-frameworks/macos-arm64_x86_64/FlutterAvif.framework/FlutterAvif target/x86_64-apple-darwin/release/libflutter_avif.dylib target/aarch64-apple-darwin/release/libflutter_avif.dylib
	cp ../flutter_avif_platform_interface/headers/flutter_avif.h target/macos-frameworks/macos-arm64_x86_64/FlutterAvif.framework/Headers
	cp darwin/Info.plist target/macos-frameworks/macos-arm64_x86_64/FlutterAvif.framework/Info.plist
	cp darwin/module.modulemap target/macos-frameworks/macos-arm64_x86_64/FlutterAvif.framework/Modules/module.modulemap
	cp darwin/Export.h target/macos-frameworks/macos-arm64_x86_64/FlutterAvif.framework/Headers/Export.h
	
	rm -rf target/FlutterAvif.xcframework
	rm -rf ../flutter_avif_macos/macos/FlutterAvif.xcframework.zip
	xcodebuild -create-xcframework -framework target/macos-frameworks/macos-arm64_x86_64/FlutterAvif.framework -output target/FlutterAvif.xcframework
	cd target && zip -r ../../flutter_avif_macos/macos/FlutterAvif.xcframework.zip FlutterAvif.xcframework

linux:
	cargo build --release
	cp target/release/libflutter_avif.so ../flutter_avif_linux/linux/libflutter_avif.so

windows:
	cargo build --release
	cp target/release/flutter_avif.dll ../flutter_avif_windows/windows/flutter_avif.dll

bindgen:
	cbindgen --config cbindgen.toml --crate flutter_avif --lang c --output ../flutter_avif_platform_interface/headers/flutter_avif.h