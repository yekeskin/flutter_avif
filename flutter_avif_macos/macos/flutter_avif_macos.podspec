#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_avif.podspec` to validate before publishing.
#

`
rm -rf Frameworks/FlutterAvif.xcframework
unzip flutter_avif_macos/FlutterAvif.xcframework.zip -d Frameworks/
`

Pod::Spec.new do |s|
  s.name             = 'flutter_avif_macos'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'flutter_avif_macos/Sources/flutter_avif_macos/**/*.{h,m}'
  s.public_header_files = 'flutter_avif_macos/Sources/flutter_avif_macos/include/**/*.h'
  s.dependency 'FlutterMacOS'
  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }

  s.vendored_frameworks = 'Frameworks/FlutterAvif.xcframework'
end
