
Pod::Spec.new do |s|
  s.name             = "MinimalTabBar"
  s.version          = "0.1.0"
  s.summary          = "A minimizing tabbar for iOS"
  s.description      = <<-DESC
MinimalTabBar is an elegant replacement for the standard UITabBar found on iOS. It includes optional navigation  gestures to improve UX and reduce the UI footprint.  Like the UITabBar, implimentation requires an array of ViewControllers and UITabBar items.
                        DESC
  s.homepage         = "https://github.com/jamesdunay/MinimalTabBar"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "jamesdunay@gmail.com" => "jamesdunay@gmail.com" }
  s.source           = { :git => "https://github.com/jamesdunay/MinimalTabBar.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/*{h,m}'
end
