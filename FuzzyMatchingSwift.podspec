Pod::Spec.new do |s|
  s.name             = 'FuzzyMatchingSwift'
  s.version          = '0.1.0'
  s.summary          = 'FuzzyMatchingSwift provides String extensions which allow developers to find similar Strings in Strings.'
  s.description      = <<-DESC
FuzzyMatchingSwift provides String extensions which allow developers to find similar Strings in Strings.
                       DESC
  s.homepage         = 'https://github.com/seanoshea/FuzzyMatchingSwift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'seanoshea' => 'oshea.ie@gmail.com' }
  s.source           = { :git => 'https://github.com/seanoshea/FuzzyMatchingSwift.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/seanoshea'
  s.ios.deployment_target = '8.0'
  s.source_files = 'FuzzyMatchingSwift/Classes/**/*'
end
