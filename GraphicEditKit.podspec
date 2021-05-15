#
# Be sure to run `pod lib lint GraphicEditKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GraphicEditKit'
  s.version          = '0.0.6'
  s.summary          = 'Flash 图文编辑'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/MeiYuLong/GraphicEditKit.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'MeiYuLong' => 'longjiao914@126.com' }
  s.source           = { :git => 'https://github.com/MeiYuLong/GraphicEditKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.swift_version = '5.0'

  s.source_files = 'GraphicEditKit/Classes/**/*'
  
  s.resource_bundles = {
      'GraphicEditKit' => ['GraphicEditKit/Assets/**/*']
  }
   
   s.public_header_files = 'ParseAddressKit/Classes/*.h'
   
   s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
   s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'SnapKit', '~> 5.0.0'
  s.dependency 'MBProgressHUD', '~> 1.1.0'
  s.dependency 'JPImageresizerView', '~> 1.7.7'
  s.dependency 'GPUImage', '~> 0.1.7'
  s.dependency 'FlashPrinter'
end
