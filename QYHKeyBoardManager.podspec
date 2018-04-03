#
#  Be sure to run `pod spec lint QYHKeyBoardManager.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "QYHKeyBoardManager"
  s.version      = "0.0.3"
  s.summary      = "键盘弹起处理"
  s.description  = "键盘弹起处理，适合所有的界面，简单方便"
  s.homepage     = "https://github.com/qiuyh/QiuyhKeyBoardLib"
  s.license      = "MIT"
  s.author       = { "qiuyh" => "1039724903@qq.com" }
  s.platform     = :ios
  s.source       = { :git => "https://github.com/qiuyh/QiuyhKeyBoardLib.git", :tag => "#{s.version}" }
  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.requires_arc  = true

  s.public_header_files    = "Classes/QYHKeyBoardManager.h"
  s.ios.vendored_libraries = "Classes/libQYHKeyBoardManager.a"

end
