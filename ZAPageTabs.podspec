root_path = "/Users/zartarn/works/ZA"

Pod::Spec.new do |s|

  s.name         = "ZAPageTabs"
  s.version      = "0.0.1"
  s.summary      = "Tabs Page Controller"

  s.description  = "Tabs Page Controller"
  s.homepage     = "https://github.com/ZartArn"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

  s.license      = "MIT"
  s.author             = { "ZartArn" => "lewozart@gmail.com" }

  s.platform     = :ios, "9.0"
  s.source       = { :git => 'https://github.com/ZartArn/ZAPagerTabs.git' }
  s.source_files  = 'Source', 'Source/**/*.{h,m}'
  # s.public_header_files = "Classes/**/*.h"

  # s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"

  # s.requires_arc = true
  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"

end
