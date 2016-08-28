Pod::Spec.new do |s|
  s.name             = 'FuzzyMatchingSwift'
  s.version          = '0.1.0'
  s.summary          = 'A short description of FuzzyMatchingSwift.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC
  s.homepage         = 'https://github.com/<GITHUB_USERNAME>/FuzzyMatchingSwift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'seanoshea' => 'oshea.ie@gmail.com' }
  s.source           = { :git => 'https://github.com/<GITHUB_USERNAME>/FuzzyMatchingSwift.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/seanoshea'
  s.ios.deployment_target = '8.0'
  s.source_files = 'FuzzyMatchingSwift/Classes/**/*'
end
